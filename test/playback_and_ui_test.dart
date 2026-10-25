import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

class FakePlayer implements AudioPlayer {
  final loaded = <Uri>[];
  final played = <Uri>[];
  Completer<void>? gate;
  bool fail = false;
  Uri? current;
  Duration currentPosition = Duration.zero;
  @override
  bool get playing => false;
  @override
  Stream<PlaybackEvent> get playbackEventStream => const Stream.empty();
  @override
  Stream<ProcessingState> get processingStateStream => const Stream.empty();
  @override
  Stream<Duration> get positionStream => Stream.value(Duration.zero);
  @override
  Stream<Duration?> get durationStream =>
      Stream.value(const Duration(seconds: 30));
  @override
  Stream<PlayerState> get playerStateStream =>
      Stream.value(PlayerState(false, ProcessingState.idle));
  @override
  Duration get position => currentPosition;
  @override
  Future<Duration?> setAudioSource(
    AudioSource audioSource, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    current = (audioSource as UriAudioSource).uri;
    currentPosition = initialPosition ?? Duration.zero;
    loaded.add(current!);
    await gate?.future;
    if (fail) throw StateError('Archivo ilegible');
    return const Duration(seconds: 30);
  }

  @override
  Future<void> play() async {
    played.add(current!);
  }

  @override
  Future<void> pause() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> seek(Duration? position, {int? index}) async {
    currentPosition = position ?? Duration.zero;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const tracks = [
    Track(id: 'C:/music/uno.mp3', title: 'Uno', folder: '.'),
    Track(id: 'C:/music/dos.mp3', title: 'Dos', folder: '.'),
    Track(id: 'C:/music/tres.mp3', title: 'Tres', folder: '.'),
  ];
  test(
    'restaura pista, cola disponible y posición sin comenzar a reproducir',
    () async {
      final directory = await Directory.systemTemp.createTemp('rp_session_');
      final store = LocalStore(directory, baseName: 'session');
      final handler = MusicHandler(player: FakePlayer(), sessionStore: store);
      await handler.select(tracks, 1);
      await handler.seek(const Duration(seconds: 12));
      handler.shuffle = true;
      await handler.close();
      final player = FakePlayer();
      final restored = MusicHandler(player: player, sessionStore: store);
      await restored.restoreSession(tracks.sublist(1));
      expect(restored.mediaItem.value?.title, 'Dos');
      expect(restored.tracks, hasLength(2));
      expect(player.position, const Duration(seconds: 12));
      expect(player.played, isEmpty);
      expect(restored.shuffle, isTrue);
      await restored.close();
      await directory.delete(recursive: true);
    },
  );

  testWidgets(
    'búsqueda con teclado y texto ampliado no desborda en Android compacto',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final library =
          LibraryController(
              LocalStore(Directory('unused-widget-test-store')),
              MusicFiles(),
            )
            ..loading = false
            ..root = 'raíz'
            ..tracks = tracks;
      final audio = MusicHandler(player: FakePlayer());
      await tester.pumpWidget(MusicApp(library: library, audio: audio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 350);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
      await tester.enterText(find.byType(TextField), 'Dos');
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Dos'), findsWidgets);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(audio.close);
      library.dispose();
    },
  );
  test(
    'cambios rápidos descartan selecciones obsoletas sin reproducirlas',
    () async {
      final player = FakePlayer()..gate = Completer<void>();
      final handler = MusicHandler(player: player);
      final first = handler.select(tracks, 0);
      await Future<void>.delayed(Duration.zero);
      final second = handler.select(tracks, 1);
      final third = handler.select(tracks, 2);
      player.gate!.complete();
      await Future.wait([first, second, third]);
      expect(player.loaded.map((u) => u.pathSegments.last), [
        'uno.mp3',
        'tres.mp3',
      ]);
      expect(player.played.map((u) => u.pathSegments.last), ['tres.mp3']);
      expect(handler.mediaItem.value?.title, 'Tres');
      await handler.close();
    },
  );
  test('pausar mientras carga impide el inicio automático posterior', () async {
    final player = FakePlayer()..gate = Completer<void>();
    final handler = MusicHandler(player: player);
    final operation = handler.select(tracks, 0);
    await Future<void>.delayed(Duration.zero);
    await handler.pause();
    player.gate!.complete();
    await operation;
    expect(player.played, isEmpty);
    await handler.close();
  });
  test(
    'un fallo informa al usuario y permite seleccionar otra pista',
    () async {
      final player = FakePlayer()..fail = true;
      final handler = MusicHandler(player: player);
      final error = handler.errors.stream.first;
      await handler.select(tracks, 0);
      expect(await error, contains('Uno'));
      player.fail = false;
      await handler.select(tracks, 1);
      expect(player.played.single.pathSegments.last, 'dos.mp3');
      await handler.close();
    },
  );

  for (final width in [360.0, 1280.0]) {
    testWidgets('interfaz vacía y navegación sin desbordes a $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final directory = Directory('unused-widget-test-store');
      final library = LibraryController(LocalStore(directory), MusicFiles())
        ..loading = false;
      final audio = MusicHandler(player: FakePlayer());
      await tester.pumpWidget(MusicApp(library: library, audio: audio));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(find.text('Seleccionar mi música'), findsOneWidget);
      await tester.tap(find.text('Extensiones').last);
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(find.text('Importar extensión'), findsOneWidget);
      await tester.tap(find.text('Ajustes').last);
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(find.text('Tema oscuro'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(audio.close);
      library.dispose();
    });
  }
}
