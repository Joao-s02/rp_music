import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

import '../domain/track.dart';
import '../data/local_store.dart';
import '../data/replay_gain.dart';
import 'native_audio_player.dart';
import 'equalizer_settings.dart';

class MusicHandler extends BaseAudioHandler with SeekHandler {
  AudioPlayer _player;
  final AudioPlayer Function() _createCrossfadePlayer;
  AudioPlayer get player => _player;
  final _playerSubscriptions = <StreamSubscription<dynamic>>[];
  final _positions = StreamController<Duration>.broadcast();
  final _durations = StreamController<Duration?>.broadcast();
  final _states = StreamController<PlayerState>.broadcast();
  final _volumes = StreamController<double>.broadcast();
  Stream<Duration> get positionStream => _positions.stream;
  Stream<Duration?> get durationStream => _durations.stream;
  Stream<PlayerState> get playerStateStream => _states.stream;
  Stream<double> get volumeStream => _volumes.stream;
  double get appVolume => _appVolume;

  double _appVolume = 1;
  bool gapless = true;
  bool equalizerEnabled = false;
  List<double> equalizerGains = const [];
  EqualizerEffects equalizerEffects = const EqualizerEffects();
  List<EqualizerProfile> equalizerProfiles = const [];
  List<double> _legacyAndroidGains = const [];
  Future<void> _equalizerUpdate = Future.value();
  bool _desktopDynamics = false;

  bool get supportsEqualizer => Platform.isWindows || Platform.isAndroid;
  bool get supportsEqualizerDynamics => Platform.isAndroid || _desktopDynamics;
  List<int> get equalizerFrequencies =>
      supportsEqualizer ? graphicEqualizerFrequencies : const [];
  double get minEqualizerGain => -12;
  double get maxEqualizerGain => 12;

  Future<void> setEqualizer({
    required bool enabled,
    List<double>? gains,
    EqualizerEffects? effects,
  }) async {
    equalizerEnabled = enabled;
    if (gains != null) {
      _legacyAndroidGains = const [];
      equalizerGains = List.unmodifiable(gains);
    }
    if (effects != null) equalizerEffects = effects;
    await _refreshEqualizer();
    await _savePlaybackSettings();
  }

  Future<void> _refreshEqualizer() {
    if (!supportsEqualizer) return Future.value();
    final enabled = equalizerEnabled;
    final gains = equalizerGains;
    final effects = equalizerEffects;
    return _equalizerUpdate = _equalizerUpdate.then((_) async {
      if (_shuttingDown) return;
      try {
        await configureNativeEqualizer(
          enabled: enabled,
          frequencies: equalizerFrequencies,
          gains: gains,
          effects: effects,
          dynamicsControls: supportsEqualizerDynamics,
        );
      } catch (error) {
        recordEvent('Ecualizador no disponible: ${error.runtimeType}');
        errors.add('No se pudo aplicar el ecualizador.');
      }
    });
  }

  Future<void> _migrateAndroidEqualizer(AudioPlayer target) async {
    final legacy = _legacyAndroidGains;
    final session = target.androidAudioSessionId;
    if (legacy.isEmpty || session == null || session <= 0) return;
    try {
      final bands = await legacyAndroidEqualizerFrequencies(session);
      if (!identical(legacy, _legacyAndroidGains) || _shuttingDown) return;
      if (bands.length != legacy.length) return;
      await setEqualizer(
        enabled: equalizerEnabled,
        gains: EqualizerProfile.fromJson({
          'version': 1,
          'name': 'Android',
          'frequencies': bands,
          'gains': legacy,
          'effects': const EqualizerEffects().toJson(),
        }).gainsFor(equalizerFrequencies),
      );
    } catch (error) {
      recordEvent('Migración del ecualizador pendiente: ${error.runtimeType}');
    }
  }

  EqualizerProfile currentEqualizerProfile(String name) =>
      EqualizerProfile.fromJson({
        'version': 1,
        'name': name,
        'frequencies': equalizerFrequencies,
        'gains': List.generate(
          equalizerFrequencies.length,
          (i) => equalizerGains.elementAtOrNull(i)?.clamp(-12, 12) ?? 0,
        ),
        'effects': equalizerEffects.toJson(),
      });

  Future<void> saveEqualizerProfile(EqualizerProfile profile) async {
    final profiles = equalizerProfiles.where(
      (item) => item.name != profile.name,
    );
    if (profiles.length >= 40) {
      throw const FormatException('Elimina un perfil antes de guardar otro.');
    }
    equalizerProfiles = List.unmodifiable([...profiles, profile]);
    await _savePlaybackSettings();
  }

  Future<void> removeEqualizerProfile(EqualizerProfile profile) async {
    equalizerProfiles = List.unmodifiable(
      equalizerProfiles.where((item) => item.name != profile.name),
    );
    await _savePlaybackSettings();
  }

  Future<void> applyEqualizerProfile(EqualizerProfile profile) => setEqualizer(
    enabled: true,
    gains: profile.gainsFor(equalizerFrequencies),
    effects: profile.effects,
  );

  ReplayGainMode replayGainMode = ReplayGainMode.off;
  final Future<ReplayGainTags?> Function(String)? replayGainLoader;
  final _gainCache = <String, Future<ReplayGainTags?>>{};
  double _currentGain = 1;
  double _incomingGain = 1;
  final bool _supportsNativeQueue;
  bool _nativeQueue = false;
  int? _preparedEntry;
  bool _updatingNativeQueue = false;
  bool _nativeQueueDirty = false;
  int crossfadeSeconds = 0;
  int crossfadeLength = 5;
  Timer? _crossfadeTimer;
  AudioPlayer? _incoming;
  int? _incomingEntry;
  bool _incomingReady = false;
  bool _incomingStarted = false;
  int? _failedCrossfadeEntry;
  double _fadeProgress = 0;

  late final LocalStore? _playbackSettings = sessionStore == null
      ? null
      : LocalStore(sessionStore!.directory, baseName: 'playback-settings');

  Future<void> loadPlaybackSettings() async {
    if (Platform.isWindows) {
      _desktopDynamics = await supportsNativeDynamicsControls();
    }
    final settings = await _playbackSettings?.load();
    gapless = settings?['gapless'] != false;
    equalizerEnabled = settings?['equalizerEnabled'] == true;
    final savedGains = settings?['equalizerGains'];
    if (savedGains is List &&
        savedGains.every((value) => value is num && value.isFinite)) {
      equalizerGains = savedGains
          .cast<num>()
          .map((value) => value.toDouble())
          .toList();
    }
    replayGainMode = ReplayGainMode.values.firstWhere(
      (mode) => mode.name == settings?['replayGain'],
      orElse: () => ReplayGainMode.off,
    );
    try {
      final effects = settings?['equalizerEffects'];
      if (effects != null) {
        equalizerEffects = EqualizerEffects.fromJson(effects);
      }
    } on FormatException {
      equalizerEffects = const EqualizerEffects();
    }
    final profiles = settings?['equalizerProfiles'];
    if (profiles is List) {
      final valid = <String, EqualizerProfile>{};
      for (final item in profiles.take(40)) {
        try {
          final profile = EqualizerProfile.fromJson(item);
          valid[profile.name] = profile;
        } on FormatException {
          continue;
        }
      }
      equalizerProfiles = List.unmodifiable(valid.values);
    }
    final pendingMigration = settings?['legacyAndroidEqualizerGains'];
    if (Platform.isAndroid &&
        pendingMigration is List &&
        pendingMigration.every((value) => value is num && value.isFinite)) {
      _legacyAndroidGains = pendingMigration
          .cast<num>()
          .map((value) => value.toDouble())
          .toList();
    }
    if (settings?['equalizerLayout'] != 1 && equalizerGains.isNotEmpty) {
      if (Platform.isWindows) {
        final legacyProfile = EqualizerProfile(
          name: 'Windows',
          frequencies: legacyDesktopFrequencies,
          gains: List.generate(
            legacyDesktopFrequencies.length,
            (i) => equalizerGains.elementAtOrNull(i) ?? 0,
          ),
          effects: equalizerEffects,
        );
        equalizerGains = legacyProfile.gainsFor(equalizerFrequencies);
      } else if (Platform.isAndroid) {
        _legacyAndroidGains = equalizerGains;
        equalizerGains = const [];
      }
    }
    if (equalizerEnabled) await _refreshEqualizer();
    final length = settings?['crossfadeLength'];
    crossfadeLength = length is int ? length.clamp(1, 12) : 5;
    if (!_shuttingDown) _setCrossfade(settings?['crossfadeEnabled'] == true);
  }

  Future<void> setCrossfade({required bool enabled, int? seconds}) async {
    if (seconds != null) crossfadeLength = seconds.clamp(1, 12);
    _setCrossfade(enabled);
    _refreshNativeQueue();
    await _savePlaybackSettings();
  }

  Future<void> setGapless(bool enabled) async {
    gapless = enabled;
    _refreshNativeQueue();
    await _savePlaybackSettings();
  }

  Future<void> setReplayGain(ReplayGainMode mode) async {
    replayGainMode = mode;
    final current = index < 0 ? null : tracks[index];
    if (current != null) {
      final gain = await _gainFor(current);
      if (!_shuttingDown &&
          mode == replayGainMode &&
          index >= 0 &&
          tracks[index] == current) {
        _currentGain = gain;
        _updateFadeVolumes();
      }
    }
    await _savePlaybackSettings();
  }

  Future<double> _gainFor(Track track) async {
    final load = replayGainLoader;
    final mode = replayGainMode;
    if (mode == ReplayGainMode.off || load == null) return 1;
    if (_gainCache.length >= 128) _gainCache.remove(_gainCache.keys.first);
    final key = '${track.id}:${track.modifiedMs}:${track.size}';
    try {
      final tags = await _gainCache
          .putIfAbsent(key, () => load(track.id))
          .timeout(const Duration(seconds: 3));
      return tags?.multiplier(mode) ?? 1;
    } catch (_) {
      _gainCache.remove(key);
      return 1;
    }
  }

  Future<void> _savePlaybackSettings() async {
    try {
      await _playbackSettings?.save({
        'crossfadeEnabled': crossfadeSeconds > 0,
        'gapless': gapless,
        'equalizerEnabled': equalizerEnabled,
        'equalizerGains': equalizerGains,
        'equalizerLayout': 1,
        'equalizerEffects': equalizerEffects.toJson(),
        'equalizerProfiles': equalizerProfiles
            .map((item) => item.toJson())
            .toList(),
        'legacyAndroidEqualizerGains': _legacyAndroidGains,
        'replayGain': replayGainMode.name,
        'crossfadeLength': crossfadeLength,
      });
    } catch (error) {
      recordEvent(
        'Error al guardar los ajustes de reproducción: ${error.runtimeType}',
      );
      if (!_shuttingDown) {
        errors.add('No se pudo guardar los ajustes de reproducción.');
      }
    }
  }

  void _setCrossfade(bool enabled) {
    _cancelCrossfade();
    _failedCrossfadeEntry = null;
    crossfadeSeconds = enabled ? crossfadeLength : 0;
    _refreshCrossfadeTimer();
  }

  void _refreshCrossfadeTimer() {
    if (crossfadeSeconds > 0 && player.playing && !_shuttingDown) {
      _crossfadeTimer ??= Timer.periodic(
        const Duration(milliseconds: 50),
        (_) => _tickCrossfade(),
      );
    } else {
      _crossfadeTimer?.cancel();
      _crossfadeTimer = null;
    }
  }

  void _cancelCrossfade() {
    final incoming = _incoming;
    if (incoming == null) return;
    _incoming = null;
    _incomingEntry = null;
    _incomingReady = false;
    _incomingStarted = false;
    _fadeProgress = 0;
    unawaited(incoming.dispose().catchError((Object _) {}));
    _setPlayerVolume(player, _appVolume * _currentGain);
  }

  void _setPlayerVolume(AudioPlayer target, double value) {
    unawaited(
      target.setVolume(value.clamp(0.0, 1.0)).catchError((Object _) {}),
    );
  }

  bool get _canCrossfade =>
      !_shuttingDown &&
      !_loading &&
      crossfadeSeconds > 0 &&
      !repeat &&
      _playIntent &&
      player.playing &&
      index >= 0 &&
      index + 1 < tracks.length;

  void _tickCrossfade() {
    final duration = player.duration;
    if (!_canCrossfade ||
        duration == null ||
        player.processingState != ProcessingState.ready) {
      if (player.processingState != ProcessingState.completed) {
        _cancelCrossfade();
      }
      return;
    }
    final nextEntry = _entries[index + 1];
    final remaining = duration - player.position;
    final fade = Duration(seconds: crossfadeSeconds);
    // Leave short tracks intact and avoid overlapping most of either track.
    if (duration <= fade * 2 || remaining > fade + const Duration(seconds: 4)) {
      _cancelCrossfade();
      return;
    }
    if (_incomingEntry != nextEntry) _cancelCrossfade();
    if (_failedCrossfadeEntry == nextEntry) return;
    if (_incoming == null && remaining > fade) {
      unawaited(_prepareCrossfade(nextEntry, tracks[index + 1], fade));
      return;
    }
    final incoming = _incoming;
    if (incoming == null || !_incomingReady || remaining > fade) return;
    if (!_incomingStarted) {
      if (remaining < fade - const Duration(milliseconds: 300)) {
        _cancelCrossfade();
        return;
      }
      _incomingStarted = true;
      unawaited(
        incoming.play().catchError((Object error) {
          if (identical(_incoming, incoming)) {
            _failedCrossfadeEntry = nextEntry;
            _cancelCrossfade();
          }
        }),
      );
    }
    if (incoming.processingState != ProcessingState.ready) {
      _fadeProgress = 0;
      _updateFadeVolumes();
      return;
    }
    _fadeProgress = (1 - remaining.inMilliseconds / fade.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    _updateFadeVolumes();
  }

  void _updateFadeVolumes() {
    _setPlayerVolume(player, _appVolume * _currentGain * (1 - _fadeProgress));
    final incoming = _incoming;
    if (incoming != null) {
      _setPlayerVolume(incoming, _appVolume * _incomingGain * _fadeProgress);
    }
  }

  Future<void> _prepareCrossfade(int entry, Track track, Duration fade) async {
    AudioPlayer? incoming;
    try {
      incoming = _createCrossfadePlayer();
      _incoming = incoming;
      _incomingEntry = entry;
      await incoming.setVolume(0);
      final gain = await _gainFor(track);
      if (_incoming != incoming) return;
      _incomingGain = gain;
      if (!identical(_incoming, incoming)) return;
      final duration = await incoming
          .setAudioSources([_sourceFor(track)])
          .timeout(const Duration(seconds: 10));
      if (!identical(_incoming, incoming)) return;
      if (duration != null && duration > fade * 2) {
        if (_incoming != incoming) return;
        _incomingReady = true;
        return;
      }
    } catch (error) {
      if (!identical(_incoming, incoming)) return;
      recordEvent('Preparación del fundido fallida: ${error.runtimeType}');
    }
    _failedCrossfadeEntry = entry;
    _cancelCrossfade();
  }

  IndexedAudioSource _sourceFor(Track track) => AudioSource.uri(
    track.id.startsWith('content://')
        ? Uri.parse(track.id)
        : Uri.file(track.id),
  );

  bool _finishCrossfade() {
    final incoming = _incoming;
    if (!_canCrossfade ||
        incoming == null ||
        !_incomingStarted ||
        incoming.processingState != ProcessingState.ready ||
        !incoming.playing ||
        incoming.position == Duration.zero ||
        _incomingEntry != _entries[index + 1]) {
      _cancelCrossfade();
      return false;
    }
    final outgoing = player;
    _incoming = null;
    _incomingEntry = null;
    _incomingReady = false;
    _incomingStarted = false;
    _failedCrossfadeEntry = null;
    _fadeProgress = 0;
    _player = incoming;
    _nativeQueue = _supportsNativeQueue;
    _nativeCursor = 0;
    _preparedEntry = null;
    _currentGain = _incomingGain;
    if (_loadedEntry case final entry?) {
      _previousTracks.add(entry);
      if (_previousTracks.length > 300) _previousTracks.removeAt(0);
    }
    index++;
    _loadedEntry = _entries[index];
    _forwardTracks.clear();
    final track = tracks[index];
    final generation = ++_generation;
    mediaItem.add(_mediaItem(track).copyWith(duration: player.duration));
    _observePlayer();
    _setPlayerVolume(player, _appVolume * _currentGain);
    unawaited(outgoing.dispose().catchError((Object _) {}));
    unawaited(_loadArtwork(track, generation));
    _publish();
    unawaited(saveSession());
    _refreshNativeQueue();
    return true;
  }

  final Future<void> Function()? onEmptyPlay;
  final Future<Uri?> Function(String)? artworkLoader;
  final LocalStore? sessionStore;
  Timer? _checkpointTimer;
  Timer? _seekCheckpoint;
  bool _closed = false;
  bool _shuttingDown = false;
  Future<void>? _closing;
  String? lastSystemError;
  String? lastPlaybackError;
  void _recordPlaybackError(Object error) {
    final text = error is PlayerException
        ? 'Motor ${error.code}: ${error.message ?? 'sin detalle'}'
        : '${error.runtimeType}: $error';
    final redacted = text.replaceAll(
      RegExp(r'(?:https?|file)://[^\s]+'),
      '<origen>',
    );
    lastPlaybackError = redacted.substring(0, redacted.length.clamp(0, 500));
    recordEvent('Error de audio: $lastPlaybackError');
  }

  final List<String> diagnosticEvents = [];
  String _lastState = '';
  void recordEvent(String text) {
    diagnosticEvents.add('${DateTime.now().toUtc().toIso8601String()} $text');
    if (diagnosticEvents.length > 100) diagnosticEvents.removeAt(0);
  }

  final errors = StreamController<String>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  Future<void> _operations = Future.value();
  int _generation = 0;
  bool _loading = false;
  final bool _serializeNativeLoads;
  Completer<Duration?>? _pendingLoadFailure;
  void _interruptPendingLoad() {
    final pending = _pendingLoadFailure;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(
        PlayerInterruptedException('Carga cancelada o sustituida.'),
      );
    }
  }

  void _handlePlaybackError(Object error) {
    _recordPlaybackError(error);
    final pending = _pendingLoadFailure;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(error);
    } else if (!_loading) {
      errors.add(
        'El motor de audio no pudo continuar. Consulta el diagnóstico en Ajustes.',
      );
    }
  }

  bool _playIntent = false;
  bool _queueEnded = false;
  bool get queueEnded => _queueEnded;

  void _setQueueEnded(bool value) {
    if (_queueEnded == value) return;
    _queueEnded = value;
    _states.add(player.playerState);
  }

  List<Track> tracks = [];
  int index = -1;
  final List<int> _previousTracks = [], _forwardTracks = [];
  int? _loadedEntry;
  bool _shuffle = false;
  bool get shuffle => _shuffle;
  set shuffle(bool value) {
    if (value == _shuffle) return;
    _shuffle = value;
    _arrangePending();
    _queueChanged();
  }

  int _nextEntry = 0;
  List<int> _entries = [];
  final List<int> _originalOrder = [];
  final Set<int> _playNext = {};
  int queueEntryAt(int position) => _entries[position];
  Iterable<Track> get playbackHistory sync* {
    for (final entry in _previousTracks.reversed) {
      final position = _entries.indexOf(entry);
      if (position >= 0) yield tracks[position];
    }
  }

  void _arrangePending() {
    final start = index + 1;
    if (start >= tracks.length) return;
    final pending = {
      for (var i = start; i < tracks.length; i++) _entries[i]: tracks[i],
    };
    final regular = _originalOrder
        .where((id) => pending.containsKey(id) && !_playNext.contains(id))
        .toList();
    if (_shuffle) regular.shuffle();
    _replacePending([
      ..._entries.skip(start).where(_playNext.contains),
      ...regular,
    ], pending);
  }

  void _replacePending(List<int> order, Map<int, Track> pending) {
    final start = index + 1;
    tracks = List.unmodifiable([
      ...tracks.take(start),
      ...order.map((id) => pending[id]!),
    ]);
    _entries = [..._entries.take(start), ...order];
  }

  void _queueChanged() {
    if (_incomingEntry != null &&
        (index + 1 >= _entries.length ||
            _incomingEntry != _entries[index + 1])) {
      _cancelCrossfade();
    }
    queue.add(tracks.map(_mediaItem).toList());
    _refreshNativeQueue();
    _publish();
    unawaited(saveSession());
  }

  VoidCallback? enqueue(List<Track> additions, {bool next = false}) {
    if (_shuttingDown || additions.isEmpty) return null;
    final position = next ? index + 1 : tracks.length;
    final newEntries = [for (final _ in additions) _nextEntry++];
    tracks = List.unmodifiable([
      ...tracks.take(position),
      ...additions,
      ...tracks.skip(position),
    ]);
    _entries.insertAll(position, newEntries);
    if (next) {
      _playNext.addAll(newEntries);
      final following = position + newEntries.length;
      final target = following < _entries.length
          ? _originalOrder.indexOf(_entries[following])
          : _originalOrder.length;
      _originalOrder.insertAll(target, newEntries);
    } else {
      _originalOrder.addAll(newEntries);
    }
    _forwardTracks.clear();
    _queueChanged();
    final session = _queueGeneration;
    return () {
      if (_queueGeneration != session || _shuttingDown) return;
      final added = newEntries.toSet();
      final removed = _entries.skip(index + 1).where(added.contains).toSet();
      _discardPending(removed);
    };
  }

  void movePending(int entry, int position) {
    final from = _entries.indexOf(entry);
    if (from <= index ||
        from < 0 ||
        position <= index ||
        position >= tracks.length) {
      return;
    }
    final updated = tracks.toList();
    final track = updated.removeAt(from);
    updated.insert(position, track);
    tracks = List.unmodifiable(updated);
    _entries.removeAt(from);
    _entries.insert(position, entry);
    _playNext.remove(entry);
    _originalOrder.remove(entry);
    final next = position + 1;
    _originalOrder.insert(
      next < _entries.length
          ? _originalOrder.indexOf(_entries[next])
          : _originalOrder.length,
      entry,
    );
    _forwardTracks.clear();
    _queueChanged();
  }

  void movePendingRelative(int entry, int anchor, {bool after = false}) {
    final from = _entries.indexOf(entry);
    final to = _entries.indexOf(anchor);
    if (from <= index || to <= index || from < 0 || to < 0 || entry == anchor) {
      return;
    }
    movePending(entry, to + (after ? 1 : 0) - (from < to ? 1 : 0));
  }

  Future<void> playQueueEntry(int entry) =>
      skipToQueueItem(_entries.indexOf(entry));

  void movePendingNext(int entry) {
    if (_entries.indexOf(entry) <= index || !_entries.contains(entry)) return;
    movePending(entry, index + 1);
    _playNext.add(entry);
    _queueChanged();
  }

  void Function()? removePending(int entry) {
    final position = _entries.indexOf(entry);
    if (position <= index || position < 0) return null;
    final track = tracks[position];
    final successor = position + 1 < _entries.length
        ? _entries[position + 1]
        : null;
    final wasNext = _playNext.remove(entry);
    final originalPosition = _originalOrder.indexOf(entry);
    final session = _queueGeneration;
    tracks = List.unmodifiable(tracks.toList()..removeAt(position));
    _entries.removeAt(position);
    _originalOrder.remove(entry);
    _forwardTracks.clear();
    _queueChanged();
    return () {
      if (_queueGeneration != session ||
          _entries.contains(entry) ||
          _shuttingDown) {
        return;
      }
      final successorPosition = successor == null
          ? -1
          : _entries.indexOf(successor);
      final target = successorPosition > index
          ? successorPosition
          : position.clamp(index + 1, tracks.length);
      tracks = List.unmodifiable(tracks.toList()..insert(target, track));
      _entries.insert(target, entry);
      _originalOrder.insert(
        originalPosition.clamp(0, _originalOrder.length),
        entry,
      );
      if (wasNext) _playNext.add(entry);
      _queueChanged();
    };
  }

  void shufflePending() {
    final start = index + 1;
    if (_shuttingDown || tracks.length - start < 2) return;
    final pending = {
      for (var i = start; i < tracks.length; i++) _entries[i]: tracks[i],
    };
    final order = pending.keys.toList()..shuffle();
    if (order.indexed.every((item) => item.$2 == _entries[start + item.$1])) {
      order.add(order.removeAt(0));
    }
    _originalOrder
      ..removeWhere(pending.containsKey)
      ..addAll(order);
    _playNext.removeAll(order);
    _forwardTracks.clear();
    _replacePending(order, pending);
    _queueChanged();
  }

  void clearPending() {
    _queueGeneration++;
    _discardPending(_entries.skip(index + 1).toSet());
  }

  void _discardPending(Set<int> removed) {
    if (removed.isEmpty) return;
    tracks = List.unmodifiable([
      for (var i = 0; i < tracks.length; i++)
        if (!removed.contains(_entries[i])) tracks[i],
    ]);
    _entries.removeWhere(removed.contains);
    _originalOrder.removeWhere(removed.contains);
    _playNext.removeAll(removed);
    _forwardTracks.clear();
    _queueChanged();
  }

  int _queueGeneration = 0;
  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;
  AudioServiceRepeatMode get repeatMode => _repeatMode;
  bool get repeat => _repeatMode == AudioServiceRepeatMode.one;
  set repeat(bool value) {
    _setRepeatMode(
      value ? AudioServiceRepeatMode.one : AudioServiceRepeatMode.none,
    );
  }

  void _setRepeatMode(AudioServiceRepeatMode mode) {
    _repeatMode = mode == AudioServiceRepeatMode.group
        ? AudioServiceRepeatMode.all
        : mode;
    _refreshNativeQueue();
    _publish();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _setRepeatMode(repeatMode);
    await saveSession();
  }

  MusicHandler({
    AudioPlayer? player,
    this.sessionStore,
    this.artworkLoader,
    this.replayGainLoader,
    this.onEmptyPlay,
    bool? serializeNativeLoads,
    bool? supportsNativeQueue,
    AudioPlayer Function()? crossfadePlayerFactory,
  }) : _supportsNativeQueue = supportsNativeQueue ?? player == null,
       _serializeNativeLoads = serializeNativeLoads ?? Platform.isAndroid,
       _createCrossfadePlayer =
           crossfadePlayerFactory ?? createNativeAudioPlayer,
       _player = player ?? createNativeAudioPlayer() {
    if (sessionStore != null) {
      _checkpointTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (this.player.playing && !_loading) unawaited(saveSession());
      });
    }
    _appVolume = this.player.volume;
    _observePlayer();
  }

  void _observePlayer() {
    for (final subscription in _playerSubscriptions) {
      unawaited(subscription.cancel());
    }
    _playerSubscriptions
      ..clear()
      ..add(player.positionStream.listen(_positions.add))
      ..add(player.durationStream.listen(_durations.add))
      ..add(
        player.playerStateStream.listen((state) {
          _states.add(state);
          if (!state.playing) _cancelCrossfade();
          _refreshCrossfadeTimer();
          _publish();
        }),
      )
      ..add(
        player.playbackEventStream.listen(
          (_) => _publish(),
          onError: _handlePlaybackError,
        ),
      )
      ..add(player.errorStream.listen(_handlePlaybackError))
      ..add(
        player.processingStateStream.listen((state) {
          if (state == ProcessingState.completed && !_loading) {
            if (!_finishCrossfade()) unawaited(_advance());
          }
        }),
      );
    if (_supportsNativeQueue) {
      _playerSubscriptions.add(
        player.currentIndexStream.listen(_onNativeIndex),
      );
    }
  }

  // Keep only the next source ahead of the native playback cursor, so queue
  // edits do not have to reload the track that is currently playing.
  void _refreshNativeQueue() {
    if (!_nativeQueue || _loading || _shuttingDown) return;
    if (_updatingNativeQueue) {
      _nativeQueueDirty = true;
      return;
    }
    final target = gapless && !repeat && index >= 0 && index + 1 < tracks.length
        ? _entries[index + 1]
        : null;
    if (_preparedEntry == target) return;
    final active = player;
    final generation = _generation;
    final cursor = active.currentIndex ?? 0;
    final next = target == null ? null : tracks[index + 1];
    _updatingNativeQueue = true;
    final operation = _operations.then((_) async {
      if (_generation != generation || !_nativeQueue || _shuttingDown) return;
      if (active.audioSources.length > cursor + 1) {
        await active.removeAudioSourceAt(cursor + 1);
      }
      _preparedEntry = null;
      if (next != null && _generation == generation && !_shuttingDown) {
        _preparedEntry = target;
        await active.addAudioSource(_sourceFor(next));
        if (replayGainMode != ReplayGainMode.off) unawaited(_gainFor(next));
      }
    });
    _operations = operation
        .then<void>(
          (_) {},
          onError: (Object error) {
            _preparedEntry = null;
            recordEvent(
              'No se pudo preparar la siguiente pista: ${error.runtimeType}',
            );
          },
        )
        .whenComplete(() {
          _updatingNativeQueue = false;
          if (_nativeQueueDirty) {
            _nativeQueueDirty = false;
            _refreshNativeQueue();
          }
        });
  }

  void _onNativeIndex(int? cursor) {
    final prepared = _preparedEntry;
    if (_loading ||
        !_nativeQueue ||
        _shuttingDown ||
        cursor == null ||
        cursor == 0 ||
        prepared == null ||
        cursor == _nativeCursor) {
      return;
    }
    _nativeCursor = cursor;
    _preparedEntry = null;
    if (!gapless ||
        repeat ||
        index + 1 >= _entries.length ||
        _entries[index + 1] != prepared) {
      if (index + 1 >= _entries.length && !repeat) {
        unawaited(select(tracks, index, autoplay: false, preserveQueue: true));
      } else {
        unawaited(
          select(tracks, repeat ? index : index + 1, preserveQueue: true),
        );
      }
      return;
    }
    if (_finishCrossfade()) return;
    if (_loadedEntry case final entry?) {
      _previousTracks.add(entry);
      if (_previousTracks.length > 300) _previousTracks.removeAt(0);
    }
    index++;
    _loadedEntry = prepared;
    _forwardTracks.clear();
    final track = tracks[index];
    final generation = ++_generation;
    mediaItem.add(_mediaItem(track).copyWith(duration: player.duration));
    _currentGain = 1;
    _updateFadeVolumes();
    unawaited(_refreshReplayGain(track, generation));
    unawaited(_loadArtwork(track, generation));
    _publish();
    unawaited(saveSession());
    _refreshNativeQueue();
  }

  Future<void> _refreshReplayGain(Track track, int generation) async {
    final mode = replayGainMode;
    final gain = await _gainFor(track);
    if (!_shuttingDown && generation == _generation && mode == replayGainMode) {
      _currentGain = gain;
      _updateFadeVolumes();
    }
  }

  int _nativeCursor = 0;

  void observeSystemErrors(Stream<Object> source) {
    _subscriptions.add(
      source.listen((error) {
        final message = error.toString();
        if (message.contains('startForeground') ||
            message.contains('ForegroundServiceStartNotAllowed')) {
          _playIntent = false;
          unawaited(player.pause().catchError((Object _) {}));
        }
        if (lastSystemError == message) return;
        lastSystemError = message;
        recordEvent('Error del servicio: $lastSystemError');
        errors.add(
          'Android no pudo actualizar los controles multimedia. Consulta el diagnóstico en Ajustes.',
        );
      }),
    );
  }

  MediaItem _mediaItem(Track track) => MediaItem(
    id: track.id,
    title: track.title,
    artist: track.artist,
    album: track.album,
    extras: {
      'sourceName': track.sourceName ?? 'Audio local',
      if (track.sourceId != null) 'sourceId': track.sourceId,
    },
    duration: track.durationMs > 0
        ? Duration(milliseconds: track.durationMs)
        : null,
  );

  Future<void> configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _publish() {
    final state =
        '${player.processingState.name}/${player.playing}/carga=$_loading/índice=$index';
    if (state != _lastState) {
      recordEvent('Audio: $state');
      _lastState = state;
    }
    playbackState.add(
      PlaybackState(
        controls: [
          const MediaControl(
            androidIcon: 'drawable/rp_previous',
            label: 'Anterior',
            action: MediaAction.skipToPrevious,
          ),
          player.playing
              ? const MediaControl(
                  androidIcon: 'drawable/rp_pause',
                  label: 'Pausar',
                  action: MediaAction.pause,
                )
              : const MediaControl(
                  androidIcon: 'drawable/rp_play',
                  label: 'Reproducir',
                  action: MediaAction.play,
                ),
          const MediaControl(
            androidIcon: 'drawable/rp_next',
            label: 'Siguiente',
            action: MediaAction.skipToNext,
          ),
          const MediaControl(
            androidIcon: 'drawable/rp_stop',
            label: 'Detener',
            action: MediaAction.stop,
          ),
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.playPause,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        queueIndex: index >= 0 ? index : null,
        repeatMode: repeatMode,
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _loading
            ? AudioProcessingState.loading
            : switch (player.processingState) {
                ProcessingState.idle => AudioProcessingState.idle,
                ProcessingState.loading => AudioProcessingState.loading,
                ProcessingState.buffering => AudioProcessingState.buffering,
                ProcessingState.ready => AudioProcessingState.ready,
                ProcessingState.completed => AudioProcessingState.completed,
              },
        playing: player.playing || (_loading && _playIntent),
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
      ),
    );
  }

  Future<void> select(
    List<Track> source,
    int selected, {
    bool autoplay = true,
    Duration initialPosition = Duration.zero,
    bool recordHistory = true,
    bool preserveQueue = false,
    bool continueOnError = false,
  }) {
    if (_shuttingDown) return Future.value();
    if (selected < 0 || selected >= source.length) return Future.value();
    _setQueueEnded(false);
    _cancelCrossfade();
    _failedCrossfadeEntry = null;
    final sameQueue =
        preserveQueue ||
        (source.length == tracks.length &&
            Iterable<int>.generate(source.length)
                .every((i) => source[i].id == tracks[i].id));
    if (sameQueue && !preserveQueue) tracks = List.unmodifiable(source);
    if (!sameQueue) {
      _queueGeneration++;
      _previousTracks.clear();
      _forwardTracks.clear();
      _loadedEntry = null;
      tracks = List.unmodifiable(source);
      _entries = [for (final _ in source) _nextEntry++];
      _originalOrder
        ..clear()
        ..addAll(_entries);
      _playNext.clear();
    }
    index = selected;
    if (!sameQueue && shuffle) {
      final pending = {
        for (var i = 0; i < tracks.length; i++)
          if (i != selected) _entries[i]: tracks[i],
      };
      final order = pending.keys.toList()..shuffle();
      tracks = List.unmodifiable([
        tracks[selected],
        ...order.map((id) => pending[id]!),
      ]);
      _entries = [_entries[selected], ...order];
      index = 0;
    }
    final track = tracks[index];
    final entry = _entries[index];
    recordEvent(
      'Selección de pista: $selected/${tracks.length}; autoplay=$autoplay',
    );
    final generation = ++_generation;
    _nativeQueue = false;
    _nativeCursor = 0;
    _preparedEntry = null;
    if (!_serializeNativeLoads) _interruptPendingLoad();
    _loading = true;
    _playIntent = autoplay;
    final operation = _operations.then((_) async {
      if (generation != _generation) return;
      await player.pause();
      if (generation != _generation) return;
      final nextQueue = tracks.map(_mediaItem).toList();
      final previousQueue = queue.value;
      if (previousQueue.length != nextQueue.length ||
          Iterable<int>.generate(nextQueue.length)
              .any((i) => previousQueue[i] != nextQueue[i])) {
        queue.add(nextQueue);
      }
      mediaItem.add(_mediaItem(track));
      unawaited(_loadArtwork(track, generation));
      try {
        final loadWatch = Stopwatch()..start();
        final failure = Completer<Duration?>();
        if (!_serializeNativeLoads) _pendingLoadFailure = failure;
        Duration? duration;
        try {
          // Android emits an unscoped error when a native load is aborted.
          // Let the current load settle before starting its replacement.
          _currentGain = await _gainFor(track);
          if (generation != _generation) return;
          _setPlayerVolume(player, _appVolume * _currentGain);
          final nativeLoad = _supportsNativeQueue
              ? player.setAudioSources([
                  _sourceFor(track),
                ], initialPosition: initialPosition)
              : player.setAudioSource(
                  _sourceFor(track),
                  initialPosition: initialPosition,
                );
          final loading = _serializeNativeLoads
              ? nativeLoad
              : Future.any<Duration?>([nativeLoad, failure.future]);
          duration = await (Platform.isWindows
              ? loading.timeout(const Duration(seconds: 30))
              : loading);
        } finally {
          if (identical(_pendingLoadFailure, failure)) {
            _pendingLoadFailure = null;
          }
        }
        recordEvent(
          'Carga del motor de audio: ${loadWatch.elapsedMilliseconds} ms',
        );
        if (generation == _generation) await _migrateAndroidEqualizer(player);
        if (generation == _generation && !_shuttingDown) {
          if (recordHistory && _loadedEntry != null && _loadedEntry != entry) {
            _previousTracks.add(_loadedEntry!);
            if (_previousTracks.length > 300) _previousTracks.removeAt(0);
            _forwardTracks.clear();
          }
          _loadedEntry = entry;
          _loading = false;
          _nativeQueue = _supportsNativeQueue;
          _refreshNativeQueue();
          if (duration != null) {
            mediaItem.add(mediaItem.value!.copyWith(duration: duration));
          }
          _publish();
          unawaited(saveSession(position: initialPosition));
          if (_playIntent) unawaited(play());
        }
      } catch (error) {
        if (generation == _generation && !_shuttingDown) {
          _recordPlaybackError(error);
          _loading = false;
          _playIntent = false;
          await player.stop();
          recordEvent('Error al cargar pista: índice=$index');
          errors.add(
            'El motor de audio no pudo cargar «${track.title}». Consulta el diagnóstico en Ajustes.',
          );
          if (continueOnError && index + 1 < tracks.length) {
            unawaited(skipToNext());
          }
        }
      }
    });
    _operations = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _loadArtwork(Track track, int generation) async {
    try {
      final uri = await artworkLoader?.call(track.id);
      if (uri != null && generation == _generation && !_shuttingDown) {
        mediaItem.add(mediaItem.value!.copyWith(artUri: uri));
      }
    } catch (_) {
      /* Artwork failure must not interrupt playback. */
    }
  }

  Future<void> removeTrack(String id) async {
    _queueGeneration++;
    final current = index >= 0 ? tracks[index].id : null;
    final currentEntry = index >= 0 ? _entries[index] : null;
    final removed = {
      for (var i = 0; i < tracks.length; i++)
        if (tracks[i].id == id) _entries[i],
    };
    _previousTracks.removeWhere(removed.contains);
    _forwardTracks.removeWhere(removed.contains);
    if (removed.contains(_incomingEntry)) _cancelCrossfade();
    if (removed.contains(_loadedEntry)) _loadedEntry = null;
    final remaining = tracks.where((t) => t.id != id).toList();
    if (current == id) {
      await stop();
      tracks = remaining;
      _entries.removeWhere(removed.contains);
      _originalOrder.removeWhere(removed.contains);
      _playNext.removeAll(removed);
      index = -1;
      mediaItem.add(null);
      queue.add(remaining.map(_mediaItem).toList());
      await sessionStore?.save({
        'schema': 1,
        'ids': <String>[],
        'current': null,
      });
    } else {
      tracks = remaining;
      _entries.removeWhere(removed.contains);
      _originalOrder.removeWhere(removed.contains);
      _playNext.removeAll(removed);
      index = _entries.indexOf(currentEntry ?? -1);
      _queueChanged();
      await saveSession();
    }
  }

  Future<void> _advance() async {
    if (_shuttingDown || !_playIntent || index < 0 || _queueEnded) return;
    if (repeat && index >= 0) {
      await seek(Duration.zero);
      unawaited(play());
      return;
    }
    if (index + 1 < tracks.length) {
      await skipToNext();
    } else if (repeatMode == AudioServiceRepeatMode.all) {
      await restartQueue();
    } else {
      _setQueueEnded(true);
      await pause();
    }
  }

  Future<void> restartQueue() {
    if (_shuttingDown || tracks.isEmpty) return Future.value();
    if (shuffle && tracks.length > 1) {
      final lastId = index >= 0 ? tracks[index].id : null;
      final order = List<int>.generate(tracks.length, (i) => i)..shuffle();
      final alternative = order.indexWhere((i) => tracks[i].id != lastId);
      if (alternative > 0) order.insert(0, order.removeAt(alternative));
      tracks = List.unmodifiable(order.map((i) => tracks[i]));
      _entries = order.map((i) => _entries[i]).toList();
    }
    _playNext.clear();
    _previousTracks.clear();
    _forwardTracks.clear();
    _loadedEntry = null;
    return select(tracks, 0, preserveQueue: true, recordHistory: false);
  }

  @override
  Future<void> play() async {
    if (_shuttingDown) return;
    if (queueEnded) {
      await restartQueue();
      return;
    }
    if (index < 0) {
      if (tracks.isNotEmpty) {
        await select(tracks, 0, preserveQueue: true);
        return;
      }
      await onEmptyPlay?.call();
    }
    if (_shuttingDown || index < 0) return;
    _playIntent = true;
    if (_loading) return;
    try {
      final playback = player.play();
      _publish();
      await playback;
    } catch (error) {
      _recordPlaybackError(error);
      errors.add('No se pudo iniciar el audio.');
    }
  }

  @override
  Future<void> pause() {
    _playIntent = false;
    _cancelCrossfade();
    recordEvent('Pausa solicitada');
    return player.pause().then((_) {
      _publish();
      return saveSession();
    });
  }

  @override
  Future<void> seek(Duration position) async {
    _setQueueEnded(false);
    _cancelCrossfade();
    await player.seek(position);
    if (sessionStore != null) {
      _seekCheckpoint?.cancel();
      _seekCheckpoint = Timer(
        const Duration(milliseconds: 350),
        () => unawaited(saveSession()),
      );
    }
  }

  Future<void> saveSession({Duration? position}) async {
    if (_closed || sessionStore == null || index >= tracks.length || _loading) {
      return;
    }
    final snapshot = <String, dynamic>{
      'schema': 1,
      'ids': tracks.map((t) => t.id).toList(),
      'current': index < 0 ? null : tracks[index].id,
      'currentEntry': index < 0 ? null : _entries[index],
      'entries': List<int>.of(_entries),
      'originalOrder': List<int>.of(_originalOrder),
      'playNext': _playNext.toList(),
      'positionMs': (position ?? player.position).inMilliseconds,
      'shuffle': shuffle,
      'repeat': repeat,
      'repeatMode': repeatMode.name,
      'queueEnded': queueEnded,
      'previous': List<int>.of(_previousTracks),
      'forward': List<int>.of(_forwardTracks),
    };
    try {
      await sessionStore!.save(snapshot);
    } catch (_) {
      if (!_closed) errors.add('No se pudo guardar la sesión de reproducción.');
    }
  }

  Future<void> restoreSession(List<Track> library) async {
    if (sessionStore == null || _generation != 0) return;
    try {
      final saved = await sessionStore!.load();
      if (saved['schema'] != 1 || _generation != 0 || _entries.isNotEmpty) {
        return;
      }
      final byId = {for (final t in library) t.id: t};
      final ids = saved['ids'] as List;
      final stored = saved['entries'];
      final entries =
          stored is List &&
              stored.length == ids.length &&
              stored.every((id) => id is int) &&
              stored.toSet().length == ids.length
          ? stored.cast<int>()
          : List<int>.generate(ids.length, (i) => i);
      final availableEntries = {
        for (var i = 0; i < ids.length; i++) entries[i]: ?byId[ids[i]],
      };
      final restored = availableEntries.values.toList();
      final currentEntry = saved['currentEntry'];
      final selected = currentEntry is int
          ? availableEntries.keys.toList().indexOf(currentEntry)
          : restored.indexWhere((t) => t.id == saved['current']);
      if (restored.isEmpty) return;
      _shuffle = saved['shuffle'] as bool? ?? false;
      _setRepeatMode(
        AudioServiceRepeatMode.values.firstWhere(
          (mode) => mode.name == saved['repeatMode'],
          orElse: () => saved['repeat'] == true
              ? AudioServiceRepeatMode.one
              : AudioServiceRepeatMode.none,
        ),
      );
      tracks = List.unmodifiable(restored);
      _entries = availableEntries.keys.toList();
      _nextEntry = _entries.reduce(max) + 1;
      final order = saved['originalOrder'];
      _originalOrder.addAll({
        if (order is List)
          ...order.whereType<int>().where(availableEntries.containsKey),
        ..._entries,
      });
      final pinned = saved['playNext'];
      if (pinned is List) {
        _playNext.addAll(
          pinned.whereType<int>().where(availableEntries.containsKey),
        );
      }
      if (stored == null && shuffle) {
        index = selected;
        _arrangePending();
      }
      if (selected < 0) {
        _queueChanged();
        return;
      }
      var position = (saved['positionMs'] as num?)?.toInt() ?? 0;
      if (position < 0) position = 0;
      final duration = restored[selected].durationMs;
      if (duration > 0 && position >= duration) position = 0;
      final restoreGeneration = _generation + 1;
      await select(
        tracks,
        selected,
        preserveQueue: true,
        autoplay: false,
        initialPosition: Duration(milliseconds: position),
        recordHistory: false,
      );
      if (_generation != restoreGeneration || _shuttingDown) return;
      _setQueueEnded(saved['queueEnded'] == true);
      for (final pair in [
        (saved['previous'], _previousTracks),
        (saved['forward'], _forwardTracks),
      ]) {
        if (pair.$1 case final List history) {
          for (final value in history.take(300)) {
            if (value is int && availableEntries.containsKey(value)) {
              pair.$2.add(value);
            } else if (value is String) {
              final position = restored.indexWhere(
                (track) => track.id == value,
              );
              if (position >= 0) pair.$2.add(_entries[position]);
            }
          }
        }
      }
      await saveSession();
    } catch (_) {
      errors.add('No se pudo recuperar la última sesión.');
    }
  }

  @override
  Future<void> stop() async {
    _setQueueEnded(false);
    _cancelCrossfade();
    ++_generation;
    _nativeQueue = false;
    _interruptPendingLoad();
    _playIntent = false;
    _loading = false;
    await player.pause();
    await saveSession();
    await player.stop();
    _publish();
    await super.stop();
  }

  @override
  Future<void> skipToQueueItem(int index) => select(tracks, index);

  @override
  Future<void> skipToNext() async {
    if (tracks.isEmpty) return;
    while (_forwardTracks.isNotEmpty) {
      final id = _forwardTracks.removeLast();
      final target = _entries.indexOf(id);
      if (target < 0 || target != index + 1) continue;
      if (_loadedEntry case final entry?) _previousTracks.add(entry);
      await select(tracks, target, recordHistory: false);
      return;
    }
    if (index + 1 >= tracks.length) {
      if (repeatMode == AudioServiceRepeatMode.all) await restartQueue();
      return;
    }
    await select(tracks, index + 1, preserveQueue: true, continueOnError: true);
  }

  @override
  Future<void> skipToPrevious() async {
    if (tracks.isEmpty) return;
    while (_previousTracks.isNotEmpty) {
      final id = _previousTracks.removeLast();
      final target = _entries.indexOf(id);
      if (target < 0) continue;
      if (_loadedEntry case final entry?) {
        _forwardTracks.add(entry);
        final current = _entries.indexOf(entry);
        if (current >= 0 && current != target + 1) {
          final reordered = tracks.toList();
          final track = reordered.removeAt(current);
          _entries.removeAt(current);
          final destination = _entries.indexOf(id) + 1;
          reordered.insert(destination, track);
          _entries.insert(destination, entry);
          tracks = List.unmodifiable(reordered);
        }
      }
      await select(tracks, _entries.indexOf(id), recordHistory: false);
      return;
    }
    await select(
      tracks,
      (index - 1 + tracks.length) % tracks.length,
      recordHistory: false,
    );
  }

  Future<void> setAppVolume(double value) async {
    _appVolume = value.clamp(0.0, 1.0);
    _volumes.add(_appVolume);
    _updateFadeVolumes();
  }

  Timer? _sleepTimer;
  DateTime? _sleepDeadline;

  Duration? get sleepTimerRemaining =>
      _sleepDeadline?.difference(DateTime.now());

  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepDeadline = null;
    if (duration == null || duration <= Duration.zero || _shuttingDown) return;
    _sleepDeadline = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () {
      _sleepDeadline = null;
      _sleepTimer = null;
      unawaited(pause());
    });
  }

  Future<void> close() => _closing ??= _closeInternal();

  Future<void> _closeInternal() async {
    _shuttingDown = true;
    setSleepTimer(null);
    _crossfadeTimer?.cancel();
    _cancelCrossfade();
    _checkpointTimer?.cancel();
    _seekCheckpoint?.cancel();
    ++_generation;
    _playIntent = false;
    _interruptPendingLoad();
    // Silence first; saving state and native disposal happen after sound stops.
    await player.setVolume(0);
    await player.pause();
    await saveSession();
    await player.stop();
    if (_loading || _updatingNativeQueue) await _operations;
    _closed = true;
    for (final subscription in [..._subscriptions, ..._playerSubscriptions]) {
      // Cancellation stops delivery immediately; do not wait on UI stream clocks.
      unawaited(subscription.cancel());
    }
    await player.dispose();
    unawaited(_positions.close());
    unawaited(_durations.close());
    unawaited(_states.close());
    unawaited(_volumes.close());
    // Error observers must not hold the native player/window open on exit.
    unawaited(errors.close());
  }
}
