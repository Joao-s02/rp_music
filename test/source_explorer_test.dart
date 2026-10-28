import 'package:flutter/material.dart';
import 'package:rp_music/sources/extension_source_view.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer;

import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/source_spec.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/sources/extension_source_service.dart';

import 'program_system_test.dart' show Registry;
import 'extension_source_test.dart' show cloudPackage;

void main() {
  test(
    'imported collection survives restart with repeats and remains independent',
    () async {
      final store = Registry();
      final library = LibraryController(store, MusicFiles());
      await library.initialize();
      const a = Track(
        id: 'rpmusic-source:test.cloud:a',
        title: 'A',
        folder: 'Cloud',
        sourceId: 'test.cloud',
      );
      const b = Track(
        id: 'rpmusic-source:test.cloud:b',
        title: 'B',
        folder: 'Cloud',
        sourceId: 'test.cloud',
      );
      await library.importSourcePlaylist('Copy', [a, b, a]);
      final restored = LibraryController(store, MusicFiles());
      await restored.initialize();
      expect(restored.playlistTracks('Copy').map((t) => t.title), [
        'A',
        'B',
        'A',
      ]);
      expect(restored.automaticPlaylist('Copy'), false);
      await restored.removeMissingFromPlaylist('Copy');
      expect(restored.playlists['Copy'], [a.id, b.id, a.id]);
      await restored.removeFromPlaylist('Copy', a.id);
      expect(restored.playlistTracks('Copy').map((t) => t.title), ['B', 'A']);
      await expectLater(
        restored.importSourcePlaylist('Copy', [a]),
        throwsFormatException,
      );
      await expectLater(
        restored.importSourcePlaylist('Invalid', [
          const Track(id: 'local', title: 'local', folder: ''),
        ]),
        throwsFormatException,
      );
      library.dispose();
      restored.dispose();
    },
  );
  testWidgets(
    'explorer opens album and imports detached copy on narrow screen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final base = cloudPackage();
      final package = ProgramPackage.parse({
        ...base.toJson(),
        'sourceConfig': {...base.sourceSpec!.toJson(), 'browse': true},
      });
      final programs = ProgramController(Registry());
      await tester.runAsync(
        () => programs.install(package, package.permissions),
      );
      final library = LibraryController(Registry(), MusicFiles());
      final audio = MusicHandler(player: FakePlayer());
      final service = PreviewService(programs);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExtensionSourceView(
              programs: programs,
              extensionId: package.id,
              audio: audio,
              library: library,
              service: service,
              embedded: true,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Demo');
      await tester.tap(find.byTooltip('Buscar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Album demo'));
      await tester.pumpAndSettle();
      expect(find.text('Importar copia'), findsOneWidget);
      await tester.tap(find.text('Importar copia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Importar'));
      await tester.pumpAndSettle();
      expect(library.playlistTracks('Album demo').single.title, 'Song');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await audio.close();
      library.dispose();
      programs.dispose();
    },
  );
  test('browse opt in is round tripped and legacy stays unchanged', () {
    final old = cloudPackage().sourceSpec!;
    expect(old.browse, false);
    expect(
      SourceSpec.parse({...old.toJson(), 'browse': true}).toJson()['browse'],
      true,
    );
    expect(
      () => SourceSpec.parse({...old.toJson(), 'browse': 'yes'}),
      throwsFormatException,
    );
  });
  test(
    'collection contract validates entities, pagination and revoked source',
    () async {
      final base = cloudPackage();
      final package = ProgramPackage.parse({
        ...base.toJson(),
        'sourceConfig': {...base.sourceSpec!.toJson(), 'browse': true},
        'source': r"""
import 'dart:convert';
String run(String request) {
 final Map<String,dynamic> input=jsonDecode(request) as Map<String,dynamic>;
 if(input['query']=='bad') return jsonEncode(<String,dynamic>{'entities':<dynamic>[<String,dynamic>{'id':'../bad','title':'Bad','kind':'album'}]});
 return jsonEncode(<String,dynamic>{'title':'Collection','collection':<String,dynamic>{'id':'collection','title':'Album','kind':'album'},'cursor':'next','entities':<dynamic>[<String,dynamic>{'id':'collection','title':'Album','kind':'album'}], 'tracks':<dynamic>[<String,dynamic>{'id':'a','title':'A'},<String,dynamic>{'id':'a','title':'A'}]});
}
""",
      });
      final programs = ProgramController(Registry());
      await programs.install(package, package.permissions);
      final service = ExtensionSourceService(programs, platform: 'android');
      final page = await service.explore(
        package.id,
        entity: 'collection',
        kind: 'album',
      );
      expect(page.tracks.length, 2);
      expect(page.cursor, 'next');
      expect(page.collection?.id, 'collection');
      expect(page.entities.single.title, 'Album');
      await expectLater(
        service.explore(package.id, query: 'bad'),
        throwsFormatException,
      );
      await programs.setEnabled(package.id, false);
      await expectLater(
        service.explore(package.id, entity: 'collection'),
        throwsFormatException,
      );
      programs.dispose();
    },
  );
}

class PreviewService extends ExtensionSourceService {
  PreviewService(super.programs) : super(platform: 'android');
  @override
  Future<SourcePage> explore(
    String id, {
    String query = '',
    String kind = 'song',
    String? entity,
    String? cursor,
  }) async {
    if (entity == null) {
      return const SourcePage(
        [],
        [SourceEntity('album', 'album', 'Album demo')],
        '',
        null,
      );
    }
    return const SourcePage(
      [
        Track(
          id: 'rpmusic-source:test.cloud:song',
          title: 'Song',
          folder: 'Cloud',
          sourceId: 'test.cloud',
        ),
      ],
      [],
      'Album demo',
      null,
    );
  }
}
