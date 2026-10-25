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
import 'package:rp_music/platform/desktop_lifecycle.dart';
import 'package:audio_service/audio_service.dart';

class MemoryStore extends LocalStore {
  MemoryStore() : super(Directory('unused-memory-store'));
  @override
  Future<void> save(Map<String, dynamic> value) async {}
}

class FakeDesktopWindow implements DesktopWindow {
  FakeDesktopWindow(this.calls, {this.tray = true});
  final List<String> calls;
  final bool tray;
  @override
  Future<bool> initialize(Future<void> Function(String) handler) async => tray;
  @override
  Future<void> hide() async {
    calls.add('hide');
  }

  @override
  Future<void> finishClose() async {
    calls.add('finishClose');
  }
}

class FakePlayer implements AudioPlayer {
  FakePlayer({this.liveStates = false});
  final bool liveStates;
  final states = StreamController<PlayerState>.broadcast();
  final calls = <String>[];
  double currentVolume = 1;
  bool isPlaying = false;
  final loaded = <Uri>[];
  final played = <Uri>[];
  Completer<void>? gate;
  bool fail = false;
  Uri? current;
  Duration currentPosition = Duration.zero;
  @override
  bool get playing => isPlaying;
  @override
  double get volume => currentVolume;
  @override
  Stream<double> get volumeStream => Stream.value(currentVolume);
  @override
  Future<void> setVolume(double value) async {
    calls.add('volume:$value');
    currentVolume = value;
  }

  @override
  ProcessingState get processingState =>
      current == null ? ProcessingState.idle : ProcessingState.ready;
  @override
  Duration get bufferedPosition => Duration.zero;
  @override
  double get speed => 1;
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
  Stream<PlayerState> get playerStateStream => liveStates
      ? states.stream
      : Stream.value(PlayerState(playing, processingState));
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
    isPlaying = true;
    states.add(PlayerState(true, processingState));
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    isPlaying = false;
    states.add(PlayerState(false, processingState));
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    isPlaying = false;
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    unawaited(states.close());
  }

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
    'el servicio multimedia recibe reproducir y pausar sin eventos de carga',
    () async {
      final player = FakePlayer(liveStates: true);
      final handler = MusicHandler(player: player);
      await handler.select(tracks, 0);
      await Future<void>.delayed(Duration.zero);
      expect(handler.playbackState.value.playing, isTrue);
      expect(
        handler.playbackState.value.controls,
        contains(MediaControl.pause),
      );
      await handler.pause();
      await Future<void>.delayed(Duration.zero);
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.playbackState.value.controls, contains(MediaControl.play));
      await handler.close();
    },
  );
  test('publica cola, índice, duración real y errores del servicio', () async {
    final handler = MusicHandler(player: FakePlayer());
    final systemErrors = StreamController<Object>();
    handler.observeSystemErrors(systemErrors.stream);
    await handler.select(tracks, 1);
    expect(handler.queue.value.map((item) => item.title), [
      'Uno',
      'Dos',
      'Tres',
    ]);
    expect(handler.playbackState.value.queueIndex, 1);
    expect(handler.mediaItem.value?.duration, const Duration(seconds: 30));
    await handler.skipToQueueItem(2);
    expect(handler.mediaItem.value?.title, 'Tres');
    final error = handler.errors.stream.first;
    systemErrors.add(StateError('Fallo multimedia de prueba'));
    expect(await error, contains('diagnóstico'));
    expect(handler.lastSystemError, contains('Fallo multimedia de prueba'));
    await handler.close();
    await systemErrors.close();
  });

  test(
    'cada rechazo de foreground pausa aunque el mensaje sea repetido',
    () async {
      final player = FakePlayer();
      final audio = MusicHandler(player: player);
      final systemErrors = StreamController<Object>();
      audio.observeSystemErrors(systemErrors.stream);
      final error = StateError('startForegroundService() not allowed');
      await audio.select(tracks, 0);
      systemErrors.add(error);
      await Future<void>.delayed(Duration.zero);
      expect(player.playing, false);
      await audio.play();
      expect(player.playing, true);
      systemErrors.add(error);
      await Future<void>.delayed(Duration.zero);
      expect(player.playing, false);
      await audio.close();
      await systemErrors.close();
    },
  );

  test(
    'cerrar a bandeja mantiene audio y salir silencia antes de destruir',
    () async {
      final player = FakePlayer();
      final audio = MusicHandler(player: player);
      final library = LibraryController(
        LocalStore(Directory('unused-test-store')),
        MusicFiles(),
      );
      final desktop = DesktopLifecycle(
        FakeDesktopWindow(player.calls),
        library,
        audio,
      );
      await desktop.initialize();
      await audio.select(tracks, 0);
      player.calls.clear();
      await desktop.handle('closeRequested');
      expect(player.playing, isTrue);
      expect(player.calls, ['hide']);
      await desktop.handle('quitRequested');
      await audio.close();
      expect(player.calls, [
        'hide',
        'volume:0.0',
        'pause',
        'stop',
        'dispose',
        'finishClose',
      ]);
      library.dispose();
    },
  );
  test(
    'sin icono de bandeja el cierre sale y no oculta una app inaccesible',
    () async {
      final player = FakePlayer();
      final audio = MusicHandler(player: player);
      final library = LibraryController(
        LocalStore(Directory('unused-test-store')),
        MusicFiles(),
      );
      final desktop = DesktopLifecycle(
        FakeDesktopWindow(player.calls, tray: false),
        library,
        audio,
      );
      await desktop.initialize();
      await desktop.handle('closeRequested');
      expect(player.calls, isNot(contains('hide')));
      expect(player.calls.last, 'finishClose');
      library.dispose();
    },
  );
  test('volumen se limita al intervalo permitido', () async {
    final player = FakePlayer();
    final audio = MusicHandler(player: player);
    await audio.setAppVolume(0.35);
    expect(player.volume, 0.35);
    await audio.setAppVolume(-1);
    expect(player.volume, 0);
    await audio.setAppVolume(4);
    expect(player.volume, 1);
    await audio.close();
  });
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
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.byTooltip('Buscar'));
      await tester.pumpAndSettle();
      final originalSearchState = tester.state(find.byType(EditableText));
      await tester.tap(find.byType(TextField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 350);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
      expect(
        identical(originalSearchState, tester.state(find.byType(EditableText))),
        true,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
        true,
      );
      await tester.enterText(find.byType(TextField), 'Dos');
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Dos'), findsWidgets);
      await tester.enterText(find.byType(TextField), 'Uno');
      await tester.tap(find.byTooltip('Cerrar búsqueda'));
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.text('3 pistas locales'), findsOneWidget);
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

  testWidgets('eliminar lista pide confirmación y cancelar la conserva', (
    tester,
  ) async {
    final library = LibraryController(MemoryStore(), MusicFiles())
      ..loading = false;
    await library.addPlaylist('Viaje');
    final audio = MusicHandler(player: FakePlayer());
    await tester.pumpWidget(MusicApp(library: library, audio: audio));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.queue_music).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Eliminar lista'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(library.playlists.containsKey('Viaje'), true);
    await tester.tap(find.byTooltip('Eliminar lista'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(library.playlists.containsKey('Viaje'), false);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(audio.close);
    library.dispose();
  });

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
      expect(find.text('Tu biblioteca está en silencio'), findsOneWidget);
      expect(find.text('Elegir carpeta'), findsWidgets);
      await tester.tap(find.byIcon(Icons.extension_outlined).last);
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(find.text('Importar extensión'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings_outlined).last);
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
