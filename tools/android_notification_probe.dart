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
import 'package:rp_music/playback/playback_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final failures = <String>[];
  AudioService.asyncError.listen((error) => failures.add(error.toString()));
  final handler = await AudioService.init(
    builder: () => MusicHandler(),
    config: playbackServiceConfig,
  );
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Comprobando notificación release…')),
      ),
    ),
  );
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
  final file = await File('${Directory.systemTemp.path}/rp-probe.wav')
      .writeAsBytes(bytes.buffer.asUint8List());
  await handler.configureSession();
  await handler.setAppVolume(0);
  final second = await File('${Directory.systemTemp.path}/rp-probe-second.wav').writeAsBytes(bytes.buffer.asUint8List());
  await handler.select([
    Track(id: file.path, title: 'RP Music · primera', folder: '.'),
    Track(id: second.path, title: 'RP Music · segunda', folder: '.'),
  ], 0);
  debugPrint('RP_PROBE_READY');
  await Future<void>.delayed(const Duration(seconds: 5));
  const channel = MethodChannel('rp_music/system');
  Future<Map<String, dynamic>> snapshot() async {
    final raw = await channel.invokeMapMethod<String, dynamic>('playbackDiagnostics') ?? {};
    return {for (final key in ['mediaNotifications', 'foreground', 'hasMediaSession']) key: raw[key]};
  }
  final advanced = handler.index == 1 && handler.player.playing;
  final playing = await snapshot();
  await handler.pause();
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final paused = await snapshot();
  unawaited(handler.play());
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final resumed = await snapshot();
  await handler.stop();
  await Future<void>.delayed(const Duration(milliseconds: 300));
  final stopped = await snapshot();
  final result = jsonEncode({'advanced': advanced, 'playing': playing, 'paused': paused, 'resumed': resumed, 'stopped': stopped, 'errors': failures});
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
