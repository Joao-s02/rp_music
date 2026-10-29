import 'package:rp_music/sources/extension_source_view.dart';
import 'package:rp_music/sources/extension_source_service.dart';
import 'package:rp_music/sources/download_context.dart';
import 'package:rp_music/data/download_tags.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import 'dart:convert';

import 'lyrics_and_tags_035_test.dart' show box;

import 'dart:io';

import 'package:rp_music/extensions/program_package.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/album_detail_view.dart';
import 'package:rp_music/app/music_theme.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/pulse_surface.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_manager_view.dart';
import 'package:rp_music/extensions/extension_emblem.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show MemoryStore, FakePlayer;
import 'program_system_test.dart' show Registry;
import 'extension_source_test.dart' show cloudPackage;

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('dist/0.3.13-preview/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

class PreviewSource extends ExtensionSourceService {
  PreviewSource(super.programs) : super(platform: 'windows');
  @override
  Future<SourcePage> explore(
    String id, {
    String query = '',
    String kind = 'song',
    String? entity,
    String? cursor,
  }) async => SourcePage(
    [
      Track(
        id: 'rpmusic-source:$id:one',
        title: 'Luces de medianoche',
        artist: 'Solar Drift',
        album: 'Nocturnal Pulse',
        folder: '.',
        sourceId: id,
      ),
      Track(
        id: 'rpmusic-source:$id:two',
        title: 'Horizonte violeta',
        artist: 'Solar Drift',
        album: 'Nocturnal Pulse',
        folder: '.',
        sourceId: id,
      ),
    ],
    const [],
    'Resultados',
    null,
  );
}

void main() {
  test(
    'metadatos reintentan una conexión transitoria y conservan el resultado',
    () async {
      final programs = ProgramController(Registry());
      final p = ProgramPackage.parse({
        ...cloudPackage().toJson(),
        'source': r"""
import 'dart:convert';
String run(String request) { final input=jsonDecode(request); if(input['stage']=='start') return jsonEncode({'request':{'url':'https://example.com/metadata'},'next':'done'}); return jsonEncode({'tags':{'album':'Recovered'},'complete':true}); }
""",
      });
      await programs.install(p, p.permissions);
      await programs.choose('source', p.id);
      var calls = 0;
      final service = ExtensionSourceService(
        programs,
        platform: 'windows',
        transport: (request, package) async {
          calls++;
          if (calls == 1) throw const SocketException('Transient test');
          return {'status': 200, 'body': '{}'};
        },
      );
      final result = await service.invoke(p.id, 'metadata', {});
      expect(calls, 2);
      expect(result['tags']['album'], 'Recovered');
      programs.dispose();
    },
  );
  test('álbum verificado se incrusta cuando la pista no traía álbum', () async {
    final dir = await Directory.systemTemp.createTemp('rp_album_0313_');
    try {
      final tags = DownloadContext.merge(
        const Track(id: 'a', title: 'Song', artist: 'Artist', folder: '.'),
        {
          'album': 'Original',
          'albumArtist': 'Artist',
          'albumVerified': true,
          'trackNumber': 3,
        },
        null,
      );
      final file = File('${dir.path}/song.m4a');
      file.writeAsBytesSync(
        DownloadTags.mp4(
          Uint8List.fromList([
            ...box('ftyp', ascii.encode('M4A \x00\x00\x00\x00M4A ')),
            ...box('moov', []),
            ...box('mdat', [1, 2, 3]),
          ]),
          tags,
        ),
      );
      expect(readMetadata(file).album, 'Original');
      expect(readMetadata(file).trackNumber, 3);
    } finally {
      await dir.delete(recursive: true);
    }
  });
  setUpAll(() async {
    for (final e in {
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
      'Inter': 'assets/fonts/Inter.ttf',
      'Plus Jakarta Sans': 'assets/fonts/PlusJakartaSans.ttf',
    }.entries) {
      await (FontLoader(e.key)..addFont(rootBundle.load(e.value))).load();
    }
  });
  for (final width in [360.0, 1280.0]) {
    testWidgets(
      'extensiones: consentimiento conjunto explícito y guardar parcial a $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final programs = ProgramController(Registry());
        final package = cloudPackage();
        programs.installed[package.id] = InstalledProgram(
          package,
          {},
          enabled: false,
        );
        final library = LibraryController(MemoryStore(), MusicFiles())
          ..loading = false;
        library.attachPrograms(programs);
        final audio = MusicHandler(player: FakePlayer());
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: musicTheme(Brightness.dark, null),
            home: Scaffold(
              body: RepaintBoundary(
                key: key,
                child: ProgramManagerView(library: library, audio: audio),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await capture(tester, key, 'extensions-${width.toInt()}');
        expect(find.byType(ExtensionEmblem), findsWidgets);
        await tester.ensureVisible(find.text('Permisos').first);
        await tester.tap(find.text('Permisos').first);
        await tester.pumpAndSettle();
        expect(
          tester
              .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
              .every((box) => box.value == false),
          isTrue,
        );
        await tester.tap(find.text('Guardar desactivada'));
        await tester.pumpAndSettle();
        expect(programs.installed[package.id]!.enabled, isFalse);
        await tester.tap(find.text('Permisos').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Aceptar todo e instalar'));
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 500)),
        );
        await tester.pumpAndSettle();
        expect(
          programs.installed[package.id]!.grants.containsAll(
            package.permissions,
          ),
          isTrue,
        );
        expect(programs.installed[package.id]!.enabled, isTrue);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(audio.close);
        library.dispose();
      },
    );
    testWidgets('álbum con funda RP y navegación sin desbordes a $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      final audio = MusicHandler(player: FakePlayer());
      final key = GlobalKey();
      var back = false;
      final tracks = List.generate(
        5,
        (i) => Track(
          id: '/demo/$i.flac',
          title: 'Horizonte ${i + 1}',
          artist: 'Solar Drift',
          album: 'Nocturnal Pulse',
          folder: '.',
          durationMs: 200000,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: musicTheme(Brightness.dark, null),
          home: Scaffold(
            body: RepaintBoundary(
              key: key,
              child: AlbumDetailView(
                tracks: tracks,
                audio: audio,
                library: library,
                onBack: () => back = true,
                onSave: () {},
                menu: (_) => const SizedBox(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await capture(tester, key, 'album-${width.toInt()}');
      expect(find.byType(PulseSurface), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Álbumes'));
      expect(back, isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
    });
  }
  for (final width in [320.0, 1280.0]) {
    testWidgets(
      'fuente genérica renovada: buscar y cambiar categoría con texto ampliado a $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final base = cloudPackage();
        final p = ProgramPackage.parse({
          ...base.toJson(),
          'sourceConfig': {
            ...base.toJson()['sourceConfig'] as Map,
            'browse': true,
          },
        });
        final programs = ProgramController(Registry());
        programs.installed[p.id] = InstalledProgram(
          p,
          p.permissions,
          enabled: true,
        );
        programs.owners['source'] = p.id;
        final library = LibraryController(MemoryStore(), MusicFiles())
          ..loading = false;
        library.attachPrograms(programs);
        final audio = MusicHandler(player: FakePlayer());
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: musicTheme(Brightness.dark, null),
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 800),
                textScaler: TextScaler.linear(width < 400 ? 1.6 : 1),
              ),
              child: Scaffold(
                body: RepaintBoundary(
                  key: key,
                  child: ExtensionSourceView(
                    programs: programs,
                    extensionId: p.id,
                    audio: audio,
                    library: library,
                    service: PreviewSource(programs),
                    embedded: true,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Luces');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        expect(find.text('Luces de medianoche'), findsOneWidget);
        await capture(tester, key, 'source-${width.toInt()}');
        await tester.tap(find.text('Artistas'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<ChoiceChip>(
                find.ancestor(
                  of: find.text('Artistas'),
                  matching: find.byType(ChoiceChip),
                ),
              )
              .selected,
          isTrue,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(audio.close);
        library.dispose();
        programs.dispose();
      },
    );
  }
  testWidgets(
    'movimiento reducido conserva superficie estática y no deja ticker',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: PulseSurface(child: SizedBox(width: 100, height: 100)),
          ),
        ),
      );
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
