import 'package:rp_music/features/playback/domain/playable_source.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';

class AudioCapabilities {
  final bool supportsGapless;
  final bool supportsVolumeControl;
  final bool supportsSpeedControl;
  final bool supportsPitchControl;
  final Set<String> supportedCodecs;

  const AudioCapabilities({
    this.supportsGapless = false,
    this.supportsVolumeControl = true,
    this.supportsSpeedControl = true,
    this.supportsPitchControl = false,
    this.supportedCodecs = const {'mp3', 'm4a', 'aac', 'flac', 'wav', 'ogg'},
  });
}

abstract interface class AudioEngine {
  AudioCapabilities get capabilities;
  Stream<PlaybackSnapshot> get snapshots;
  PlaybackSnapshot get currentSnapshot;

  Future<void> load(PlayableSource source, Duration position);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> stop();
  Future<void> dispose();
}
