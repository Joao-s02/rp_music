import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/playback/playback_config.dart';
import 'package:rp_music/sources/extension_source_broker.dart';
import 'package:rp_music/sources/extension_source_service.dart';

Future<void> waitForPlayback(MusicHandler audio, Duration minimum) async {
  final deadline = DateTime.now().add(const Duration(seconds: 25));
  while (DateTime.now().isBefore(deadline) &&
      (!audio.player.playing || audio.player.position <= minimum)) {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  expect(audio.player.playing, isTrue);
  expect(
    audio.player.position,
    greaterThan(minimum),
    reason: 'El audio debe avanzar tras la carga inicial.',
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('fuente externa instalada, audio y retirada del permiso', (
    tester,
  ) async {
    await tester.runAsync(() async {
      const encoded = String.fromEnvironment('SOURCE_PACKAGE_GZIP');
      expect(
        encoded,
        isNotEmpty,
        reason: 'Proporciona un paquete externo comprimido.',
      );
      final package = ProgramPackage.parse(
        Map<String, dynamic>.from(
          jsonDecode(utf8.decode(gzip.decode(base64Decode(encoded)))) as Map,
        ),
      );
      final directory = await Directory.systemTemp.createTemp(
        'rp_source_probe_',
      );
      final programs = ProgramController(LocalStore(directory));
      final audio = Platform.isAndroid
          ? await AudioService.init(
              builder: MusicHandler.new,
              config: playbackServiceConfig,
            )
          : MusicHandler();
      await audio.configureSession();
      final errors = audio.errors.stream.listen(
        (message) => debugPrint('RP_SOURCE_ERROR: $message'),
      );
      final nativeErrors = audio.player.errorStream.listen(
        (error) => debugPrint('RP_SOURCE_NATIVE_ERROR: ${error.code}'),
      );
      final broker = ExtensionSourceBroker(programs, audio);
      try {
        await programs.install(package, package.permissions);
        final service = ExtensionSourceService(programs);
        final tracks = await service.search(
          const String.fromEnvironment(
            'SOURCE_QUERY',
            defaultValue: 'instrumental',
          ),
          package.id,
        );
        const titleMatch = String.fromEnvironment('SOURCE_TITLE_MATCH');
        if (titleMatch.isNotEmpty) {
          tracks.removeWhere(
            (t) => !t.title.toLowerCase().contains(titleMatch.toLowerCase()),
          );
        }
        expect(tracks, isNotEmpty);
        const secondQuery = String.fromEnvironment('SOURCE_SECOND_QUERY');
        if (secondQuery.isNotEmpty) {
          final secondResults = await service.search(secondQuery, package.id);
          expect(secondResults, isNotEmpty);
          tracks.removeRange(1, tracks.length);
          const secondTitle = String.fromEnvironment(
            'SOURCE_SECOND_TITLE_MATCH',
          );
          tracks.add(
            secondTitle.isEmpty
                ? secondResults.first
                : secondResults.firstWhere(
                    (t) => t.title.toLowerCase().contains(
                      secondTitle.toLowerCase(),
                    ),
                  ),
          );
        }
        expect(tracks.length, greaterThanOrEqualTo(2));
        await audio.select(tracks, 0);
        await waitForPlayback(audio, const Duration(seconds: 2));
        expect(
          audio.mediaItem.value!.extras!['sourceName'],
          package.sourceSpec!.name,
        );
        await audio.pause();
        expect(audio.player.playing, isFalse);
        await audio.seek(const Duration(seconds: 10));
        unawaited(audio.play());
        await waitForPlayback(audio, const Duration(seconds: 10));
        await audio.skipToNext();
        await waitForPlayback(audio, const Duration(seconds: 2));
        expect(audio.index, 1);
        expect(audio.player.playing, isTrue);
        await audio.skipToPrevious();
        await waitForPlayback(audio, const Duration(seconds: 2));
        expect(audio.index, 0);
        expect(audio.player.playing, isTrue);
        await audio.skipToNext();
        await waitForPlayback(audio, const Duration(seconds: 2));
        expect(audio.index, 1);
        expect(audio.player.playing, isTrue);
        debugPrint('RP_SOURCE_BACKGROUND_READY');
        var previous = audio.player.position;
        for (var i = 0; i < 6; i++) {
          await Future<void>.delayed(const Duration(seconds: 5));
          expect(audio.player.position, greaterThanOrEqualTo(previous));
          expect(audio.player.playing, isTrue);
          previous = audio.player.position;
        }
        await programs.setEnabled(package.id, false);
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(audio.player.playing, isFalse);
        await audio.play();
        expect(audio.player.playing, isFalse);
        debugPrint('RP_SOURCE_PROBE_OK');
      } finally {
        broker.dispose();
        programs.dispose();
        await errors.cancel();
        await nativeErrors.cancel();
        await audio.close();
      }
    });
  }, timeout: const Timeout(Duration(minutes: 4)));
}
