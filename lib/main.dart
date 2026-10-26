import 'dart:io';
import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'extensions/program_controller.dart';
import 'extensions/program_coordinator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final directory = await getApplicationSupportDirectory();
    final controller = LibraryController(
      LocalStore(Directory('${directory.path}/v2')),
      MusicFiles(),
    );
    final playbackReady = Completer<void>();
    late final MusicHandler handler;
    handler = Platform.isAndroid
        ? await AudioService.init(
            builder: () => MusicHandler(
              artworkLoader: controller.files.notificationArtwork,
              onEmptyPlay: () async {
                await playbackReady.future;
                if (handler.index < 0 && controller.tracks.isNotEmpty) {
                  await handler.select(
                    controller.ordered(controller.tracks),
                    0,
                    autoplay: false,
                  );
                }
              },
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
    final programs = ProgramController(
      LocalStore(Directory('${directory.path}/v3'), baseName: 'extensions'),
    );
    try {
      await programs.initialize();
    } catch (_) {
      try {
        await programs.restoreBase();
      } catch (_) {
        /* Keep playback available even if registry storage fails. */
      }
      programs.message =
          'Se inició en modo base por un registro de extensiones dañado.';
    }
    controller.attachPrograms(programs);
    ProgramCoordinator(controller, programs, handler);
    controller.notifyProgramsReady();
    await handler.setAppVolume(controller.volume);
    if (Platform.isWindows) {
      await DesktopLifecycle(
        NativeDesktopWindow(),
        controller,
        handler,
      ).initialize();
    }
    await handler.restoreSession(controller.tracks);
    playbackReady.complete();
    if (Platform.isAndroid) {
      try {
        await const MethodChannel('rp_music/system')
            .invokeMethod<void>('connectWidget');
      } on PlatformException catch (_) {
        /* A launcher can still connect directly to the media service. */
      } on MissingPluginException catch (_) {
        /* Headless startup has no activity channel. */
      }
    }
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
