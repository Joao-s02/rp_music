import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/track.dart';
import '../data/local_store.dart';

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
  bool _playIntent = false;
  List<Track> tracks = [];
  int index = -1;
  Future<int?> Function(List<Track>, int)? chooseNext;
  bool shuffle = false;
  bool repeat = false;
  MusicHandler({
    AudioPlayer? player,
    this.sessionStore,
    this.artworkLoader,
    this.onEmptyPlay,
  }) : player = player ?? AudioPlayer() {
    if (sessionStore != null) {
      _checkpointTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (this.player.playing && !_loading) unawaited(saveSession());
      });
    }
    _subscriptions.add(this.player.playerStateStream.listen((_) => _publish()));
    _subscriptions.add(
      this.player.playbackEventStream.listen(
        (_) => _publish(),
        onError: (Object _) =>
            errors.add('No se pudo reproducir este archivo.'),
      ),
    );
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
  }) {
    if (_shuttingDown) return Future.value();
    if (selected < 0 || selected >= source.length) return Future.value();
    tracks = List.unmodifiable(source);
    index = selected;
    final track = tracks[index];
    recordEvent(
      'Selección de pista: $selected/${tracks.length}; autoplay=$autoplay',
    );
    final generation = ++_generation;
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
        final duration = await player.setAudioSource(
          AudioSource.uri(
            track.id.startsWith('content://')
                ? Uri.parse(track.id)
                : Uri.file(track.id),
          ),
          initialPosition: initialPosition,
        );
        if (generation == _generation && !_shuttingDown) {
          _loading = false;
          if (duration != null) {
            mediaItem.add(mediaItem.value!.copyWith(duration: duration));
          }
          _publish();
          unawaited(saveSession(position: initialPosition));
          if (_playIntent) unawaited(play());
        }
      } catch (_) {
        if (generation == _generation && !_shuttingDown) {
          _loading = false;
          _playIntent = false;
          await player.stop();
          recordEvent('Error al cargar pista: índice=$index');
          errors.add(
            'No se pudo abrir «${track.title}». Comprueba el archivo y su formato.',
          );
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
    final current = mediaItem.value?.id;
    final remaining = tracks.where((t) => t.id != id).toList();
    if (current == id) {
      await stop();
      tracks = remaining;
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
      index = tracks.indexWhere((t) => t.id == current);
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
    if (index + 1 < tracks.length || shuffle) {
      await skipToNext();
    } else {
      await pause();
      await seek(Duration.zero);
    }
  }

  @override
  Future<void> play() async {
    if (_shuttingDown) return;
    if (index < 0) await onEmptyPlay?.call();
    if (_shuttingDown || index < 0) return;
    _playIntent = true;
    if (_loading) return;
    try {
      final playback = player.play();
      _publish();
      await playback;
    } catch (_) {
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
    if (_closed ||
        sessionStore == null ||
        index < 0 ||
        index >= tracks.length ||
        _loading) {
      return;
    }
    final snapshot = <String, dynamic>{
      'schema': 1,
      'ids': tracks.map((t) => t.id).toList(),
      'current': tracks[index].id,
      'positionMs': (position ?? player.position).inMilliseconds,
      'shuffle': shuffle,
      'repeat': repeat,
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
      if (saved['schema'] != 1 || _generation != 0) return;
      final byId = {for (final t in library) t.id: t};
      final queue = [
        for (final id in (saved['ids'] as List))
          if (byId[id] != null) byId[id]!,
      ];
      final selected = queue.indexWhere((t) => t.id == saved['current']);
      if (selected < 0) return;
      shuffle = saved['shuffle'] as bool? ?? false;
      repeat = saved['repeat'] as bool? ?? false;
      var position = (saved['positionMs'] as num?)?.toInt() ?? 0;
      if (position < 0) position = 0;
      final duration = queue[selected].durationMs;
      if (duration > 0 && position >= duration) position = 0;
      await select(
        queue,
        selected,
        autoplay: false,
        initialPosition: Duration(milliseconds: position),
      );
    } catch (_) {
      errors.add('No se pudo recuperar la última sesión.');
    }
  }

  @override
  Future<void> stop() async {
    ++_generation;
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
    final generation = _generation;
    int? custom;
    if (shuffle && chooseNext != null) {
      try {
        custom = await chooseNext!(tracks, index);
      } catch (_) {
        /* Keep native shuffle available. */
      }
      if (generation != _generation || _shuttingDown) return;
      if (custom != null && (custom < 0 || custom >= tracks.length)) {
        custom = null;
      }
    }
    final next =
        custom ??
        (shuffle && tracks.length > 1
            ? (index + 1 + Random().nextInt(tracks.length - 1)) % tracks.length
            : (index + 1) % tracks.length);
    await select(tracks, next);
  }

  @override
  Future<void> skipToPrevious() async {
    if (tracks.isEmpty) return;
    if (player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    await select(tracks, (index - 1 + tracks.length) % tracks.length);
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
