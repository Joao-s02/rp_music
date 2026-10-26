import 'dart:io';
import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app/library_controller.dart';
import 'app/music_app.dart';
import 'data/local_store.dart';
import 'data/music_files.dart';
import 'playback/music_handler.dart';
import 'playback/playback_config.dart';
import 'platform/android_notifications.dart';
import 'platform/desktop_lifecycle.dart';
import 'updates/update_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final directory = await getApplicationSupportDirectory();
    final controller = LibraryController(
      LocalStore(Directory('${directory.path}/v2')),
      MusicFiles(),
    );
    final handler = Platform.isAndroid
        ? await AudioService.init(
            builder: () => MusicHandler(
              artworkLoader: controller.files.notificationArtwork,
              sessionStore: LocalStore(
                Directory('${directory.path}/v2'),
                baseName: 'session',
              ),
            ),
            config: playbackServiceConfig,
          )
        : MusicHandler(
            sessionStore: LocalStore(
              Directory('${directory.path}/v2'),
              baseName: 'session',
            ),
          );
    if (Platform.isAndroid) {
      handler.observeSystemErrors(AudioService.asyncError);
    }
    await handler.configureSession();
    final notifications = Platform.isAndroid ? AndroidNotifications() : null;
    final updates = UpdateController(
      LocalStore(Directory('${directory.path}/v2'), baseName: 'updates'),
    );
    runApp(
      MusicApp(
        library: controller,
        audio: handler,
        notifications: notifications,
        updates: updates,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifications?.request(firstLaunch: true);
    });
    unawaited(updates.initialize());
    await controller.initialize();
    await handler.setAppVolume(controller.volume);
    if (Platform.isWindows) {
      await DesktopLifecycle(
        NativeDesktopWindow(),
        controller,
        handler,
      ).initialize();
    }
    await handler.restoreSession(controller.tracks);
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No se pudo iniciar RP Music. Cierra la aplicación y vuelve a intentarlo.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
