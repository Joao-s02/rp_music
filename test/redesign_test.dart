import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer, MemoryStore;

class ArtworkFiles extends MusicFiles {
  @override
  Future<Uint8List?> artwork(String id) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    for (final entry in {
      'Inter': 'Inter',
      'Plus Jakarta Sans': 'PlusJakartaSans',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load('assets/fonts/${entry.value}.ttf'))).load();
    }
  });
  testWidgets('biblioteca vacía con búsqueda contraída se adapta a móvil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final library = LibraryController(MemoryStore(), ArtworkFiles())
      ..loading = false;
    final audio = MusicHandler(player: FakePlayer());
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MusicApp(library: library, audio: audio),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.byTooltip('Buscar'), findsOneWidget);
    expect(find.text('Tu biblioteca está en silencio'), findsOneWidget);
    expect(tester.takeException(), isNull);
    if (Platform.environment['RP_UI_SNAPSHOTS'] == '1') {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('design/verification').create(recursive: true);
        await File('design/verification/empty-0.2.4-mobile.png')
            .writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.tap(find.byTooltip('Buscar'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      true,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(audio.close);
    library.dispose();
  });
  for (final width in [360.0, 1280.0]) {
    testWidgets('álbumes y reproductor completo con texto ampliado a $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final tracks = List.generate(
        12,
        (i) => Track(
          id: '/music/$i.mp3',
          title: 'Canción $i',
          artist: 'Artista ${i ~/ 3}',
          album: 'Álbum ${i ~/ 3}',
          folder: '.',
        ),
      );
      final library = LibraryController(MemoryStore(), ArtworkFiles())
        ..loading = false
        ..root = '/Music'
        ..tracks = tracks;
      final audio = MusicHandler(player: FakePlayer());
      await audio.select(tracks, 0);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MusicApp(library: library, audio: audio),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Álbumes'));
      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
      expect(tester.takeException(), isNull);
      Future<void> snapshot(String name) async {
        if (Platform.environment['RP_UI_SNAPSHOTS'] != '1') return;
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('design/verification').create(recursive: true);
          await File('design/verification/$name.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await snapshot('albums-${width.toInt()}');
      await tester.tap(find.text('Álbum 0').first);
      await tester.pumpAndSettle();
      expect(find.text('Canción 0'), findsWidgets);
      if (width < 850) {
        await tester.tap(find.text('Canción 0').last);
      } else {
        await tester.tap(find.byTooltip('Abrir reproductor'));
      }
      await tester.pumpAndSettle();
      expect(find.text('Ahora suena'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await snapshot('player-${width.toInt()}');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(audio.close);
      library.dispose();
    });
  }
}
