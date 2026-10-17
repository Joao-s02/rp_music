import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/playback/application/playback_coordinator.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';
import 'package:rp_music/infrastructure/media_controls/media_controls_bridge.dart';

class AppAudioHandler extends BaseAudioHandler implements MediaControlsBridge {
  final PlaybackCoordinator _coordinator;

  AppAudioHandler(this._coordinator);

  @override
  Future<void> init() async {
    // Initial media state
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  @override
  Future<void> play() async => _coordinator.play();

  @override
  Future<void> pause() async => _coordinator.pause();

  @override
  Future<void> seek(Duration position) async => _coordinator.seek(position);

  @override
  Future<void> skipToNext() async => _coordinator.skipNext();

  @override
  Future<void> skipToPrevious() async => _coordinator.skipPrevious();

  @override
  Future<void> stop() async => _coordinator.pause();

  @override
  void updatePlaybackState(PlaybackSnapshot snapshot) {
    final isPlaying = snapshot.isPlaying;
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _mapProcessingState(snapshot.processing),
        playing: isPlaying,
        updatePosition: snapshot.position,
        bufferedPosition: snapshot.position,
        speed: 1.0,
      ),
    );
  }

  @override
  void updateActiveTrack(Track? track) {
    if (track == null) {
      mediaItem.add(null);
      return;
    }

    mediaItem.add(
      MediaItem(
        id: track.id.value,
        title: track.title,
        artist: track.artistName ?? 'Unknown Artist',
        album: track.albumTitle ?? 'Unknown Album',
        duration: track.duration,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
      ProcessingState.failed => AudioProcessingState.error,
    };
  }

  @override
  Future<void> dispose() async {
    await stop();
  }
}
