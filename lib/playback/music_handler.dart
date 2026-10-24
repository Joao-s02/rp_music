import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/track.dart';

class MusicHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player;
  final errors = StreamController<String>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  Future<void> _operations = Future.value();
  int _generation = 0;
  bool _loading = false;
  bool _playIntent = false;
  List<Track> tracks = [];
  int index = -1;
  bool shuffle = false;
  bool repeat = false;
  MusicHandler({AudioPlayer? player}) : player = player ?? AudioPlayer() {
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
  Future<void> configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _publish() => playbackState.add(
    PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (player.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
    ),
  );
  Future<void> select(List<Track> source, int selected) {
    if (selected < 0 || selected >= source.length) return Future.value();
    tracks = List.unmodifiable(source);
    index = selected;
    final track = tracks[index];
    final generation = ++_generation;
    _loading = true;
    _playIntent = true;
    final operation = _operations.then((_) async {
      if (generation != _generation) return;
      await player.pause();
      if (generation != _generation) return;
      mediaItem.add(
        MediaItem(
          id: track.id,
          title: track.title,
          artist: track.artist,
          album: track.album,
          duration: Duration(milliseconds: track.durationMs),
        ),
      );
      try {
        await player.setAudioSource(
          AudioSource.uri(
            track.id.startsWith('content://')
                ? Uri.parse(track.id)
                : Uri.file(track.id),
          ),
        );
        if (generation == _generation) {
          _loading = false;
          if (_playIntent) unawaited(play());
        }
      } catch (_) {
        if (generation == _generation) {
          _loading = false;
          _playIntent = false;
          await player.stop();
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
    _playIntent = true;
    if (_loading) return;
    try {
      await player.play();
    } catch (_) {
      errors.add('No se pudo iniciar el audio.');
    }
  }

  @override
  Future<void> pause() {
    _playIntent = false;
    return player.pause();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);
  @override
  Future<void> stop() async {
    ++_generation;
    _playIntent = false;
    _loading = false;
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (tracks.isEmpty) return;
    final next = shuffle && tracks.length > 1
        ? (index + 1 + Random().nextInt(tracks.length - 1)) % tracks.length
        : (index + 1) % tracks.length;
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

  Future<void> close() async {
    ++_generation;
    await _operations;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await player.dispose();
    await errors.close();
  }
}
