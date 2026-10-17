import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';

abstract interface class MediaControlsBridge {
  Future<void> init();
  void updatePlaybackState(PlaybackSnapshot snapshot);
  void updateActiveTrack(Track? track);
  Future<void> dispose();
}
