import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/track_swipe.dart';
import 'package:rp_music/data/download_tags.dart';
import 'package:rp_music/data/mp4_album_artist.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/sources/download_context.dart';
import 'package:rp_music/sources/artist_portraits.dart';
import 'package:rp_music/sources/album_download.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';

import 'program_system_test.dart' show Registry;
import 'extension_source_test.dart' show cloudPackage;
import 'lyrics_and_tags_035_test.dart' show LyricsService;
import 'playback_and_ui_test.dart' show FakePlayer;

Uint8List box(String name, List<int> body) => Uint8List.fromList([
  ...(ByteData(4)..setUint32(0, body.length + 8)).buffer.asUint8List(),
  ...latin1.encode(name),
  ...body,
]);

void main() {
  const track = Track(
    id: 'a',
    title: 'Elegida',
    artist: 'Artista',
    album: 'Original',
    folder: '.',
  );
  test('un resultado de otra edición no cambia la identidad ni numeración', () {
    final tags = DownloadContext.merge(track, {
      'title': 'Otra',
      'artist': 'Otro',
      'album': 'Recopilación',
      'albumArtist': 'Otro',
      'trackNumber': 15,
      'date': '2024',
    }, null);
    expect(tags, {
      'title': 'Elegida',
      'artist': 'Artista',
      'album': 'Original',
    });
    expect(
      DownloadContext.merge(const Track(id: 'b', title: 'B', folder: '.'), {
        'album': 'Al azar',
      }, null).containsKey('album'),
      false,
    );
  });
  test('dos archivos del álbum conservan el mismo álbum, artista y secuencia incrustada', () async {
    final dir = await Directory.systemTemp.createTemp('rp_album_tags_');
    try {
      final bytes = Uint8List.fromList([
        ...box('ftyp', ascii.encode('M4A \x00\x00\x00\x00M4A ')),
        ...box('moov', []),
        ...box('mdat', [1, 2, 3]),
      ]);
      const context = DownloadContext(
        album: 'Álbum elegido',
        albumArtist: 'Principal',
      );
      final files = <Track>[];
      for (var i = 0; i < 2; i++) {
        final tags = DownloadContext.merge(track, {
          'album': 'Otra edición',
          'trackNumber': 99,
        }, context.at(i + 1, 2));
        final f = File('${dir.path}/$i.m4a')
          ..writeAsBytesSync(DownloadTags.mp4(bytes, tags));
        final parsed = readMetadata(f);
        expect(parsed.album, 'Álbum elegido');
        expect(parsed.trackNumber, i + 1);
        expect(parsed.trackTotal, 2);
        expect(mp4AlbumArtist(f), 'Principal');
        files.add(
          Track(
            id: f.path,
            title: '$i',
            folder: '.',
            artist: i == 0 ? 'Solista' : 'Solista, Invitado',
            album: parsed.album!,
            albumArtist: mp4AlbumArtist(f)!,
          ),
        );
      }
      expect(files[0].albumKey, files[1].albumKey);
      expect(Track.fromJson(files.first.toJson()).albumArtist, 'Principal');
    } finally {
      await dir.delete(recursive: true);
    }
  });
  test(
    'fotos ya guardadas se recuperan sin fuente ni conexión tras reiniciar',
    () async {
      final dir = await Directory.systemTemp.createTemp('rp_artist_cache_');
      final cache = ArtistPortraits(dir);
      try {
        final file = File('${dir.path}/${cache.key('Artista')}.jpg')
          ..writeAsBytesSync([1, 2, 3]);
        await cache.warm(['Artista'], null);
        expect(cache.image('Artista')!.path, file.path);
        cache.dispose();
        final restarted = ArtistPortraits(dir);
        await restarted.warm(['Artista'], null);
        expect(restarted.image('Artista')!.readAsBytesSync(), [1, 2, 3]);
        restarted.dispose();
      } finally {
        await dir.delete(recursive: true);
      }
    },
  );
  testWidgets(
    'deslizar izquierda avanza, derecha vuelve y un roce corto no cambia',
    (tester) async {
      final audio = MusicHandler(player: FakePlayer());
      await audio.select([
        track,
        const Track(id: 'b', title: 'B', folder: '.'),
      ], 0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrackSwipe(
              audio: audio,
              child: const SizedBox(width: 300, height: 300),
            ),
          ),
        ),
      );
      final area = find.byType(TrackSwipe);
      await tester.drag(area, const Offset(-150, 0));
      await tester.pumpAndSettle();
      expect(audio.index, 1);
      await tester.drag(area, const Offset(150, 0));
      await tester.pumpAndSettle();
      expect(audio.index, 0);
      final gesture = await tester.startGesture(tester.getCenter(area));
      await gesture.moveBy(const Offset(-12, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(audio.index, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      await audio.close();
    },
  );
  test('cola de álbum conserva archivos previos, continúa tras fallo y cancela sin exportar la petición en curso', () async {
    final dir = await Directory.systemTemp.createTemp('rp_album_queue_');
    final programs = ProgramController(Registry());
    final p = ProgramPackage.parse({
      ...cloudPackage().toJson(),
      'permissions': [...cloudPackage().permissions, 'storage.download'],
    });
    programs.installed[p.id] = InstalledProgram(
      p,
      p.permissions,
      enabled: true,
    );
    programs.owners['source'] = p.id;
    final service = LyricsService(programs)
      ..result = {
        'tags': {'album': 'Incorrecto'},
        'complete': false,
      };
    final tracks = List.generate(
      3,
      (i) => Track(
        id: 'rpmusic-source:${p.id}:$i',
        sourceId: p.id,
        title: 'Pista $i',
        artist: 'Artista',
        folder: '.',
      ),
    );
    final bytes = Uint8List.fromList([
      ...box('ftyp', ascii.encode('M4A \x00\x00\x00\x00M4A ')),
      ...box('moov', []),
      ...box('mdat', [1, 2, 3]),
    ]);
    const album = DownloadContext(album: 'Original', albumArtist: 'Artista');
    final previous = File('${dir.path}/01 - Original - Pista 0.m4a')
      ..writeAsBytesSync([9, 8, 7]);
    try {
      var failSecond = true;
      final received = <String>[];
      final job = AlbumDownload(
        tracks,
        album,
        service,
        chooseFolder: () async => dir.path,
        receive: (t, s) async {
          received.add(t.title);
          if (t.title == 'Pista 1' && failSecond) {
            throw const FormatException('Unavailable');
          }
          return (bytes, 'audio/mp4');
        },
      );
      await job.run();
      expect(job.saved, 2);
      expect(job.failed, 1);
      expect(previous.readAsBytesSync(), [9, 8, 7]);
      final copies = dir
          .listSync()
          .whereType<File>()
          .where(
            (f) => f.uri.pathSegments.last != previous.uri.pathSegments.last,
          )
          .toList();
      expect(copies.length, 2);
      expect(copies.map((f) => readMetadata(f).album).toSet(), {'Original'});
      expect(copies.map((f) => readMetadata(f).trackNumber).toSet(), {1, 3});
      failSecond = false;
      received.clear();
      await job.retryFailed();
      expect(received, ['Pista 1']);
      expect(job.saved, 3);
      expect(job.failed, 0);
      expect(job.failures, isEmpty);
      expect(previous.readAsBytesSync(), [9, 8, 7]);
      job.dispose();
      final gate = Completer<(Uint8List, String)>();
      var started = false;
      final cancelled = AlbumDownload(
        tracks,
        album,
        service,
        chooseFolder: () async => dir.path,
        receive: (t, s) {
          started = true;
          return gate.future;
        },
      );
      final task = cancelled.run();
      while (!started) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      cancelled.cancel();
      gate.complete((bytes, 'audio/mp4'));
      await task;
      expect(cancelled.saved, 0);
      expect(cancelled.cancelled, true);
      expect(dir.listSync().length, 4);
      cancelled.dispose();
    } finally {
      programs.dispose();
      await dir.delete(recursive: true);
    }
  });
}
