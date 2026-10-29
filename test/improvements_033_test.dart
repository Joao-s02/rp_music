import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/app/music_theme.dart';
import 'package:rp_music/app/expanded_player.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_manager_view.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/extension_navigation.dart';

import 'playback_and_ui_test.dart' show FakePlayer, MemoryStore;
import 'program_system_test.dart' show Registry;
import 'extension_source_test.dart' show cloudPackage;

const tracks = [
  Track(
    id: '/a.flac',
    title: 'Neon Horizons',
    artist: 'Uno, Dos',
    album: 'Neon',
    folder: '.',
  ),
  Track(
    id: '/b.flac',
    title: 'Prism Light',
    artist: 'Dos',
    album: 'Neon',
    folder: '.',
  ),
  Track(
    id: '/c.flac',
    title: 'Starlight Corridor',
    artist: 'Tres',
    album: 'Otra',
    folder: '.',
  ),
];
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
  test('artistas separados por coma, limpios y sin duplicar; conserva etiqueta original', () {
    const track = Track(
      id: 'demo',
      title: 'Demo',
      artist: ' Uno , Dos, uno, , Tres ',
      folder: '.',
    );
    expect(track.artists, ['Uno', 'Dos', 'Tres']);
    expect(Track.fromJson(track.toJson()).artist, track.artist);
  });
  test('anterior recorre historial real y siguiente recupera avance antes de aleatorio', () async {
    final player = FakePlayer();
    final audio = MusicHandler(player: player);
    var choices = 0;
    audio.shuffle = true;
    audio.chooseNext = (_, _) async => ++choices == 1 ? 2 : 1;
    await audio.select(tracks, 0);
    await audio.skipToNext();
    await audio.skipToNext();
    expect(audio.index, 1);
    player.currentPosition = const Duration(seconds: 20);
    await audio.skipToPrevious();
    expect(audio.index, 2);
    await audio.skipToPrevious();
    expect(audio.index, 0);
    await audio.skipToNext();
    expect(audio.index, 2);
    expect(choices, 2);
    await audio.select(tracks, 1);
    await audio.removeTrack(tracks[2].id);
    await audio.skipToPrevious();
    expect(audio.tracks[audio.index].id, tracks[0].id);
    await audio.close();
  });
  test(
    'historial se restaura y cambiar cola no revive canciones anteriores',
    () async {
      final store = Registry();
      final first = MusicHandler(player: FakePlayer(), sessionStore: store);
      await first.select(tracks, 0);
      await first.select(tracks, 2);
      await first.saveSession();
      await first.close();
      final second = MusicHandler(player: FakePlayer(), sessionStore: store);
      await second.restoreSession(tracks);
      await second.skipToPrevious();
      expect(second.index, 0);
      await second.select([tracks[1]], 0);
      await second.skipToPrevious();
      expect(second.tracks[second.index].id, tracks[1].id);
      await second.close();
    },
  );
  test(
    'añadir álbum a lista existente conserva contenido y evita duplicados',
    () async {
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..tracks = tracks;
      await library.createPlaylistWithTracks('Viaje', [
        tracks[2].id,
        tracks[0].id,
      ]);
      expect(
        await library.addTracksToPlaylist('Viaje', [
          tracks[0].id,
          tracks[1].id,
          'missing',
        ]),
        1,
      );
      expect(library.playlists['Viaje'], [
        tracks[2].id,
        tracks[0].id,
        tracks[1].id,
      ]);
      library.playlistMeta['Viaje'] = {'owner': 'demo', 'rule': {}};
      await expectLater(
        library.addTracksToPlaylist('Viaje', [tracks[0].id]),
        throwsFormatException,
      );
      library.dispose();
    },
  );
  testWidgets(
    'artistas colaboradores tienen su grupo y canciones compartidas',
    (tester) async {
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false
        ..root = '/music'
        ..tracks = tracks;
      final audio = MusicHandler(player: FakePlayer());
      await tester.pumpWidget(MusicApp(library: library, audio: audio));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Artistas'));
      await tester.pumpAndSettle();
      expect(find.text('Uno'), findsOneWidget);
      expect(find.text('Dos'), findsOneWidget);
      expect(find.text('Uno, Dos'), findsNothing);
      await tester.tap(find.text('Dos'));
      await tester.pumpAndSettle();
      expect(find.text('Neon Horizons'), findsOneWidget);
      expect(find.text('Prism Light'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
    },
  );
  for (final existing in [true, false]) {
    testWidgets(
      'botón de álbum permite ${existing ? 'elegir lista existente' : 'crear primera lista'}',
      (tester) async {
        tester.view.physicalSize = const Size(390, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final library = LibraryController(MemoryStore(), MusicFiles())
          ..loading = false
          ..root = '/music'
          ..tracks = tracks;
        if (existing) {
          await library.createPlaylistWithTracks('Viaje', [tracks[2].id]);
        }
        final audio = MusicHandler(player: FakePlayer());
        await tester.pumpWidget(MusicApp(library: library, audio: audio));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Álbumes'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Uno, Dos').first);
        await tester.tap(find.text('Uno, Dos').first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Añadir álbum a una lista'));
        await tester.tap(find.byTooltip('Añadir álbum a una lista'));
        await tester.pumpAndSettle();
        if (existing) {
          expect(find.text('Crear nueva lista'), findsOneWidget);
          await tester.tap(find.text('Viaje'));
        } else {
          await tester.enterText(find.byType(TextField).last, 'Primera');
          await tester.tap(find.text('Crear'));
        }
        await tester.pumpAndSettle();
        expect(
          library.playlists[existing ? 'Viaje' : 'Primera'],
          contains(tracks[0].id),
        );
        if (existing) {
          expect(library.playlists['Viaje'], contains(tracks[2].id));
        }
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(audio.close);
        library.dispose();
      },
    );
  }
  for (final width in [360.0, 1280.0]) {
    testWidgets('reproductor nuevo accesible sin ecualizador a $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false
        ..tracks = tracks;
      final audio = MusicHandler(player: FakePlayer());
      await audio.select(tracks, 0);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            theme: musicTheme(Brightness.dark, null),
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 1100),
                textScaler: TextScaler.linear(1.2),
                disableAnimations: true,
              ),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ExpandedPlayer(audio: audio, library: library),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ecualizador'), findsNothing);
      expect(find.text('Audio local'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('design/verification/player-0.3.3-${width.toInt()}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.tap(find.text('Detalles'));
      await tester.pumpAndSettle();
      expect(find.text('Detalles de la canción'), findsOneWidget);
      expect(find.text('FLAC'), findsWidgets);
      Navigator.of(tester.element(find.text('Detalles de la canción'))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cola'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Cola en curso'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
    });
  }
  testWidgets(
    'selector conserva visible el filtro de artista guardado antes de separar nombres',
    (tester) async {
      final programs = ProgramController(Registry());
      final package = ProgramPackage(
        'test.filters',
        'Filtros de prueba',
        '1.0.0',
        'Fixture genérico',
        "String run(String request) => '{}';",
        {'library.read', 'storage.private'},
        {'library'},
        false,
      );
      programs.installed[package.id] = InstalledProgram(
        package,
        package.permissions,
        enabled: true,
      );
      programs.owners['library'] = package.id;
      programs.privateData[package.id] = {
        'filters': {'artist': 'Uno, Dos'},
      };
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false
        ..root = '/music'
        ..tracks = tracks;
      library.attachPrograms(programs);
      final audio = MusicHandler(player: FakePlayer());
      await tester.pumpWidget(MusicApp(library: library, audio: audio));
      await tester.tap(find.text('Filtros combinados'));
      await tester.pump(const Duration(milliseconds: 1));
      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>).first,
      );
      expect(dropdown.initialValue, 'Uno, Dos');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
      programs.dispose();
    },
  );
  testWidgets(
    'fuente con acceso propio usa icono del tema y no ofrece abrir desde tarjeta',
    (tester) async {
      final package = cloudPackage();
      final map = package.toJson();
      final config = Map<String, dynamic>.from(map['sourceConfig'] as Map);
      config['navigation'] = {
        'label': 'Nube',
        'icon': 'playOutline',
        'color': '#47EFE0',
      };
      map['sourceConfig'] = config;
      final programs = ProgramController(Registry());
      await tester.runAsync(
        () => programs.install(ProgramPackage.parse(map), package.permissions),
      );
      final library = LibraryController(MemoryStore(), MusicFiles())
        ..loading = false;
      library.attachPrograms(programs);
      final audio = MusicHandler(player: FakePlayer());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgramManagerView(library: library, audio: audio),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Abrir Nube de prueba'), findsNothing);
      await tester.pumpWidget(
        MaterialApp(
          home: ExtensionNavigationIcon(
            extensionDestinations(programs, 'windows').single,
          ),
        ),
      );
      expect(find.byIcon(Icons.smart_display_outlined), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(audio.close);
      library.dispose();
      programs.dispose();
    },
  );
}
