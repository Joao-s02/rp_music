import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:crypto/crypto.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/mp4_album_artist.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/program_runtime.dart';
import 'package:rp_music/extensions/extension_http_transport.dart';
import 'package:rp_music/sources/extension_source_service.dart';
import 'package:rp_music/sources/download_context.dart';
import 'package:rp_music/sources/album_download.dart';
import 'package:rp_music/sources/artist_portraits.dart';

class VisibleRuntime extends ProgramRuntime {
  @override
  Future<Map<String, dynamic>> execute(
    String source,
    Map<String, dynamic> input, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    try {
      return await super.execute(source, input, timeout: timeout);
    } catch (error) {
      stdout.writeln('Runtime ${input['operation']}/${input['stage']}: $error');
      rethrow;
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'álbum remoto completo exporta archivos con una identidad coherente',
    (tester) async {
      await tester.runAsync(() async {
        const path = String.fromEnvironment('RP_ALBUM_SCENARIO');
        expect(
          path,
          isNotEmpty,
          reason: 'Supply an external RP_ALBUM_SCENARIO file.',
        );
        final scenario = jsonDecode(await File(path).readAsString()) as Map;
        final scenarioRoot = File(path).absolute.parent.parent;
        final directory = await Directory.systemTemp.createTemp(
          'rp_album_native_',
        );
        final programs = ProgramController(
          LocalStore(Directory('${directory.path}/registry')),
          runtime: VisibleRuntime(),
        );
        try {
          final package = ProgramPackage.parse(
            jsonDecode(
              await File.fromUri(
                scenarioRoot.uri.resolve(scenario['package'] as String),
              ).readAsString(),
            ) as Map<String, dynamic>,
          );
          programs.installed[package.id] = InstalledProgram(
            package,
            package.permissions,
            enabled: true,
          );
          programs.owners['source'] = package.id;
          final service = ExtensionSourceService(
            programs,
            transport: (request, package) async {
              try {
                return await ExtensionHttpTransport.request(request, package);
              } on SocketException {
                await Future<void>.delayed(const Duration(seconds: 1));
                return ExtensionHttpTransport.request(request, package);
              } on TimeoutException {
                await Future<void>.delayed(const Duration(seconds: 1));
                return ExtensionHttpTransport.request(request, package);
              }
            },
          );
          final search = await service.explore(
            package.id,
            query: scenario['query'] as String,
            kind: 'album',
          );
          expect(search.entities, isNotEmpty);
          final selected = search.entities.firstWhere((e) => e.kind == 'album');
          var page = await service.explore(
            package.id,
            kind: 'album',
            entity: selected.id,
          );
          final originalCollection = page.collection;
          final tracks = [...page.tracks];
          final cursors = <String>{};
          while (page.cursor != null) {
            expect(cursors.add(page.cursor!), true);
            page = await service.explore(
              package.id,
              kind: 'album',
              entity: selected.id,
              cursor: page.cursor,
            );
            tracks.addAll(page.tracks);
            expect(cursors.length, lessThan(20));
          }
          expect(tracks, isNotEmpty);
          expect(
            tracks.length,
            lessThanOrEqualTo(scenario['maxTracks'] as int),
          );
          final collection = originalCollection ?? selected;
          final album = collection.title == 'Colección'
              ? selected.title
              : collection.title;
          final artist = collection.artist?.isNotEmpty == true
              ? collection.artist!
              : tracks.first.artist;
          final output = Directory('${directory.path}/audio')..createSync();
          final job = AlbumDownload(
            tracks,
            DownloadContext(
              album: album,
              albumArtist: artist,
              artwork: collection.artwork ?? selected.artwork,
            ),
            service,
            chooseFolder: () async => output.path,
          );
          job.addListener(
            () => stdout.writeln(
              'Álbum: ${job.saved} guardadas, ${job.failed} fallidas; ${job.failures.join('; ')}',
            ),
          );
          await job.run();
          expect(job.failed, 0, reason: job.failures.join(', '));
          expect(job.saved, tracks.length);
          final files = output.listSync().whereType<File>().toList();
          expect(files.length, tracks.length);
          final numbers = <int>{};
          final covers = <String>{};
          for (final file in files) {
            final tags = readMetadata(file, getImage: true);
            expect(tags.album, album);
            expect(mp4AlbumArtist(file), artist);
            expect(tags.trackTotal, tracks.length);
            numbers.add(tags.trackNumber!);
            expect(tags.pictures, isNotEmpty);
            covers.add(sha256.convert(tags.pictures.first.bytes).toString());
          }
          expect(covers.length, 1);
          expect(
            numbers,
            Set<int>.from(List.generate(tracks.length, (i) => i + 1)),
          );
          final portraits = ArtistPortraits(
            Directory('${directory.path}/portraits'),
          );
          await portraits.warm([artist], service);
          expect(portraits.image(artist), isNotNull);
          expect(await portraits.image(artist)!.length(), greaterThan(100));
          portraits.dispose();
          final offline = ArtistPortraits(
            Directory('${directory.path}/portraits'),
          );
          await offline.warm([artist], null);
          expect(offline.image(artist), isNotNull);
          offline.dispose();
          final report = {
            'album': album,
            'count': files.length,
            'allAlbumTagsEqual': true,
            'allAlbumArtistTagsEqual': true,
            'numberingVerified': true,
            'allEmbeddedCoversEqual': true,
            'artistPhotoCached': true,
            'artistPhotoReopenedOffline': true,
          };
          final reportFile = File.fromUri(
            scenarioRoot.uri.resolve(scenario['report'] as String),
          );
          await reportFile.parent.create(recursive: true);
          await reportFile.writeAsString(jsonEncode(report));
          job.dispose();
        } finally {
          programs.dispose();
          await directory.delete(recursive: true);
        }
      });
    },
    timeout: const Timeout(Duration(minutes: 12)),
  );
}
