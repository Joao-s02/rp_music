import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/album_detail_view.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/extension_view_cache.dart';
import 'package:rp_music/extensions/javascript_screen_view.dart';

import 'javascript_extensions_test.dart' show jsPackage;

import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/sources/extension_source_service.dart';
import 'package:rp_music/sources/extension_source_view.dart';

import 'extension_source_test.dart' show cloudPackage;
import 'playback_and_ui_test.dart' show MemoryStore, FakePlayer;
import 'program_system_test.dart' show Registry;

class BrowseFixture extends ExtensionSourceService {
  BrowseFixture(super.programs) : super(platform: 'windows');
  int calls = 0;
  @override
  Future<SourcePage> explore(
    String id, {
    String query = '',
    String kind = 'song',
    String? entity,
    String? cursor,
  }) async {
    calls++;
    if (entity == 'artist') {
      return const SourcePage(
        [],
        [SourceEntity('album', 'album', 'Álbum de prueba')],
        'Artista de prueba',
        null,
        SourceEntity('artist', 'artist', 'Artista de prueba'),
      );
    }
    if (entity == 'album') {
      return SourcePage(
        List.generate(
          30,
          (i) => Track(
            id: 'rpmusic-source:test.cloud:$i',
            title: 'Tema $i',
            artist: 'Artista',
            folder: '.',
            sourceId: 'test.cloud',
          ),
        ),
        [],
        'Álbum de prueba',
        null,
        const SourceEntity('album', 'album', 'Álbum de prueba'),
      );
    }
    return const SourcePage(
      [],
      [SourceEntity('artist', 'artist', 'Artista de prueba')],
      '',
      null,
    );
  }
}

class ScreenFixtureController extends ProgramController {
  ScreenFixtureController() : super(Registry());
  int calls = 0;
  @override
  Future<Map<String, dynamic>?> invoke(
    String id,
    String event,
    Map<String, dynamic> snapshot, {
    bool Function()? active,
  }) async {
    calls++;
    return {
      'view': {
        'type': 'column',
        'children': [
          {'type': 'input', 'id': 'query', 'value': '', 'label': 'Buscar'},
          {
            'type': 'text',
            'text': snapshot['action'] == 'search'
                ? 'Resultado conservado'
                : 'Inicio',
          },
          {'type': 'button', 'label': 'Consultar', 'action': 'search'},
        ],
      },
    };
  }
}

void main() {
  test('session cache bounds entries and rejects changed package or permission revision', () {
    final cache = ExtensionViewCache();
    final owner = Object();
    for (var i = 0; i < 10; i++) {
      cache.save('$i', owner, 1, 'value $i');
    }
    expect(cache.read<String>('0', owner, 1), isNull);
    expect(cache.read<String>('9', owner, 1), 'value 9');
    expect(cache.read<String>('9', Object(), 1), isNull);
    cache.save('x', owner, 1, 'private');
    expect(cache.read<String>('x', owner, 2), isNull);
  });

  testWidgets(
    'JS search state and draft survive navigation without invoking open again',
    (tester) async {
      final programs = ScreenFixtureController();
      final package = jsPackage();
      await tester.runAsync(
        () => programs.install(package, package.permissions),
      );
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      final audio = MusicHandler(player: FakePlayer());
      Widget screen() => MaterialApp(
        home: Scaffold(
          body: JavascriptScreenView(
            programs: programs,
            extensionId: package.id,
            library: library,
            audio: audio,
          ),
        ),
      );
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Consulta reciente');
      await tester.tap(find.text('Consultar'));
      await tester.pumpAndSettle();
      expect(find.text('Resultado conservado'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Borrador reciente');
      final calls = programs.calls;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      expect(find.text('Resultado conservado'), findsOneWidget);
      expect(find.text('Borrador reciente'), findsOneWidget);
      expect(programs.calls, calls);
      await programs.setGrants(package.id, {});
      await tester.pumpAndSettle();
      expect(find.text('Resultado conservado'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(audio.close);
      library.dispose();
      programs.dispose();
    },
  );

  for (final count in [500, 900]) {
    test(
      'discovery and unchanged metadata cache remain complete for $count tracks',
      () async {
        final directory = await Directory.systemTemp.createTemp('rp0318_scan_');
        addTearDown(() => directory.delete(recursive: true));
        final cached = <Track>[];
        for (var i = 0; i < count; i++) {
          final file = await File(
            '${directory.path}${Platform.pathSeparator}track$i.mp3',
          ).writeAsBytes([0]);
          final stat = await file.stat();
          cached.add(
            Track(
              id: file.path,
              title: 'Cached $i',
              folder: '.',
              size: stat.size,
              modifiedMs: stat.modified.millisecondsSinceEpoch,
              metadataLoaded: true,
              metadataVersion: 2,
            ),
          );
        }
        final events = <ScanProgress>[];
        final result = scanDirectory(
          directory.path,
          cached: cached,
          onProgress: events.add,
        );
        final discovery = events.where((e) => e.discovery).toList();
        expect(discovery.length, greaterThan(1));
        expect(
          discovery.first.total,
          0,
        ); // Published before enumeration is complete.
        expect(discovery.first.append, false);
        expect(discovery.skip(1).every((e) => e.append), true);
        expect(discovery.last.total, count);
        expect(
          discovery.expand((e) => e.batch).map((t) => t.id).toSet().length,
          count,
        );
        expect(result.tracks.length, count);
        expect(result.tracks.every((t) => t.title.startsWith('Cached')), true);
        expect(result.skipped, 0);
        expect(events.where((e) => !e.discovery).length, lessThan(12));
      },
    );
  }

  testWidgets(
    'phone Back closes local album detail and keeps the home screen',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false
        ..root = '/synthetic'
        ..tracks = [
          const Track(
            id: 'rpmusic-source:synthetic:song',
            title: 'Tema local',
            album: 'Álbum local',
            folder: '.',
          ),
        ];
      final audio = MusicHandler(player: FakePlayer());
      await tester.pumpWidget(MusicApp(library: library, audio: audio));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Álbumes').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Álbum local').first);
      await tester.tap(find.text('Álbum local').first);
      await tester.pumpAndSettle();
      expect(find.byType(AlbumDetailView), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AlbumDetailView), findsNothing);
      expect(find.byType(MusicHome), findsOneWidget);
      expect(find.text('Álbum local'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(audio.close);
      library.dispose();
    },
  );

  for (final width in [360.0, 1280.0]) {
    testWidgets('browse, scroll, Back and session restore at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final programs = ProgramController(Registry());
      final raw = cloudPackage().toJson();
      final package = ProgramPackage.parse({
        ...raw,
        'sourceConfig': {...raw['sourceConfig'] as Map, 'browse': true},
      });
      await tester.runAsync(
        () => programs.install(package, package.permissions),
      );
      await programs.choose('source', package.id);
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      final audio = MusicHandler(player: FakePlayer());
      final service = BrowseFixture(programs);
      Widget screen() => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 800),
            textScaler: TextScaler.linear(1.6),
          ),
          child: Scaffold(
            body: ExtensionSourceView(
              programs: programs,
              extensionId: package.id,
              library: library,
              audio: audio,
              service: service,
              embedded: true,
            ),
          ),
        ),
      );
      await tester.pumpWidget(screen());
      await tester.enterText(find.byType(TextField), 'prueba');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Artista de prueba').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Álbum de prueba').first);
      await tester.pumpAndSettle();
      final scroll = find.byKey(const ValueKey('source-scroll'));
      await tester.drag(scroll, const Offset(0, -650));
      await tester.pumpAndSettle();
      expect(find.byType(TextField).hitTestable(), findsNothing);
      expect(find.textContaining('Tema ').hitTestable(), findsWidgets);
      expect(tester.takeException(), isNull);
      final previousOffset = tester.widget<ListView>(scroll).controller!.offset;
      final calls = service.calls;
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Biblioteca local'))),
      );
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      expect(service.calls, calls);
      expect(
        tester.widget<ListView>(scroll).controller!.offset,
        closeTo(previousOffset, 1),
      );
      tester.widget<ListView>(scroll).controller!.jumpTo(0);
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'prueba');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Álbum de prueba'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Artista de prueba'), findsOneWidget);
      expect(service.calls, calls);
      await programs.setGrants(package.id, {});
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await programs.setGrants(package.id, package.permissions);
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('Artista de prueba'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(audio.close);
      library.dispose();
      programs.dispose();
    });
  }
}
