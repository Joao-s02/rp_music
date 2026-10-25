import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/platform/desktop_lifecycle.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/music_files.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Windows nativo cambia pistas repetidamente sin cerrar el proceso',
    (tester) async {
      await tester.runAsync(() async {
        final directory = await Directory.systemTemp.createTemp(
          'rp_native_audio_',
        );
        final bytes = ByteData(44 + 16000 * 3);
        void ascii(int offset, String value) {
          for (var i = 0; i < value.length; i++) {
            bytes.setUint8(offset + i, value.codeUnitAt(i));
          }
        }

        ascii(0, 'RIFF');
        bytes.setUint32(4, bytes.lengthInBytes - 8, Endian.little);
        ascii(8, 'WAVE');
        ascii(12, 'fmt ');
        bytes.setUint32(16, 16, Endian.little);
        bytes.setUint16(20, 1, Endian.little);
        bytes.setUint16(22, 1, Endian.little);
        bytes.setUint32(24, 8000, Endian.little);
        bytes.setUint32(28, 16000, Endian.little);
        bytes.setUint16(32, 2, Endian.little);
        bytes.setUint16(34, 16, Endian.little);
        ascii(36, 'data');
        bytes.setUint32(40, bytes.lengthInBytes - 44, Endian.little);
        final tracks = <Track>[];
        for (var i = 0; i < 3; i++) {
          final file = await File('${directory.path}/Pista $i.wav')
              .writeAsBytes(bytes.buffer.asUint8List());
          tracks.add(Track(id: file.path, title: 'Pista $i', folder: '.'));
        }
        final handler = MusicHandler();
        final errors = <String>[];
        final subscription = handler.errors.stream.listen(errors.add);
        try {
          await handler.configureSession();
          for (var i = 0; i < 12; i++) {
            await handler.select(tracks, i % tracks.length);
            await Future<void>.delayed(const Duration(milliseconds: 120));
            await handler.skipToNext();
            await Future<void>.delayed(const Duration(milliseconds: 120));
            await handler.skipToPrevious();
            await Future<void>.delayed(const Duration(milliseconds: 120));
          }
          await Future.wait([
            for (var i = 0; i < 15; i++)
              handler.select(tracks, i % tracks.length),
          ]);
          await Future<void>.delayed(const Duration(milliseconds: 250));
          expect(errors, isEmpty);
          expect(handler.player.duration, const Duration(seconds: 3));
          await handler.setAppVolume(0.35);
          expect(handler.player.volume, 0.35);
          final library = LibraryController(
            LocalStore(directory),
            MusicFiles(),
          );
          final desktop = DesktopLifecycle(
            NativeDesktopWindow(),
            library,
            handler,
          );
          try {
            await desktop.initialize();
            expect(
              desktop.hasTray,
              isTrue,
              reason: 'La prueba requiere la bandeja de Windows disponible',
            );
            await NativeDesktopWindow.channel.invokeMethod<void>(
              'requestClose',
            );
            await Future<void>.delayed(const Duration(milliseconds: 200));
            expect(
              await NativeDesktopWindow.channel.invokeMethod<bool>('isVisible'),
              isFalse,
            );
            expect(handler.player.playing, isTrue);
            await NativeDesktopWindow.channel.invokeMethod<void>('show');
            expect(
              await NativeDesktopWindow.channel.invokeMethod<bool>('isVisible'),
              isTrue,
            );
          } finally {
            await NativeDesktopWindow.channel.invokeMethod<void>('dispose');
            library.dispose();
          }
          await handler.pause();
        } finally {
          await subscription.cancel();
          await handler.close();
          await directory.delete(recursive: true);
        }
      });
    },
    skip: !Platform.isWindows,
  );
}
