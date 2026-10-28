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

import 'playback_and_ui_test.dart' show MemoryStore, FakePlayer;

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
  for (final width in [360.0, 1280.0]) {
    testWidgets('lista con portada grande, acciones y pistas a $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      library.tracks = List.generate(
        5,
        (i) => Track(
          id: '/demo/$i.mp3',
          title: 'Canción ${i + 1}',
          artist: 'Artista',
          album: 'Noches',
          folder: '.',
          durationMs: 210000,
        ),
      );
      library.playlists['Noches favoritas'] = library.tracks
          .map((t) => t.id)
          .toList();
      final audio = MusicHandler(player: FakePlayer());
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MusicApp(library: library, audio: audio),
        ),
      );
      await tester.tap(find.text('Listas').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Noches favoritas').first);
      await tester.pumpAndSettle();
      expect(find.text('LISTA LOCAL'), findsOneWidget);
      expect(find.text('Reproducir'), findsWidgets);
      expect(find.text('Cambiar carátula'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('dist/0.3.11-preview/playlist-${width.toInt()}.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await audio.close();
      library.dispose();
    });
  }
}
