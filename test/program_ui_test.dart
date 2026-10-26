import 'dart:convert';
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
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer;
import 'program_system_test.dart' show Registry;

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
    testWidgets('biblioteca programable usable y modo seguro a $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final programs = ProgramController(Registry());
      await tester.runAsync(() async {
        final package = ProgramPackage.parse(
          Map<String, dynamic>.from(
            jsonDecode(
              await File(
                'examples/extensions/programables/biblioteca-viva.rpmx',
              ).readAsString(),
            ) as Map,
          ),
        );
        await programs.install(package, package.permissions);
      });
      final library = LibraryController(Registry(), MusicFiles())
        ..loading = false
        ..root = '/synthetic'
        ..tracks = [
          const Track(
            id: '/a.mp3',
            title: 'Prueba de extensión A',
            artist: 'Uno',
            album: 'Álbum',
            folder: 'Rock',
            durationMs: 120000,
          ),
          const Track(
            id: '/b.mp3',
            title: 'Prueba de extensión B',
            artist: 'Dos',
            album: 'Otro',
            folder: 'Pop',
            durationMs: 240000,
          ),
        ];
      library.attachPrograms(programs);
      final audio = MusicHandler(player: FakePlayer());
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MusicApp(library: library, audio: audio),
        ),
      );
      for (var i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)),
        );
        if (find.text('2 canciones').evaluate().isNotEmpty) break;
      }
      expect(find.text('Biblioteca viva'), findsOneWidget);
      expect(find.text('2 canciones'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Reproducir resultados'),
            )
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
      if (Platform.environment['RP_UI_SNAPSHOTS'] == '1') {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('design/verification/program-library-${width.toInt()}.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.ensureVisible(find.text('Crear lista automática'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crear lista automática'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Mi automática');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();
      expect(library.playlists['Mi automática'], ['/a.mp3', '/b.mp3']);
      await tester.tap(find.text('Listas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mi automática'));
      await tester.pumpAndSettle();
      expect(find.text('Lista automática · activa'), findsOneWidget);
      await tester.tap(find.text('Cambiar carátula'));
      await tester.pumpAndSettle();
      expect(find.text('Elegir imagen propia'), findsOneWidget);
      await tester.tap(find.text('Usar mosaico automático'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Extensiones'));
      await tester.pumpAndSettle();
      expect(find.text('Instalar Biblioteca viva'), findsNothing);
      await tester.tap(find.text('Explorar repositorio'));
      await tester.pumpAndSettle();
      expect(find.text('Repositorio de extensiones'), findsOneWidget);
      expect(
        find.widgetWithText(
          TextField,
          'https://github.com/Joao-s02/rp-music-extensions',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Quién controla cada función'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Interfaz base'),
        350,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interfaz base'));
      await tester.pumpAndSettle();
      expect(programs.owner('library'), isNull);
      await tester.scrollUntilVisible(
        find.text('Volver a la base · modo seguro'),
        -350,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Volver a la base · modo seguro'));
      await tester.pumpAndSettle();
      expect(programs.owner('library'), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(audio.close);
      library.dispose();
      programs.dispose();
    });
  }
}
