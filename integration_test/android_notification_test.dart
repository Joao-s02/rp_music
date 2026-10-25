import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/playback/playback_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android publica una notificación con sesión multimedia real', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final errors = <Object>[];
      final subscription = AudioService.asyncError.listen(errors.add);
      final handler = await AudioService.init(
        builder: () => MusicHandler(),
        config: playbackServiceConfig,
      );
      final directory = await Directory.systemTemp.createTemp('rp_android_');
      final bytes = ByteData(44 + 16000 * 4);
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
      final file = await File('${directory.path}/prueba.wav')
          .writeAsBytes(bytes.buffer.asUint8List());
      try {
        await handler.configureSession();
        await handler.setAppVolume(0);
        final second = await File('${directory.path}/segunda.wav')
            .writeAsBytes(bytes.buffer.asUint8List());
        await handler.select([
          Track(id: file.path, title: 'Prueba Android', folder: '.'),
          Track(id: second.path, title: 'Segunda Android', folder: '.'),
        ], 0);
        await Future<void>.delayed(const Duration(seconds: 2));
        expect(
          errors,
          isEmpty,
          reason: 'Errores del puente AudioService: $errors',
        );
        const channel = MethodChannel('rp_music/system');
        final diagnostics = await channel.invokeMapMethod<String, dynamic>(
          'playbackDiagnostics',
        );
        expect(diagnostics?['mediaNotifications'], 1, reason: '$diagnostics');
        expect(diagnostics?['hasMediaSession'], true);
        await channel.invokeMethod<void>('testMoveToBackground');
        await Future<void>.delayed(const Duration(seconds: 3));
        expect(
          handler.index,
          1,
          reason: 'La pista debe avanzar con la actividad en segundo plano',
        );
        expect(handler.player.playing, true);
        await handler.pause();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(handler.playbackState.value.playing, false);
        final paused = await channel.invokeMapMethod<String, dynamic>(
          'playbackDiagnostics',
        );
        expect(
          paused?['foreground'],
          true,
          reason: 'Pausar no debe degradar el servicio',
        );
        unawaited(handler.play());
        await Future<void>.delayed(const Duration(milliseconds: 400));
        expect(handler.playbackState.value.playing, true);
        expect(errors, isEmpty);
        await handler.stop();
        await Future<void>.delayed(const Duration(milliseconds: 400));
        final stopped = await channel.invokeMapMethod<String, dynamic>(
          'playbackDiagnostics',
        );
        expect(
          stopped?['foreground'],
          false,
          reason: 'Detener debe liberar el servicio',
        );
      } finally {
        await handler.stop();
        await handler.close();
        await subscription.cancel();
        await directory.delete(recursive: true);
      }
    });
  });
}
