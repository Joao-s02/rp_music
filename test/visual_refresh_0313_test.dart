import 'dart:io';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/album_detail_view.dart';
import 'package:rp_music/app/music_theme.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/pulse_surface.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show MemoryStore, FakePlayer;

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

void main() {
  for (final width in [360.0, 1280.0]) {
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
      await tester.tap(find.byTooltip('Vista de biblioteca'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Álbumes').last);
      expect(back, isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
    });
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
