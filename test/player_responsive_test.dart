import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rp_music/app/music_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer, MemoryStore;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
  for (final size in [
    const Size(360, 640),
    const Size(320, 568),
    const Size(800, 360),
    const Size(1280, 720),
  ]) {
    testWidgets('controles visibles sin desplazar en $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      final audio = MusicHandler(player: FakePlayer());
      await audio.select([
        const Track(id: '/a.mp3', title: 'Canción', folder: '.'),
      ], 0);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            theme: musicTheme(Brightness.dark, null),
            home: Scaffold(
              body: PlayerPanel(audio: audio, library: library),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        size.width >= 850
            ? find.byTooltip('Abrir reproductor')
            : find.text('Canción').first,
      );
      await tester.pumpAndSettle();
      for (final tip in ['Anterior', 'Siguiente', 'Pausar']) {
        final target = find.byTooltip(tip).last;
        expect(target.hitTestable(), findsOneWidget);
        final bounds = tester.getRect(target);
        expect(bounds.bottom, lessThanOrEqualTo(size.height));
        expect(bounds.top, greaterThanOrEqualTo(0));
      }
      expect(tester.takeException(), isNull);
      if (size.width == 360 || size.width == 1280) {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'design/verification/player-0.3.4-${size.width.toInt()}.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
    });
  }
}
