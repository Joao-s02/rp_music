import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rp_music/app/expanded_player.dart';
import 'package:rp_music/app/lyrics_view.dart';
import 'package:rp_music/app/lyric_stage.dart';
import 'package:rp_music/app/music_theme.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/playback_queue.dart';
import 'package:rp_music/app/now_playing_bars.dart';
import 'package:rp_music/app/volume_control.dart';
import 'package:rp_music/app/track_swipe.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/data/embedded_lyrics.dart';
import 'package:rp_music/domain/lyrics.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/lyrics/lyrics_controller.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/sources/download_enrichment.dart';

import 'playback_and_ui_test.dart' show FakePlayer, MemoryStore;
import 'lyrics_view_test.dart' show PositionPlayer;
import 'lyrics_and_tags_035_test.dart' show LyricsService, ReadOnlyFiles, box;
import 'program_system_test.dart' show Registry;
import 'extension_source_test.dart' show cloudPackage;

const verses =
    '[00:00]La noche deja luces\n[00:03]Donde el miedo se apagó\n[00:06]Mi voz cruza el cielo\n[00:09]Y vuelve a brillar';
Future<void> screenshot(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('dist/0.3.12-preview/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    for (final e in {
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
      'Inter': 'assets/fonts/Inter.ttf',
      'Plus Jakarta Sans': 'assets/fonts/PlusJakartaSans.ttf',
    }.entries) {
      await (FontLoader(e.key)..addFont(rootBundle.load(e.value))).load();
    }
  });
  test(
    'LRC real se incrusta y se conserva por delante de texto plano al reabrir',
    () async {
      final dir = await Directory.systemTemp.createTemp('rp_lyrics_0312_');
      final programs = ProgramController(Registry());
      final base = cloudPackage();
      final p = ProgramPackage.parse({
        ...base.toJson(),
        'permissions': [...base.permissions, 'storage.download'],
      });
      programs.installed[p.id] = InstalledProgram(
        p,
        p.permissions,
        enabled: true,
      );
      programs.owners['source'] = p.id;
      final service = LyricsService(programs)
        ..result = {
          'syncedLyrics': verses,
          'plainLyrics': 'Texto sin tiempos',
          'complete': true,
        };
      try {
        final audio = Uint8List.fromList([
          ...box('ftyp', ascii.encode('M4A \x00\x00\x00\x00M4A ')),
          ...box('moov', []),
          ...box('mdat', [1, 2, 3]),
        ]);
        final result = await DownloadEnrichment.apply(
          Track(
            id: 'rpmusic-source:${p.id}:a',
            sourceId: p.id,
            title: 'A',
            folder: '.',
          ),
          audio,
          'audio/mp4',
          service,
        );
        final file = File('${dir.path}/a.m4a')..writeAsBytesSync(result.bytes);
        expect(Lyrics.parse(EmbeddedLyrics.read(file)!).lines.length, 4);
        final track = Track(id: file.path, title: 'A', folder: '.');
        final files = ReadOnlyFiles()..text = 'Texto incrustado anterior';
        var controller = LyricsController(dir, files, programs);
        await controller.save(track.id, verses, track: track);
        controller.dispose();
        controller = LyricsController(dir, files, programs);
        expect(
          (await controller.ensure(track))!
              .activeAt(const Duration(seconds: 7)),
          2,
        );
        controller.dispose();
        expect(files.text, 'Texto incrustado anterior');
      } finally {
        programs.dispose();
        await dir.delete(recursive: true);
      }
    },
  );
  test('Enhanced LRC solo resalta palabras con tiempos explícitos', () {
    final parsed = Lyrics.parse('[00:01]<00:01>La <00:02>noche <00:03>brilla');
    expect(parsed.lines.single.text, 'La noche brilla');
    expect(parsed.lines.single.words.length, 3);
    expect(parsed.lines.single.words[1].time, const Duration(seconds: 2));
    final prefix = Lyrics.parse('[00:00]La <00:01>noche');
    expect(prefix.lines.single.leadingText, 'La ');
    expect(prefix.lines.single.text, 'La noche');
    expect(
      Lyrics.parse('[00:01]Sin palabras temporizadas').lines.single.words,
      isEmpty,
    );
  });
  for (final size in [
    const Size(360, 640),
    const Size(320, 568),
    const Size(800, 360),
    const Size(1280, 720),
  ]) {
    testWidgets('reproductor fijo, gesto diagonal y volumen oculto $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      final audio = MusicHandler(player: FakePlayer());
      await audio.select([
        const Track(
          id: '/a.mp3',
          title: 'Noche',
          artist: 'Luz Azul',
          album: 'Horizontes',
          folder: '.',
        ),
        const Track(id: '/b.mp3', title: 'Brillar', folder: '.'),
      ], 0);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: musicTheme(Brightness.dark, null),
            home: Scaffold(
              appBar: AppBar(title: const Text('Ahora suena')),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ExpandedPlayer(audio: audio, library: library),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(VolumeControl), findsNothing);
      expect(find.text('Archivo local'), findsNothing);
      expect(find.text('Audio local'), findsOneWidget);
      final cover = find.byType(TrackSwipe);
      final bounds = tester.getRect(cover);
      await tester.drag(cover, const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(tester.getRect(cover), bounds);
      await tester.drag(cover, const Offset(-170, 35));
      await tester.pumpAndSettle();
      expect(audio.index, 1);
      await tester.tap(find.byTooltip('Volumen'));
      await tester.pumpAndSettle();
      expect(find.byType(VolumeControl), findsOneWidget);
      Navigator.of(tester.element(find.byType(VolumeControl))).pop();
      await tester.pumpAndSettle();
      if (size.width == 360 || size.width == 1280) {
        await screenshot(tester, key, 'player-${size.width.toInt()}');
      }
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
    });
  }
  testWidgets(
    'cola abre centrada en la pista actual con anterior/siguiente e indicador vivo',
    (tester) async {
      final player = FakePlayer(liveStates: true);
      final audio = MusicHandler(player: player);
      await audio.select(
        List.generate(
          100,
          (i) => Track(
            id: '/song$i.mp3',
            title: 'Pista $i',
            artist: 'Artista',
            folder: '.',
          ),
        ),
        78,
      );
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: SizedBox(height: 500, child: PlaybackQueue(audio: audio)),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      for (final i in [77, 78, 79]) {
        expect(find.text('Pista $i').hitTestable(), findsOneWidget);
      }
      final queue = tester.getRect(
        find.byKey(const ValueKey('playback-queue')),
      );
      final current = tester.getRect(
        find.byKey(const ValueKey('queue-track-78')),
      );
      expect((queue.center.dy - current.center.dy).abs(), lessThan(3));
      final bar = find
          .descendant(
            of: find.byType(NowPlayingBars),
            matching: find.byType(Container),
          )
          .first;
      final before = tester.getSize(bar);
      await tester.pump(const Duration(milliseconds: 170));
      expect(tester.getSize(bar), isNot(before));
      await audio.pause();
      player.states.add(PlayerState(false, ProcessingState.ready));
      await tester.pump();
      final paused = tester.getSize(bar);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.getSize(bar), paused);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
    },
  );
  testWidgets(
    'letras vivas y escena grabable siguen reproducción y permiten ocultar controles',
    (tester) async {
      tester.view.physicalSize = const Size(360, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dir = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('rp_stage_'),
      ))!;
      final programs = ProgramController(Registry());
      final player = PositionPlayer();
      final audio = MusicHandler(player: player);
      await audio.select([
        const Track(
          id: '/demo.mp3',
          title: 'Luces de la noche',
          artist: 'Luz Azul',
          folder: '.',
        ),
      ], 0);
      final controller = LyricsController(dir, ReadOnlyFiles(), programs);
      await tester.runAsync(() => controller.save('/demo.mp3', verses));
      await tester.runAsync(() => controller.ensure(audio.tracks.single));
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: musicTheme(Brightness.dark, null),
            home: LyricsView(audio: audio, controller: controller),
          ),
        ),
      );
      for (var i = 0; i < 50; i++) {
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)),
        );
        if (find.text('La noche deja luces').evaluate().isNotEmpty &&
            controller.pending.isEmpty) {
          break;
        }
      }
      expect(controller.pending, isEmpty);
      player.positions.add(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Donde el miedo se apagó'), findsOneWidget);
      await screenshot(tester, key, 'lyrics-live-360');
      await tester.tap(find.byTooltip('Abrir escena'));
      await tester.pumpAndSettle();
      expect(find.byType(LyricScene), findsOneWidget);
      await tester.tapAt(const Offset(330, 500));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Salir de escena'), findsNothing);
      await screenshot(tester, key, 'lyrics-scene-360');
      player.positions.add(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(find.text('Mi voz cruza el cielo'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      controller.dispose();
      programs.dispose();
      await tester.runAsync(() => dir.delete(recursive: true));
    },
  );
}
