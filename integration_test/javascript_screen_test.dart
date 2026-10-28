// Generic native harness; provider logic and scenarios live in the extension repo.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/javascript_screen_service.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/sources/extension_source_broker.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('external JavaScript screen scenario and native audio', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Comprobando extensiones JavaScript')),
        ),
      ),
    );
    await tester.runAsync(() async {
      const path = String.fromEnvironment('SCREEN_SCENARIO_PATH');
      expect(path, isNotEmpty, reason: 'Supply an external scenario file.');
      final scenario =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      final directory = await Directory.systemTemp.createTemp(
        'rp_screen_native_',
      );
      final programs = ProgramController(
        LocalStore(directory, baseName: 'extensions'),
      );
      final audio = MusicHandler();
      final broker = ExtensionSourceBroker(programs, audio);
      final errors = <String>[];
      final subscription = audio.errors.stream.listen(errors.add);
      final report = <String, dynamic>{
        'platform': Platform.operatingSystem,
        'steps': <dynamic>[],
        'nativeAudio': false,
      };
      try {
        for (final file in scenario['packages'] as List) {
          final package = ProgramPackage.parse(
            jsonDecode(File(file as String).readAsStringSync())
                as Map<String, dynamic>,
          );
          await programs.install(package, package.permissions);
        }
        final screens = JavascriptScreenService(programs);
        for (final raw in scenario['steps'] as List) {
          final step = Map<String, dynamic>.from(raw as Map);
          final id = step['id'] as String;
          final before = programs.privateData[id] ?? {};
          var action = step['action'] as String;
          if (step['indexWhere'] is Map) {
            final match = step['indexWhere'] as Map;
            final items = before[match['list']] as List;
            final index = items.indexWhere(
              (item) => (item as Map)[match['field']] == match['value'],
            );
            expect(index, greaterThanOrEqualTo(0));
            action += '$index';
          }
          final result = await screens.run(id, {
            'action': action,
            'fields': step['fields'] ?? {},
          });
          (report['steps'] as List).add({
            'id': id,
            'action': action,
            'error': result['error'],
            'message': result['message'],
          });
          expect(result['error'], isNot(true), reason: '${result['message']}');
          final state = programs.privateData[id] ?? {};
          if (step['nonempty'] is String) {
            expect(
              state[step['nonempty']],
              isNotEmpty,
              reason: jsonEncode(result['view']),
            );
          }
          if (step['changed'] is String) {
            expect(state[step['changed']], isNot(before[step['changed']]));
          }
          if (step['remote'] == true) {
            expect(
              result['playRemote'],
              isA<Map>(),
              reason: '${result['message']}',
            );
            final track = screens.remoteTrack(id, result['playRemote']);
            (report['steps'] as List).last['remoteResolved'] = programs
                .screenAudio
                .containsKey(track.id);
          }
          if (step['listen'] == true) {
            expect(
              result['playRemote'],
              isA<Map>(),
              reason: jsonEncode(result['view']),
            );
            final track = screens.remoteTrack(id, result['playRemote']);
            await audio.configureSession();
            await audio.setAppVolume(0.1);
            await audio.select([track], 0).timeout(const Duration(seconds: 35));
            final deadline = DateTime.now().add(const Duration(seconds: 20));
            while (DateTime.now().isBefore(deadline) &&
                audio.player.position.inMilliseconds < 2000 &&
                errors.isEmpty) {
              await Future<void>.delayed(const Duration(milliseconds: 250));
            }
            expect(errors, isEmpty);
            expect(audio.player.playing, isTrue);
            expect(audio.player.position.inMilliseconds, greaterThan(1000));
            report['nativeAudio'] = true;
            report['title'] = track.title;
            report['positionMs'] = audio.player.position.inMilliseconds;
            await audio.pause();
            expect(audio.player.playing, isFalse);
            unawaited(audio.play());
            await Future<void>.delayed(const Duration(seconds: 1));
            expect(audio.player.playing, isTrue);
            await programs.setEnabled(id, false);
            await Future<void>.delayed(const Duration(milliseconds: 400));
            expect(audio.player.playing, isFalse);
            report['revocationStopped'] = true;
          }
          (report['steps'] as List).last['count'] = state['items'] is List
              ? (state['items'] as List).length
              : null;
        }
        report['ok'] = true;
      } finally {
        report['errors'] = errors;
        File(
          scenario['report'] as String,
        ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
        debugPrint('RP_JS_NATIVE ${jsonEncode(report)}');
        await subscription.cancel();
        broker.dispose();
        await audio.close();
        programs.dispose();
        await directory.delete(recursive: true);
      }
    });
  }, timeout: const Timeout(Duration(minutes: 6)));
}
