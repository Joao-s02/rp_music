import 'package:rp_music/features/playback/application/playback_coordinator.dart';
import 'package:rp_music/infrastructure/media_controls/media_controls_bridge.dart';
import 'media_controls_bridge_web.dart'
    if (dart.library.io) 'media_controls_bridge_native.dart' as impl;

Future<MediaControlsBridge> getMediaControlsBridge(PlaybackCoordinator coordinator) =>
    impl.createMediaControlsBridge(coordinator);
