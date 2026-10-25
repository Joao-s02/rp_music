import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app/library_controller.dart';
import 'app/music_app.dart';
import 'data/local_store.dart';
import 'data/music_files.dart';
import 'playback/music_handler.dart';

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
              sessionStore: LocalStore(
                Directory('${directory.path}/v2'),
                baseName: 'session',
              ),
            ),
            config: const AudioServiceConfig(
              androidNotificationChannelId: 'rp_music.playback',
              androidNotificationChannelName: 'Reproducción',
              androidNotificationOngoing: true,
            ),
          )
        : MusicHandler(
            sessionStore: LocalStore(
              Directory('${directory.path}/v2'),
              baseName: 'session',
            ),
          );
    await handler.configureSession();
    runApp(MusicApp(library: controller, audio: handler));
    await controller.initialize();
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
