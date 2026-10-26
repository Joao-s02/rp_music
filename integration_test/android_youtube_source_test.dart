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
import 'package:rp_music/sources/youtube_source_broker.dart';
import 'package:rp_music/sources/youtube_music_api.dart';

import '../test/fixtures/youtube_package.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android real: fuente instalada, búsqueda, audio y revocación', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'rp_youtube_native_',
      );
      final programs = ProgramController(
        LocalStore(directory, baseName: 'test-extensions'),
      );
      final handler = await AudioService.init(
        builder: MusicHandler.new,
        config: playbackServiceConfig,
      );
      await handler.configureSession();
      final broker = YoutubeSourceBroker(programs, handler);
      try {
        final package = ProgramPackage.parse(
          Map<String, dynamic>.from(jsonDecode(youtubePackageJson) as Map),
        );
        await programs.install(package, package.permissions);
        final api = YoutubeMusicApi();
        final found = await api.search('Kevin MacLeod', package.id);
        expect(found.length, greaterThanOrEqualTo(2));
        final contract = await programs.invoke(package.id, 'source', {
          'query': 'Kevin MacLeod',
        });
        expect(contract?['provider'], 'youtube-music');
        await handler.select(found, 0);
        await Future<void>.delayed(const Duration(seconds: 5));
        expect(handler.player.playing, isTrue);
        expect(
          handler.player.position,
          greaterThan(const Duration(seconds: 2)),
        );
        await handler.pause();
        expect(handler.player.playing, isFalse);
        await handler.seek(const Duration(seconds: 10));
        unawaited(handler.play());
        await Future<void>.delayed(const Duration(seconds: 4));
        expect(
          handler.player.position,
          greaterThan(const Duration(seconds: 10)),
        );
        await handler.skipToNext();
        await Future<void>.delayed(const Duration(seconds: 5));
        expect(handler.index, 1);
        expect(handler.player.playing, isTrue);
        var previous = handler.player.position;
        debugPrint('RP_YOUTUBE_APP_PROBE_BACKGROUND_READY');
        for (var i = 0; i < 9; i++) {
          await Future<void>.delayed(const Duration(seconds: 5));
          final current = handler.player.position;
          expect(current, greaterThanOrEqualTo(previous));
          expect(handler.player.playing, isTrue);
          previous = current;
          debugPrint('RP_YOUTUBE_APP_PROBE_POSITION ${current.inMilliseconds}');
        }
        await programs.setEnabled(package.id, false);
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(handler.player.playing, isFalse);
        await handler.play();
        expect(handler.player.playing, isFalse);
        debugPrint('RP_YOUTUBE_APP_PROBE_OK');
      } finally {
        broker.dispose();
        programs.dispose();
        await handler.close();
        await directory.delete(recursive: true);
      }
    });
  }, timeout: const Timeout(Duration(minutes: 4)));
}
