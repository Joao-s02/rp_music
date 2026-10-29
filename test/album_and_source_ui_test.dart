import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/album_detail_view.dart';
import 'package:rp_music/app/music_theme.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/sources/extension_source_view.dart';
import 'package:rp_music/sources/extension_source_service.dart';

import 'playback_and_ui_test.dart' show MemoryStore, FakePlayer;
import 'program_system_test.dart' show Registry;
import 'extension_source_test.dart' show cloudPackage;

void main() {
  setUpAll(() async {
    for (final entry in {
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
      'Inter': 'assets/fonts/Inter.ttf',
      'Plus Jakarta Sans': 'assets/fonts/PlusJakartaSans.ttf',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load(entry.value))).load();
    }
  });
  const tracks = [
    Track(
      id: '/demo/01.flac',
      title: 'Prism Light',
      artist: 'Solar Drift',
      album: 'Neon Horizons',
      folder: '.',
      durationMs: 222000,
    ),
    Track(
      id: '/demo/02.flac',
      title: 'Neon Horizons',
      artist: 'Solar Drift',
      album: 'Neon Horizons',
      folder: '.',
      durationMs: 258000,
    ),
  ];
  for (final width in [360.0, 1280.0]) {
    testWidgets('álbum, cola y acciones sin desbordes a $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      final audio = MusicHandler(player: FakePlayer());
      var saved = false;
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: musicTheme(Brightness.dark, null),
          home: Scaffold(
            body: RepaintBoundary(
              key: boundary,
              child: AlbumDetailView(
                tracks: tracks,
                audio: audio,
                library: library,
                onBack: () {},
                onSave: () => saved = true,
                menu: (_) => IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('● ÁLBUM LOCAL'), findsOneWidget);
      expect(find.text('24b Hi-Res'), findsNothing);
      await tester.ensureVisible(find.text('Reproducir'));
      await tester.tap(find.text('Reproducir'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(audio.tracks.length, 2);
      expect(audio.shuffle, isFalse);
      await tester.tap(find.byTooltip('Añadir álbum a una lista'));
      expect(saved, isTrue);
      await tester.ensureVisible(find.byKey(const ValueKey('album-queue')));
      await tester.tap(find.byKey(const ValueKey('album-queue')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('design/verification/album-0.3.2-${width.toInt()}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
    });
  }
  testWidgets(
    'fuente respeta barra del sistema y muestra nombre del servicio',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final programs = ProgramController(Registry());
      final p = cloudPackage();
      await tester.runAsync(() => programs.install(p, p.permissions));
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      final audio = MusicHandler(player: FakePlayer());
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 800),
              padding: EdgeInsets.only(bottom: 48),
            ),
            child: ExtensionSourceView(
              programs: programs,
              extensionId: p.id,
              audio: audio,
              library: library,
              service: ExtensionSourceService(programs, platform: 'android'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final player = find.byType(PlayerPanel);
      expect(tester.getBottomRight(player).dy, lessThanOrEqualTo(752));
      expect(find.text('Nube de prueba'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
      programs.dispose();
    },
  );
  testWidgets(
    'acceso de extensión abre su pantalla y desaparece al desactivar',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final programs = ProgramController(Registry());
      final package = cloudPackage();
      await tester.runAsync(
        () => programs.install(package, package.permissions),
      );
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      library.attachPrograms(programs);
      final audio = MusicHandler(player: FakePlayer());
      await tester.pumpWidget(MusicApp(library: library, audio: audio));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      await tester.tap(find.text('Explorar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.cloud_outlined).last);
      await tester.pumpAndSettle();
      expect(find.byType(ExtensionSourceView), findsOneWidget);
      expect(find.byType(PlayerPanel), findsOneWidget);
      await tester.runAsync(() => programs.setEnabled(package.id, false));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      expect(find.byType(ExtensionSourceView), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
      programs.dispose();
    },
  );
}
