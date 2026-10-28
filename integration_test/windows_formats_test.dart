import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

// Paths stay in a private, ignored local fixture list; never embed user music.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Windows rejects invalid media without blocking the next valid file',
    (tester) async {
      await tester.runAsync(() async {
        const fixtures = String.fromEnvironment('AUDIO_FIXTURE_LIST');
        final paths = (jsonDecode(File(fixtures).readAsStringSync()) as List)
            .cast<String>();
        final temp = await Directory.systemTemp.createTemp('rp_invalid_audio_');
        final file = await File('${temp.path}/invalid.m4a')
            .writeAsString('This is not audio.');
        final audio = MusicHandler();
        final errors = <String>[];
        final subscription = audio.errors.stream.listen(errors.add);
        try {
          await audio.setAppVolume(0.05);
          await audio
              .select([
                Track(id: file.path, title: 'Invalid control', folder: '.'),
              ], 0)
              .timeout(const Duration(seconds: 5));
          await Future<void>.delayed(const Duration(milliseconds: 600));
          expect(errors, isNotEmpty);
          expect(audio.lastPlaybackError, isNotNull);
          await audio
              .select([
                Track(id: paths.first, title: 'Valid control', folder: '.'),
              ], 0)
              .timeout(const Duration(seconds: 10));
          await Future<void>.delayed(const Duration(seconds: 2));
          expect(audio.player.playing, isTrue);
          expect(audio.player.position.inMilliseconds, greaterThan(500));
        } finally {
          await subscription.cancel();
          await audio.close();
          if (!temp.absolute.path.startsWith(
            '${Directory.systemTemp.absolute.path}${Platform.pathSeparator}rp_invalid_audio_',
          )) {
            throw StateError('Unexpected temporary path');
          }
          await temp.delete(recursive: true);
        }
      });
    },
  );
  testWidgets('Windows loads supplied local formats through the real handler', (
    tester,
  ) async {
    await tester.runAsync(() async {
      const fixtures = String.fromEnvironment('AUDIO_FIXTURE_LIST');
      const reportPath = String.fromEnvironment('AUDIO_REPORT');
      expect(fixtures, isNotEmpty);
      final paths = (jsonDecode(File(fixtures).readAsStringSync()) as List)
          .cast<String>();
      final rows = <Map<String, dynamic>>[];
      for (var i = 0; i < paths.length; i++) {
        final path = paths[i];
        final audio = MusicHandler();
        final errors = <String>[];
        final native = <String>[];
        String redact(String text) => text
            .replaceAll(path, '<local file>')
            .replaceAll(Uri.file(path).toString(), '<local file>');
        final messages = audio.errors.stream.listen(
          (e) => errors.add(redact(e)),
        );
        final details = audio.player.errorStream.listen(
          (e) => native.add(redact('code=${e.code}; ${e.message}')),
        );
        final watch = Stopwatch()..start();
        try {
          await audio.configureSession();
          await audio.setAppVolume(0.05);
          await audio
              .select([Track(id: path, title: 'Fixture $i', folder: '.')], 0)
              .timeout(const Duration(seconds: 25));
          final loadMs = watch.elapsedMilliseconds;
          await Future<void>.delayed(const Duration(seconds: 2));
          rows.add({
            'index': i,
            'extension': path.split('.').last.toLowerCase(),
            'loadMs': loadMs,
            'positionMs': audio.player.position.inMilliseconds,
            'playing': audio.player.playing,
            'errors': errors,
            'nativeErrors': native,
          });
        } catch (e) {
          rows.add({
            'index': i,
            'extension': path.split('.').last.toLowerCase(),
            'error': redact('$e'),
            'nativeErrors': native,
          });
        } finally {
          await messages.cancel();
          await details.cancel();
          await audio.close();
        }
      }
      if (reportPath.isNotEmpty) {
        File(
          reportPath,
        ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(rows));
      }
      // Only anonymous fixture indices and native errors are reported.
      // ignore: avoid_print
      print('WINDOWS_FORMATS ${jsonEncode(rows)}');
      expect(
        rows.every(
          (r) =>
              r['playing'] == true &&
              (r['positionMs'] as int? ?? 0) > 500 &&
              (r['errors'] as List).isEmpty,
        ),
        isTrue,
        reason: 'See anonymous native playback report.',
      );
    });
  }, timeout: const Timeout(Duration(minutes: 5)));
}
