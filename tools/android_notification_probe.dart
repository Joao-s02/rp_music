// Local release probe, never used as the production entry point.
// flutter build apk --release -t tools/android_notification_probe.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final failures = <String>[];
  AudioService.asyncError.listen((error) => failures.add(error.toString()));
  final handler = await AudioService.init(
    builder: () => MusicHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'rp_music.playback',
      androidNotificationChannelName: 'Reproducción',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'drawable/ic_stat_music',
    ),
  );
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Comprobando notificación release…')),
      ),
    ),
  );
  final bytes = ByteData(44 + 16000 * 180);
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
  final file = await File('${Directory.systemTemp.path}/rp-probe.wav')
      .writeAsBytes(bytes.buffer.asUint8List());
  await handler.configureSession();
  await handler.setAppVolume(0);
  await handler.select([
    Track(id: file.path, title: 'RP Music · prueba release', folder: '.'),
  ], 0);
  await Future<void>.delayed(const Duration(seconds: 3));
  const channel = MethodChannel('rp_music/system');
  final playing = await channel.invokeMapMethod<String, dynamic>(
    'playbackDiagnostics',
  );
  await handler.pause();
  await Future<void>.delayed(const Duration(milliseconds: 400));
  final paused = await channel.invokeMapMethod<String, dynamic>(
    'playbackDiagnostics',
  );
  unawaited(handler.play());
  await Future<void>.delayed(const Duration(milliseconds: 400));
  final resumed = await channel.invokeMapMethod<String, dynamic>(
    'playbackDiagnostics',
  );
  final result = jsonEncode({
    'playing': playing,
    'paused': paused,
    'resumed': resumed,
    'errors': failures,
  });
  // Read with adb logcat; does not contain library/account information.
  debugPrint('RP_RELEASE_PROBE $result');
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(result),
          ),
        ),
      ),
    ),
  );
}
