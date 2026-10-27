import 'dart:convert';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/extension_http_transport.dart';
import 'package:rp_music/sources/download_enrichment.dart';
import 'package:rp_music/sources/extension_source_service.dart';

/// Opt-in network contract verification using an external package and synthetic
/// audio. No provider-specific implementation or package is bundled here.
void main() {
  const packagePath = String.fromEnvironment('METADATA_PACKAGE');
  test(
    'paquete externo enriquece una copia con letras/portada sin cambiar audio',
    () async {
      final directory = await Directory.systemTemp.createTemp('rp_live_tags_');
      final programs = ProgramController(LocalStore(directory));
      try {
        final package = ProgramPackage.parse(
          jsonDecode(await File(packagePath).readAsString())
              as Map<String, dynamic>,
        );
        await programs.install(package, package.permissions);
        final service = ExtensionSourceService(
          programs,
          platform: const String.fromEnvironment(
            'METADATA_PLATFORM',
            defaultValue: 'android',
          ),
          transport: (request, package) async {
            final result = await ExtensionHttpTransport.request(
              request,
              package,
            );
            // ignore: avoid_print
            print(
              'METADATA_HTTP ${Uri.parse(request['url'] as String).host}: ${result['status']}',
            );
            return result;
          },
        );
        final original = File(const String.fromEnvironment('TAG_TEST_INPUT'));
        final bytes = await original.readAsBytes();
        final hash = sha256.convert(bytes);
        const key = String.fromEnvironment('METADATA_ID');
        final result = await DownloadEnrichment.apply(
          Track(
            id: ExtensionSourceService.trackId(package.id, key),
            sourceId: package.id,
            title: const String.fromEnvironment('METADATA_TITLE'),
            artist: const String.fromEnvironment('METADATA_ARTIST'),
            folder: 'Verificación',
            durationMs: const int.fromEnvironment('METADATA_DURATION_MS'),
            artwork: const String.fromEnvironment('METADATA_IMAGE'),
          ),
          bytes,
          'audio/mp4',
          service,
        );
        final output = File('${directory.path}/enriched.m4a');
        await output.writeAsBytes(result.bytes);
        final tags = readMetadata(output, getImage: true);
        // ignore: avoid_print
        print(
          'METADATA_STATE: ${result.notice}; fallos ${programs.installed[package.id]?.failures}; error ${programs.installed[package.id]?.error}',
        );
        expect(tags.lyrics, isNotNull);
        expect(tags.lyrics!.length, greaterThan(100));
        expect(tags.title, isNotEmpty);
        expect(tags.pictures, isNotEmpty);
        expect(tags.duration?.inMilliseconds, 4000);
        expect(sha256.convert(await original.readAsBytes()), hash);
        // Report only presence, never copyrighted lyric content.
        // ignore: avoid_print
        print(
          'LIVE_METADATA_OK: letra ${tags.lyrics!.length} caracteres; portada ${tags.pictures.first.bytes.length} bytes; álbum ${tags.album}; aviso parcial ${result.notice != null}',
        );
      } finally {
        programs.dispose();
        await directory.delete(recursive: true);
      }
    },
    skip: packagePath.isEmpty,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
