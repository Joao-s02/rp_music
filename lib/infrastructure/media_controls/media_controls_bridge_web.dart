import 'package:rp_music/features/playback/application/playback_coordinator.dart';
import 'package:rp_music/infrastructure/media_controls/media_controls_bridge.dart';
import 'package:rp_music/infrastructure/media_controls/web_media_session_bridge.dart';

Future<MediaControlsBridge> createMediaControlsBridge(PlaybackCoordinator coordinator) async {
  final bridge = WebMediaSessionBridge(coordinator);
  await bridge.init();
  return bridge;
}
