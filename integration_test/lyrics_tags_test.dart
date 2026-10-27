import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rp_music/data/download_tags.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('M4A etiquetado se lee y reproduce sin cambiar el original', (
    tester,
  ) async {
    await tester.runAsync(() async {
      const inputPath = String.fromEnvironment('TAG_TEST_INPUT');
      expect(
        inputPath,
        isNotEmpty,
        reason: 'Proporciona audio sintético mediante TAG_TEST_INPUT.',
      );
      final original = File(inputPath);
      final bytes = await original.readAsBytes();
      final before = sha256.convert(bytes);
      final root = await Directory.systemTemp.createTemp('rp_tags_native_');
      final output = File('${root.path}/tagged.m4a');
      final audio = MusicHandler();
      try {
        await output.writeAsBytes(
          DownloadTags.mp4(bytes, {
            'title': 'Audio sintético',
            'artist': 'RP Music',
            'lyrics': '[00:00]Uno\n[00:02]Dos',
          }),
        );
        expect(
          await MusicFiles().embeddedLyrics(output.path),
          '[00:00]Uno\n[00:02]Dos',
        );
        await audio.configureSession();
        await audio.setAppVolume(0);
        await audio.select(
          [Track(id: output.path, title: 'Audio sintético', folder: root.path)],
          0,
          autoplay: false,
        );
        unawaited(audio.play());
        final deadline = DateTime.now().add(const Duration(seconds: 15));
        while (audio.player.position < const Duration(milliseconds: 1200) &&
            DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
        expect(audio.player.position, greaterThan(const Duration(seconds: 1)));
        expect(audio.player.duration?.inMilliseconds, closeTo(4000, 200));
        expect(sha256.convert(await original.readAsBytes()), before);
      } finally {
        await audio.close();
        await root.delete(recursive: true);
      }
    });
  });
}
