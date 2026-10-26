import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/app_version.dart';
import 'package:rp_music/app/music_theme.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/domain/track_sort.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/updates/update_controller.dart';
import 'package:rp_music/updates/update_widgets.dart';

import 'playback_and_ui_test.dart' show FakePlayer, MemoryStore;
import 'update_controller_test.dart'
    show fixture, FakePlatform, FakeClient, FakeResponse;

class WriteFiles extends MusicFiles {
  bool granted = false;
  int requests = 0, deletes = 0;
  @override
  Future<bool> ensureWritable(String root) async {
    requests++;
    return granted;
  }

  @override
  Future<void> delete(String id) async {
    deletes++;
  }
}

const a = Track(
  id: '/z.mp3',
  title: 'Árbol',
  artist: 'Zulu',
  album: 'B',
  folder: '.',
  durationMs: 1000,
  modifiedMs: 50,
  size: 10,
);
const b = Track(
  id: '/a.mp3',
  title: 'Barco',
  artist: 'Alfa',
  album: 'A',
  folder: '.',
  durationMs: 2000,
  modifiedMs: 10,
  size: 20,
);
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
  test('orden por siete criterios, dirección y catálogo sin mutar', () {
    final original = [b, a];
    for (final sort in TrackSort.values) {
      final forward = sortTracks(original, sort, true);
      final backward = sortTracks(original, sort, false);
      expect(backward, forward.reversed.toList());
    }
    expect(sortTracks(original, TrackSort.title, true).first.id, a.id);
    expect(sortTracks(original, TrackSort.artist, true).first.id, b.id);
    expect(sortTracks(original, TrackSort.modified, true).first.id, b.id);
    expect(sortTracks(original, TrackSort.filename, true).first.id, b.id);
    expect(original, [b, a]);
  });
  test('orden y dirección sobreviven reinicio', () async {
    final directory = await Directory.systemTemp.createTemp('rp_sort_');
    try {
      final library = LibraryController(LocalStore(directory), MusicFiles());
      await library.setSort(TrackSort.duration);
      await library.toggleSortDirection();
      final restored = LibraryController(LocalStore(directory), MusicFiles());
      await restored.initialize();
      expect(restored.sort, TrackSort.duration);
      expect(restored.ascending, false);
      library.dispose();
      restored.dispose();
    } finally {
      await directory.delete(recursive: true);
    }
  });
  test(
    'solicitar escritura antes de detener y borrar; cancelar conserva todo',
    () async {
      final files = WriteFiles();
      final library = LibraryController(MemoryStore(), files)
        ..root = 'content://root'
        ..tracks = [a]
        ..favorites = {a.id};
      var stopped = false;
      expect(
        await library.deleteTrack(
          a,
          beforeDelete: () async {
            stopped = true;
          },
        ),
        false,
      );
      expect(stopped, false);
      expect(files.deletes, 0);
      expect(library.tracks, [a]);
      files.granted = true;
      expect(
        await library.deleteTrack(
          a,
          beforeDelete: () async {
            stopped = true;
          },
        ),
        true,
      );
      expect(stopped, true);
      expect(files.deletes, 1);
      expect(files.requests, 2);
      library.dispose();
    },
  );
  test('widget puede pedir reproducir antes de restaurar biblioteca', () async {
    final ready = Completer<void>();
    late MusicHandler handler;
    handler = MusicHandler(
      player: FakePlayer(),
      onEmptyPlay: () async {
        await ready.future;
        if (handler.index < 0) await handler.select([a, b], 0, autoplay: false);
      },
    );
    final playing = handler.play();
    expect(handler.player.playing, false);
    ready.complete();
    await playing;
    expect(handler.player.playing, true);
    expect(handler.mediaItem.value!.id, a.id);
    await handler.close();
  });
  test('Windows descarga ZIP verificado desde la app', () async {
    final directory = await Directory.systemTemp.createTemp('rp_zip_');
    final bytes = [1, 2, 3, 4];
    var calls = 0;
    final updates = UpdateController(
      LocalStore(directory),
      platform: FakePlatform(directory),
      android: false,
      clientFactory: () => FakeClient(
        calls++ == 0
            ? FakeResponse([
                utf8.encode(
                  jsonEncode([
                    fixture(digest: sha256.convert(bytes).toString()),
                  ]),
                ),
              ])
            : FakeResponse([bytes]),
      ),
    );
    try {
      await updates.check(manual: true);
      await updates.download();
      expect(updates.downloaded!.path, endsWith('.zip'));
      expect(await updates.downloaded!.readAsBytes(), bytes);
    } finally {
      updates.dispose();
      await directory.delete(recursive: true);
    }
  });
  testWidgets(
    'oferta centrada muestra versiones y descarga; después permite volver',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final screenshotKey = GlobalKey();
      final directory = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('rp_dialog_'),
      ))!;
      final bytes = [1, 2, 3, 4];
      var calls = 0;
      final updates = UpdateController(
        MemoryStore(),
        platform: FakePlatform(directory),
        android: true,
        clientFactory: () => FakeClient(
          calls++ == 0
              ? FakeResponse([
                  utf8.encode(
                    jsonEncode([
                      fixture(digest: sha256.convert(bytes).toString()),
                    ]),
                  ),
                ])
              : FakeResponse([bytes]),
        ),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: screenshotKey,
          child: MaterialApp(
            theme: musicTheme(Brightness.dark, null),
            debugShowCheckedModeBanner: false,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: Scaffold(
              body: Column(
                children: [
                  UpdateNotice(updates: updates, beforeInstall: () async {}),
                  Expanded(
                    child: ListView(
                      children: [
                        UpdateSettings(
                          updates: updates,
                          beforeInstall: () async {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() => updates.check(manual: true));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('Versión actual:'), findsOneWidget);
      expect(find.textContaining('Nueva versión:'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (Platform.environment['RP_UI_SNAPSHOTS'] == '1') {
        final boundary =
            screenshotKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('design/verification').create(recursive: true);
          await File('design/verification/update-$appVersion-mobile.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await tester.runAsync(() async {
        await tester.tap(find.text('Actualizar · descargar'));
        for (var i = 0; i < 30 && updates.downloading; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      });
      await tester.pumpAndSettle();
      expect(updates.downloaded, isNotNull, reason: updates.message);
      await tester.tap(find.text('Actualizar después'));
      await tester.pumpAndSettle();
      expect(updates.available, isNotNull);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.ensureVisible(find.text('Ver actualización'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver actualización'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      updates.dispose();
      await tester.runAsync(() => directory.delete(recursive: true));
    },
  );
}
