import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

import '../domain/track.dart';
import '../data/local_store.dart';
import 'native_audio_player.dart';

class MusicHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player;
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
    queue.add(tracks.map(_mediaItem).toList());
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
  bool repeat = false;
  MusicHandler({
    AudioPlayer? player,
    this.sessionStore,
    this.artworkLoader,
    this.onEmptyPlay,
    bool? serializeNativeLoads,
  }) : _serializeNativeLoads = serializeNativeLoads ?? Platform.isAndroid,
       player = player ?? createNativeAudioPlayer() {
    if (sessionStore != null) {
      _checkpointTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (this.player.playing && !_loading) unawaited(saveSession());
      });
    }
    _subscriptions.add(this.player.playerStateStream.listen((_) => _publish()));
    _subscriptions.add(
      this.player.playbackEventStream.listen(
        (_) => _publish(),
        onError: _handlePlaybackError,
      ),
    );
    _subscriptions.add(this.player.errorStream.listen(_handlePlaybackError));
    _subscriptions.add(
      this.player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed && !_loading) {
          unawaited(_advance());
        }
      }),
    );
  }
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
          final nativeLoad = player.setAudioSource(
            AudioSource.uri(
              track.id.startsWith('content://')
                  ? Uri.parse(track.id)
                  : Uri.file(track.id),
            ),
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
        if (generation == _generation && !_shuttingDown) {
          if (recordHistory && _loadedEntry != null && _loadedEntry != entry) {
            _previousTracks.add(_loadedEntry!);
            if (_previousTracks.length > 300) _previousTracks.removeAt(0);
            _forwardTracks.clear();
          }
          _loadedEntry = entry;
          _loading = false;
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
      queue.add(tracks.map(_mediaItem).toList());
      _publish();
      await saveSession();
    }
  }

  Future<void> _advance() async {
    if (repeat && index >= 0) {
      await seek(Duration.zero);
      unawaited(play());
      return;
    }
    if (index + 1 < tracks.length) {
      await skipToNext();
    } else {
      await pause();
      await seek(Duration.zero);
    }
  }

  @override
  Future<void> play() async {
    if (_shuttingDown) return;
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
    recordEvent('Pausa solicitada');
    return player.pause().then((_) {
      _publish();
      return saveSession();
    });
  }

  @override
  Future<void> seek(Duration position) async {
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
      repeat = saved['repeat'] as bool? ?? false;
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
      await select(
        tracks,
        selected,
        preserveQueue: true,
        autoplay: false,
        initialPosition: Duration(milliseconds: position),
        recordHistory: false,
      );
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
    ++_generation;
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
    if (index + 1 >= tracks.length) return;
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

  Future<void> setAppVolume(double value) =>
      player.setVolume(value.clamp(0.0, 1.0));

  Future<void> close() => _closing ??= _closeInternal();

  Future<void> _closeInternal() async {
    _shuttingDown = true;
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
    if (_loading) await _operations;
    _closed = true;
    for (final subscription in _subscriptions) {
      // Cancellation stops delivery immediately; do not wait on UI stream clocks.
      unawaited(subscription.cancel());
    }
    await player.dispose();
    // Error observers must not hold the native player/window open on exit.
    unawaited(errors.close());
  }
}
