import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/playback/application/playback_coordinator.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';
import 'package:rp_music/infrastructure/media_controls/media_controls_bridge.dart';

class StubMediaControlsBridge implements MediaControlsBridge {
  StubMediaControlsBridge(PlaybackCoordinator coordinator);

  @override
  Future<void> init() async {}

  @override
  void updatePlaybackState(PlaybackSnapshot snapshot) {}

  @override
  void updateActiveTrack(Track? track) {}

  @override
  Future<void> dispose() async {}
}

Future<MediaControlsBridge> createMediaControlsBridge(PlaybackCoordinator coordinator) async {
  return StubMediaControlsBridge(coordinator);
}
