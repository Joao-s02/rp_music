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
      final audio = await AudioService.init(
        builder: MusicHandler.new,
        config: playbackServiceConfig,
      );
      await audio.configureSession();
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
        expect(tracks.length, greaterThanOrEqualTo(2));
        await audio.select(tracks, 0);
        await Future<void>.delayed(const Duration(seconds: 5));
        expect(audio.player.playing, isTrue);
        expect(audio.player.position, greaterThan(const Duration(seconds: 2)));
        expect(
          audio.mediaItem.value!.extras!['sourceName'],
          package.sourceSpec!.name,
        );
        await audio.pause();
        expect(audio.player.playing, isFalse);
        await audio.seek(const Duration(seconds: 10));
        unawaited(audio.play());
        await Future<void>.delayed(const Duration(seconds: 4));
        expect(audio.player.position, greaterThan(const Duration(seconds: 10)));
        await audio.skipToNext();
        await Future<void>.delayed(const Duration(seconds: 5));
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
        await audio.close();
      }
    });
  }, timeout: const Timeout(Duration(minutes: 4)));
}
