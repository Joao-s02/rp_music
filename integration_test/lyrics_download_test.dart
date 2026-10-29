import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/embedded_lyrics.dart';
import 'package:rp_music/domain/lyrics.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/sources/extension_source_service.dart';
import 'package:rp_music/sources/source_audio_transfer.dart';
import 'package:rp_music/sources/download_enrichment.dart';
import 'package:rp_music/playback/music_handler.dart';

List<String> mediaDigests(Uint8List bytes) {
  final result = <String>[];
  var offset = 0;
  while (offset + 8 <= bytes.length) {
    final data = ByteData.sublistView(bytes);
    var size = data.getUint32(offset);
    var head = 8;
    if (size == 1) {
      size = data.getUint64(offset + 8);
      head = 16;
    }
    if (size == 0) size = bytes.length - offset;
    if (size < head || offset + size > bytes.length) {
      throw const FormatException('Invalid media box');
    }
    if (String.fromCharCodes(bytes.sublist(offset + 4, offset + 8)) == 'mdat') {
      result.add(
        sha256
            .convert(Uint8List.sublistView(bytes, offset + head, offset + size))
            .toString(),
      );
    }
    offset += size;
  }
  return result;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('descarga real conserva LRC incrustado y audio reproducible', (
    tester,
  ) async {
    await tester.runAsync(() async {
      const scenarioPath = String.fromEnvironment('LYRICS_DOWNLOAD_SCENARIO');
      expect(scenarioPath, isNotEmpty);
      final scenario =
          jsonDecode(await File(scenarioPath).readAsString()) as Map;
      final base = File(scenarioPath).absolute.parent.parent;
      final temp = await Directory.systemTemp.createTemp('rp_synced_download_');
      final programs = ProgramController(
        LocalStore(temp, baseName: 'extensions'),
      );
      final audio = MusicHandler();
      try {
        final package = ProgramPackage.parse(
          jsonDecode(
            await File.fromUri(base.uri.resolve(scenario['package'] as String))
                .readAsString(),
          ) as Map<String, dynamic>,
        );
        await programs.install(package, package.permissions);
        await programs.choose('source', package.id);
        final service = ExtensionSourceService(programs);
        final tracks = await service.search(
          scenario['query'] as String,
          package.id,
        );
        final track = tracks.firstWhere(
          (t) => t.title.toLowerCase().contains(
            (scenario['titleContains'] as String).toLowerCase(),
          ),
        );
        final received = await SourceAudioTransfer.receive(track, service);
        final tagged = await DownloadEnrichment.apply(
          track,
          received.$1,
          received.$2,
          service,
        );
        expect(mediaDigests(received.$1), isNotEmpty);
        expect(mediaDigests(tagged.bytes), mediaDigests(received.$1));
        final file = File('${temp.path}/download.m4a');
        await file.writeAsBytes(tagged.bytes);
        final embedded = EmbeddedLyrics.read(file);
        expect(embedded, isNotNull, reason: tagged.notice);
        final lyrics = Lyrics.parse(embedded!);
        expect(lyrics.lines, isNotEmpty, reason: tagged.notice);
        await audio.configureSession();
        await audio.setAppVolume(.03);
        await audio.select([
          Track(id: file.path, title: 'Comprobación', folder: '.'),
        ], 0);
        final deadline = DateTime.now().add(const Duration(seconds: 20));
        while (audio.player.position < const Duration(seconds: 2) &&
            DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        expect(
          audio.player.position,
          greaterThanOrEqualTo(const Duration(seconds: 2)),
          reason: audio.lastPlaybackError,
        );
        final cue = lyrics.lines.first.time + const Duration(milliseconds: 100);
        await audio.seek(cue);
        expect(lyrics.activeAt(cue), greaterThanOrEqualTo(0));
        final report = {
          'lines': lyrics.lines.length,
          'embeddedSyncedLyrics': true,
          'nativePlayback': true,
          'seekToTimedCue': true,
          'audioBytesPreservedByTagger': true,
        };
        await File.fromUri(base.uri.resolve(scenario['report'] as String))
            .writeAsString(jsonEncode(report));
      } finally {
        await audio.close();
        programs.dispose();
        await temp.delete(recursive: true);
      }
    });
  }, timeout: const Timeout(Duration(minutes: 6)));
}
