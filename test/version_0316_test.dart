import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/data/download_tags.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/javascript_screen_service.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/app/album_detail_view.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/now_playing_bars.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'fragmented_download_tags_test.dart' show atom, fragment;
import 'javascript_network_test.dart' show networkPackage;
import 'program_system_test.dart' show Registry;
import 'playback_and_ui_test.dart' show FakePlayer, MemoryStore;

void main() {
  test('colaboraciones separadas y nombres sin duplicados por mayúsculas', () {
    const track = Track(
      id: '1',
      title: 'Song',
      folder: '.',
      artist: 'Ana y LUIS & ana, Luis',
    );
    expect(track.artists, ['Ana', 'LUIS']);
    expect(Track.artistKey(' LUIS  Miguel '), Track.artistKey('luis miguel'));
    expect(
      const Track(id: '2', title: '', folder: '.', artist: 'AC/DC').artists,
      ['AC/DC'],
    );
  });

  test(
    'etiquetado a disco conserva MP4 plano y fragmentado byte a byte',
    () async {
      final dir = await Directory.systemTemp.createTemp('rp_stream_tags_');
      addTearDown(() => dir.delete(recursive: true));
      for (final fragmented in [false, true]) {
        final original = Uint8List.fromList([
          ...atom('ftyp', ascii.encode('M4A ')),
          ...atom('moov', []),
          if (fragmented) ...fragment(),
          ...atom('mdat', List.generate(512, (i) => i % 256)),
        ]);
        final file = await File('${dir.path}/$fragmented.m4a')
            .writeAsBytes(original);
        final tagged = await DownloadTags.mp4File(file, {
          'title': 'Song',
          'album': 'Album',
        });
        expect(
          await tagged.readAsBytes(),
          DownloadTags.mp4(original, {'title': 'Song', 'album': 'Album'}),
        );
        expect(await file.readAsBytes(), original);
      }
    },
  );

  test(
    'archivo mayor de 64 MiB conserva el payload sin cargarlo completo',
    () async {
      final dir = await Directory.systemTemp.createTemp('rp_large_tags_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/large.m4a');
      final writer = await file.open(mode: FileMode.write);
      const size = 65 * 1024 * 1024;
      final prefix = [
        ...atom('ftyp', ascii.encode('M4A ')),
        ...atom('moov', []),
      ];
      await writer.writeFrom(prefix);
      final header = ByteData(8)..setUint32(0, size + 8);
      header.buffer.asUint8List().setRange(4, 8, ascii.encode('mdat'));
      await writer.writeFrom(header.buffer.asUint8List());
      await writer.setPosition(prefix.length + 8 + size - 1);
      await writer.writeByte(123);
      await writer.close();
      final tagged = await DownloadTags.mp4File(file, {'album': 'Large album'});
      final start = prefix.length + 8;
      expect(
        await sha256.bind(tagged.openRead(start, start + size)).first,
        await sha256.bind(file.openRead(start, start + size)).first,
      );
      expect(await tagged.length(), greaterThan(await file.length()));
    },
  );

  test('caché pública evita segunda red y se invalida con permisos', () async {
    final programs = ProgramController(Registry());
    addTearDown(programs.dispose);
    final p = networkPackage(
      code: "function run(i){if(i.stage==='start')return {request:{url:'https://example.com/page',cacheSeconds:60},next:'result'};return {view:{type:'text',text:'ok'}};}",
    );
    await programs.install(p, p.permissions);
    var calls = 0;
    final phases = <String>[];
    final service = JavascriptScreenService(
      programs,
      onTiming: (phase, ms) => phases.add(phase),
      transport: (_, p) async {
        calls++;
        return {'status': 200, 'body': '{}'};
      },
    );
    await service.run(p.id, {'action': 'search'});
    await service.run(p.id, {'action': 'back'});
    expect(calls, 1);
    expect(phases, contains('red desde caché'));
    await programs.setGrants(p.id, {'navigation.add'});
    await expectLater(
      service.run(p.id, {'action': 'back'}),
      throwsFormatException,
    );
    await programs.setGrants(p.id, p.permissions.toSet());
    await programs.setEnabled(p.id, true);
    await service.run(p.id, {'action': 'back'});
    expect(calls, 2);
  });

  testWidgets(
    'búsqueda de álbum conserva cabecera y anima solo la pista actual',
    (tester) async {
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      final player = FakePlayer();
      final audio = MusicHandler(player: player);
      const tracks = [
        Track(id: 'a.mp3', title: 'Primera', album: 'Mi álbum', folder: '.'),
        Track(id: 'b.mp3', title: 'Segunda', album: 'Mi álbum', folder: '.'),
      ];
      await audio.select(tracks, 1);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: AlbumDetailView(
                tracks: tracks,
                audio: audio,
                library: library,
                onBack: () {},
                onSave: () {},
                menu: (_) => const SizedBox(),
                query: 'segunda',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mi álbum'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Segunda'), 250);
      expect(find.text('Primera'), findsNothing);
      expect(find.byType(NowPlayingBars), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
    },
  );
}
