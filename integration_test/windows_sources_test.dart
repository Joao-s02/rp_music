import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/sources/extension_source_broker.dart';
import 'package:rp_music/sources/extension_source_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'external API2 sources play and support transport controls on Windows',
    (tester) async {
      await tester.runAsync(() async {
        const listPath = String.fromEnvironment('SOURCE_FIXTURE_LIST');
        const reportPath = String.fromEnvironment('SOURCE_REPORT');
        final paths = (jsonDecode(File(listPath).readAsStringSync()) as List)
            .cast<String>();
        final temp = await Directory.systemTemp.createTemp(
          'rp_source_windows_',
        );
        final programs = ProgramController(
          LocalStore(temp, baseName: 'extensions'),
        );
        final audio = MusicHandler();
        final sources = ExtensionSourceService(programs);
        final broker = ExtensionSourceBroker(programs, audio, service: sources);
        final errors = <String>[];
        final subscription = audio.errors.stream.listen(errors.add);
        final rows = <Map<String, dynamic>>[];
        Future<void> progress(Duration minimum) async {
          final deadline = DateTime.now().add(const Duration(seconds: 25));
          while (DateTime.now().isBefore(deadline) &&
              errors.isEmpty &&
              (!audio.player.playing || audio.player.position < minimum)) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
          expect(errors, isEmpty, reason: audio.lastPlaybackError);
          expect(audio.player.playing, isTrue, reason: audio.lastPlaybackError);
          expect(audio.player.position, greaterThanOrEqualTo(minimum));
        }

        try {
          await audio.configureSession();
          await audio.setAppVolume(0.05);
          for (final path in paths) {
            final package = ProgramPackage.parse(
              jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>,
            );
            await programs.install(package, package.permissions);
            await programs.choose('source', package.id);
            final watch = Stopwatch()..start();
            final results = await sources.search('Luis Miguel', package.id);
            expect(results.length, greaterThanOrEqualTo(2));
            final searchMs = watch.elapsedMilliseconds;
            final tracks = results.take(2).toList();
            watch.reset();
            await audio.select(tracks, 0).timeout(const Duration(seconds: 40));
            await progress(const Duration(seconds: 2));
            final firstAudioMs = watch.elapsedMilliseconds;
            await audio.pause();
            expect(audio.player.playing, isFalse);
            await audio.seek(const Duration(seconds: 10));
            unawaited(audio.play());
            await progress(const Duration(seconds: 10));
            await audio.skipToNext();
            await progress(const Duration(seconds: 2));
            expect(audio.index, 1);
            await audio.skipToPrevious();
            await progress(const Duration(seconds: 2));
            expect(audio.index, 0);
            await programs.setEnabled(package.id, false);
            await Future<void>.delayed(const Duration(milliseconds: 500));
            expect(audio.player.playing, isFalse);
            rows.add({
              'id': package.id,
              'searchMs': searchMs,
              'firstAudioWith2sProgressMs': firstAudioMs,
              'searchResults': results.length,
              'nativePlayback': true,
              'pauseSeekNextPrevious': true,
              'revocationStopped': true,
              'events': List<String>.of(audio.diagnosticEvents),
            });
          }
        } finally {
          if (reportPath.isNotEmpty) {
            File(reportPath).writeAsStringSync(
              const JsonEncoder.withIndent('  ').convert({
                'results': rows,
                'errors': errors,
                'lastPlaybackError': audio.lastPlaybackError,
              }),
            );
          }
          // ignore: avoid_print
          print(
            'WINDOWS_API2 ${jsonEncode({'results': rows.map((r) => Map.of(r)..remove('events')).toList(), 'errors': errors, 'lastPlaybackError': audio.lastPlaybackError})}',
          );
          await subscription.cancel();
          broker.dispose();
          await audio.close();
          programs.dispose();
          if (!temp.absolute.path.startsWith(
            '${Directory.systemTemp.absolute.path}${Platform.pathSeparator}rp_source_windows_',
          )) {
            throw StateError('Unexpected temporary path');
          }
          await temp.delete(recursive: true);
        }
      });
    },
    timeout: const Timeout(Duration(minutes: 6)),
  );
}
