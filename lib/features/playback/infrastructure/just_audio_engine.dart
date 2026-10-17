import 'dart:async';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:rp_music/core/diagnostics/diagnostics_service.dart';
import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/playback/domain/audio_engine.dart';
import 'package:rp_music/features/playback/domain/playable_source.dart';
import 'package:rp_music/features/playback/domain/playback_failure.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';

class JustAudioEngine implements AudioEngine {
  final ja.AudioPlayer _player;
  final StreamController<PlaybackSnapshot> _snapshotController = StreamController<PlaybackSnapshot>.broadcast();
  final DiagnosticsService _diagnostics = DiagnosticsService();

  PlaybackSnapshot _currentSnapshot = PlaybackSnapshot.initial();
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  JustAudioEngine({ja.AudioPlayer? player}) : _player = player ?? ja.AudioPlayer() {
    _initStreams();
  }

  void _initStreams() {
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      final proc = _mapProcessingState(state.processingState);
      _updateSnapshot(
        processing: proc,
        playIntent: state.playing,
      );
    }, onError: (Object error, StackTrace stack) {
      _diagnostics.error('JustAudioEngine', 'Player state stream error: $error', {'stack': stack.toString()});
      _updateSnapshot(
        processing: ProcessingState.failed,
        failure: () => PlaybackFailure(
          reason: PlaybackFailureReason.backendFailure,
          message: error.toString(),
          cause: error,
          stackTrace: stack,
        ),
      );
    });

    _positionSubscription = _player.positionStream.listen((pos) {
      if (_currentSnapshot.position != pos) {
        _updateSnapshot(position: pos);
      }
    });

    _durationSubscription = _player.durationStream.listen((dur) {
      if (_currentSnapshot.duration != dur) {
        _updateSnapshot(duration: () => dur);
      }
    });
  }

  ProcessingState _mapProcessingState(ja.ProcessingState state) {
    return switch (state) {
      ja.ProcessingState.idle => ProcessingState.idle,
      ja.ProcessingState.loading => ProcessingState.loading,
      ja.ProcessingState.buffering => ProcessingState.buffering,
      ja.ProcessingState.ready => ProcessingState.ready,
      ja.ProcessingState.completed => ProcessingState.completed,
    };
  }

  void _updateSnapshot({
    String? sessionId,
    int? sourceGeneration,
    TrackId? Function()? trackId,
    ProcessingState? processing,
    bool? playIntent,
    Duration? position,
    Duration? Function()? duration,
    double? volume,
    PlaybackFailure? Function()? failure,
  }) {
    _currentSnapshot = _currentSnapshot.copyWith(
      sessionId: sessionId,
      sourceGeneration: sourceGeneration,
      trackId: trackId,
      processing: processing,
      playIntent: playIntent,
      position: position,
      duration: duration,
      volume: volume,
      failure: failure,
    );
    _snapshotController.add(_currentSnapshot);
  }

  @override
  AudioCapabilities get capabilities => const AudioCapabilities(
    supportsGapless: false,
    supportsVolumeControl: true,
    supportsSpeedControl: true,
  );

  @override
  Stream<PlaybackSnapshot> get snapshots => _snapshotController.stream;

  @override
  PlaybackSnapshot get currentSnapshot => _currentSnapshot;

  @override
  Future<void> load(PlayableSource source, Duration position) async {
    _diagnostics.info('JustAudioEngine', 'Loading source: $source, pos: $position');
    _updateSnapshot(
      processing: ProcessingState.loading,
      failure: () => null,
      position: position,
    );

    try {
      final ja.AudioSource jaSource = switch (source) {
        NativeFileSource s => ja.AudioSource.file(s.path),
        AndroidContentUriSource s => ja.AudioSource.uri(s.uri),
        WebBlobSource s => ja.AudioSource.uri(s.blobUri),
        ManagedAppFileSource s => ja.AudioSource.file(s.localPath),
      };

      final resolvedDuration = await _player.setAudioSource(jaSource, initialPosition: position);
      _updateSnapshot(
        processing: ProcessingState.ready,
        duration: () => resolvedDuration ?? _player.duration,
      );
    } on ja.PlayerException catch (e, stack) {
      _diagnostics.error('JustAudioEngine', 'PlayerException during load: ${e.message}', {'code': e.code});
      final failure = PlaybackFailure(
        reason: PlaybackFailureReason.unsupportedFormat,
        message: 'Unsupported format or decode error: ${e.message}',
        cause: e,
        stackTrace: stack,
      );
      _updateSnapshot(
        processing: ProcessingState.failed,
        failure: () => failure,
      );
      throw failure;
    } catch (e, stack) {
      _diagnostics.error('JustAudioEngine', 'Generic error during load: $e');
      final failure = PlaybackFailure(
        reason: PlaybackFailureReason.backendFailure,
        message: 'Failed to load audio: $e',
        cause: e,
        stackTrace: stack,
      );
      _updateSnapshot(
        processing: ProcessingState.failed,
        failure: () => failure,
      );
      throw failure;
    }
  }

  @override
  Future<void> play() async {
    _updateSnapshot(playIntent: true);
    // Don't wait forever if play Future doesn't complete immediately
    unawaited(_player.play());
  }

  @override
  Future<void> pause() async {
    _updateSnapshot(playIntent: false);
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    _updateSnapshot(position: position);
    await _player.seek(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _updateSnapshot(volume: clamped);
    await _player.setVolume(clamped);
  }

  @override
  Future<void> stop() async {
    _updateSnapshot(
      playIntent: false,
      processing: ProcessingState.idle,
      position: Duration.zero,
    );
    await _player.stop();
  }

  @override
  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _snapshotController.close();
    await _player.dispose();
  }
}
