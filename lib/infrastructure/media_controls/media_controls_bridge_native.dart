import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:rp_music/features/playback/application/playback_coordinator.dart';
import 'package:rp_music/infrastructure/media_controls/android_audio_handler.dart';
import 'package:rp_music/infrastructure/media_controls/media_controls_bridge.dart';

Future<MediaControlsBridge> createMediaControlsBridge(PlaybackCoordinator coordinator) async {
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      final handler = await AudioService.init(
        builder: () => AppAudioHandler(coordinator),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.rp_music.audio',
          androidNotificationChannelName: 'Music Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
      await handler.init();
      return handler;
    } catch (_) {
      // Fallback if background service init fails
    }
  }

  // Windows / Desktop lightweight fallback handler
  final handler = AppAudioHandler(coordinator);
  await handler.init();
  return handler;
}
