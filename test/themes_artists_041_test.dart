import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/app/music_app.dart';
import 'package:rp_music/app/expanded_player.dart';
import 'package:rp_music/lyrics/lyrics_controller.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer, MemoryStore;

import 'package:rp_music/platform/android_notifications.dart';

import 'package:rp_music/artists/artist_portraits.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/themes/theme_library.dart';

class CoverFiles extends MusicFiles {
  CoverFiles({this.bytes});
  final Uint8List? bytes;
  int reads = 0;
  @override
  Future<Uint8List?> thumbnail(String id) async => bytes;
  @override
  Future<String?> embeddedLyrics(String id) async => null;
  @override
  Future<Uint8List?> artwork(String id) async {
    reads++;
    return bytes ?? Uint8List.fromList([1, 2, 3]);
  }
}

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

  test(
    'la carátula reutiliza la lectura y se invalida al cambiar el archivo',
    () async {
      final directory = await Directory.systemTemp.createTemp('rp_cover041_');
      addTearDown(() => directory.delete(recursive: true));
      final files = CoverFiles();
      final library = LibraryController(LocalStore(directory), files)
        ..tracks = const [
          Track(id: '/song', title: 'Song', folder: '.', modifiedMs: 1),
        ];
      addTearDown(library.dispose);
      await library.artwork('/song');
      await library.artwork('/song');
      expect(files.reads, 1);
      expect(library.cachedArtwork('/song'), [1, 2, 3]);
      library.tracks = const [
        Track(id: '/song', title: 'Song', folder: '.', modifiedMs: 2),
      ];
      expect(library.cachedArtwork('/song'), isNull);
      await library.artwork('/song');
      expect(files.reads, 2);
    },
  );

  test(
    'el tema conserva el decodificador activo bajo presión de caché',
    () async {
      final text = await File('assets/themes/minimalista.rptheme')
          .readAsString();
      final theme = MusicAppearance.parse(text);
      addTearDown(theme.releaseImages);
      await theme.prepareImages();
      final provider = theme.image('play')!;
      final first = provider.resolve(ImageConfiguration.empty).completer;
      final key = await provider.obtainKey(ImageConfiguration.empty);
      PaintingBinding.instance.imageCache.evict(key, includeLive: false);
      final second = theme
          .image('play')!
          .resolve(ImageConfiguration.empty)
          .completer;
      expect(identical(first, second), isTrue);
      expect(identical(provider, theme.image('play')), isTrue);
    },
  );

  test('fotos nuevas y fotos guardadas se restauran sin extensiones', () async {
    final directory = await Directory.systemTemp.createTemp('rp_artist041_');
    addTearDown(() => directory.delete(recursive: true));
    final sample = jsonDecode(
      await File('assets/themes/minimalista.rptheme').readAsString(),
    ) as Map;
    final png = base64Decode((sample['images'] as Map)['play'] as String);
    var calls = 0;
    final portraits = ArtistPortraits(
      directory,
      request: (uri) async {
        calls++;
        if (uri.host == 'thumb.wikimedia.org') return png;
        final Object result;
        if (uri.queryParameters['action'] == 'wbsearchentities') {
          result = {
            'search': [
              {'id': 'Q1', 'label': 'Fixture Artist'},
            ],
          };
        } else if (uri.queryParameters['action'] == 'wbgetentities') {
          result = {
            'entities': {
              'Q1': {
                'claims': {
                  'P434': [{}],
                  'P18': [
                    {
                      'mainsnak': {
                        'datavalue': {'value': 'Fixture.png'},
                      },
                    },
                  ],
                },
              },
            },
          };
        } else {
          result = {
            'query': {
              'pages': {
                '1': {
                  'imageinfo': [
                    {
                      'thumburl': 'https://thumb.wikimedia.org/fixture.png',
                      'descriptionurl':
                          'https://commons.wikimedia.org/wiki/File:Fixture.png',
                      'extmetadata': {
                        'Artist': {'value': 'Fixture creator'},
                        'LicenseShortName': {'value': 'CC BY 4.0'},
                      },
                    },
                  ],
                },
              },
            },
          };
        }
        return Uint8List.fromList(utf8.encode(jsonEncode(result)));
      },
    );
    final first = portraits.photo('Fixture Artist');
    expect(identical(first, portraits.photo('Fixture Artist')), isTrue);
    final photo = await first;
    expect(photo, isNotNull);
    expect(photo!.credit, contains('Fixture creator'));
    expect(calls, 5);
    portraits.dispose();
    final cached = ArtistPortraits(
      directory,
      request: (_) async => throw StateError('Offline'),
    );
    final restored = await cached.photo('Fixture Artist');
    expect(restored!.file.path, photo.file.path);
    expect(restored.credit, contains('CC BY 4.0'));
    final old = File('${directory.path}/${cached.key('Old artist')}.jpg');
    await old.writeAsBytes(png);
    expect(await cached.photo('Old artist'), isNull);
    expect(await old.exists(), isTrue);
    cached.dispose();
  });
  testWidgets(
    'reproductor muestra datos e iconos al entrar y al volver de Letras',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      late Directory directory;
      late LibraryController library;
      late MusicHandler audio;
      late CoverFiles files;
      await tester.runAsync(() async {
        directory = await Directory.systemTemp.createTemp('rp_routes041_');
        final theme = jsonDecode(
          await File('assets/themes/minimalista.rptheme').readAsString(),
        ) as Map<String, dynamic>;
        final icons = theme['images'] as Map;
        final png = icons['play'];
        for (final slot in [
          'background',
          'decoration',
          'lyrics',
          'queue',
          'volume',
          'details',
          'favorite',
          'favoriteSelected',
        ]) {
          icons[slot] = png;
        }
        files = CoverFiles(bytes: base64Decode(png as String));
        library = LibraryController(LocalStore(directory), files)
          ..loading = false
          ..root = '/synthetic'
          ..tracks = const [
            Track(
              id: '/song',
              title: 'Fixture Song',
              artist: 'Fixture Artist',
              folder: '.',
            ),
          ];
        await library.themes.initialize();
        await library.themes.install(jsonEncode(theme));
        library.lyrics = LyricsController(directory, files);
        await library.lyrics!.save(
          '/song',
          '[00:00]Fixture line\n[00:03]Another line',
        );
        await library.lyrics!.ensure(library.tracks.single);
        await library.artwork('/song');
        audio = MusicHandler(player: FakePlayer());
        await audio.select(library.tracks, 0, autoplay: false);
      });
      await tester.pumpWidget(MusicApp(library: library, audio: audio));
      await tester.pumpAndSettle();
      final background = library.themes.active!.image('background')!;
      final decoder = background.resolve(ImageConfiguration.empty).completer;
      await tester.tap(find.text('Fixture Song').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final player = find.byType(ExpandedPlayer);
      expect(
        find.ancestor(
          of: player,
          matching: find.byWidgetPredicate(
            (w) => w is ThemeBackdrop && w.opaque,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: player, matching: find.text('Fixture Song')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is ThemeBrand && w.size == 32),
        findsOneWidget,
      );
      for (final slot in ['lyrics', 'queue', 'volume', 'details']) {
        expect(
          find.descendant(
            of: player,
            matching: find.byWidgetPredicate(
              (w) => w is ThemeIcon && w.slot == slot,
            ),
          ),
          findsOneWidget,
        );
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Letras'));
      await tester.pumpAndSettle();
      final key = await background.obtainKey(ImageConfiguration.empty);
      PaintingBinding.instance.imageCache.evict(key, includeLive: false);
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        find.descendant(of: player, matching: find.text('Fixture Song')),
        findsOneWidget,
      );
      expect(
        identical(
          background.resolve(ImageConfiguration.empty).completer,
          decoder,
        ),
        isTrue,
      );
      expect(files.reads, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() async {
        await audio.close();
        library.dispose();
        await directory.delete(recursive: true);
      });
    },
  );
  testWidgets(
    'un icono de tema conserva su tamaño dentro de una carátula vacía',
    (tester) async {
      late MusicAppearance theme;
      await tester.runAsync(() async {
        final data = jsonDecode(
          await File('assets/themes/minimalista.rptheme').readAsString(),
        ) as Map<String, dynamic>;
        (data['images'] as Map)['album'] = (data['images'] as Map)['play'];
        theme = MusicAppearance.parse(jsonEncode(data));
        await theme.prepareImages();
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [theme]),
          home: const Scaffold(
            body: Center(
              child: SizedBox.square(
                dimension: 200,
                child: ThemeIcon('album', Icons.album_outlined),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Image)), const Size(24, 24));
      await tester.pumpWidget(const SizedBox.shrink());
      theme.releaseImages();
    },
  );
  test(
    'actualizar tema reemplaza la revisión y persiste sin duplicarlo',
    () async {
      final dir = await Directory.systemTemp.createTemp('rp_theme_revision_');
      final themes = ThemeLibrary(LocalStore(dir));
      await themes.initialize();
      String package(int revision) => jsonEncode({
        'version': 1,
        'name': 'Prueba',
        'accent': '#102030',
        'revision': revision,
      });
      await themes.install(package(1));
      final old = themes.activeId;
      await themes.install(package(2));
      expect(themes.installed.length, 1);
      expect(themes.activeId, isNot(old));
      expect(themes.active!.revision, 2);
      await expectLater(themes.install(package(1)), throwsFormatException);
      expect(themes.active!.revision, 2);
      final restored = ThemeLibrary(LocalStore(dir));
      await restored.initialize();
      expect(restored.installed.length, 1);
      expect(restored.active!.revision, 2);
      restored.dispose();
      themes.dispose();
      await dir.delete(recursive: true);
    },
  );

  testWidgets('catálogo bloquea descargar un tema instalado', (tester) async {
    late ThemeLibrary themes;
    late Directory dir;
    await tester.runAsync(() async {
      dir = await Directory.systemTemp.createTemp('rp_theme_catalog_');
      themes = ThemeLibrary(LocalStore(dir));
      await themes.initialize();
      await themes.install(
        await File('assets/themes/minimalista.rptheme').readAsString(),
      );
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ThemeLibraryView(themes: themes)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Descargados'), findsOneWidget);
    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Importar tema'), findsNothing);
    expect(find.text('Instalado'), findsNothing);
    await tester.tap(find.text('Catálogo'));
    await tester.pumpAndSettle();
    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Instalado'),
    );
    expect(button.onPressed, isNull);
    expect(find.byType(Card), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox.shrink());
    themes.dispose();
    await tester.runAsync(() => dir.delete(recursive: true));
  });

  testWidgets(
    'listas recogen cabecera y agrupan acciones; ajustes con botones iguales',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final library = LibraryController(MemoryStore(), CoverFiles())
        ..loading = false
        ..playlists = {for (var i = 0; i < 35; i++) 'Lista $i': []};
      final audio = MusicHandler(player: FakePlayer());
      final notifications = AndroidNotifications();
      await tester.pumpWidget(
        MusicApp(library: library, audio: audio, notifications: notifications),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Listas'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const ValueKey('playlist-tools'))).height,
        0,
      );
      await tester.drag(find.byType(ListView), const Offset(0, 700));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const ValueKey('playlist-tools'))).height,
        greaterThan(0),
      );
      await tester.tap(find.text('Lista 0'));
      await tester.pumpAndSettle();
      final play = find.widgetWithText(FilledButton, 'Reproducir');
      final shuffle = find.widgetWithText(FilledButton, 'Aleatorio');
      await tester.ensureVisible(play);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(play).dy, tester.getTopLeft(shuffle).dy);
      expect(tester.getSize(play).height, tester.getSize(shuffle).height);
      expect(find.text('Cambiar carátula'), findsNothing);
      expect(
        tester.getCenter(find.byTooltip('Filtrar por')).dy,
        tester.getCenter(find.byTooltip('Opciones de la lista')).dy,
      );
      await tester.tap(find.byTooltip('Opciones de la lista'));
      await tester.pumpAndSettle();
      expect(find.text('Cambiar carátula'), findsOneWidget);
      expect(find.text('Eliminar lista'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      final permission = find.widgetWithText(FilledButton, 'Solicitar permiso');
      await tester.ensureVisible(permission);
      await tester.pumpAndSettle();
      final size = tester.getSize(permission);
      for (final label in [
        'Abrir ajustes de notificaciones',
        'Revisar restricciones de batería',
        'Diagnóstico multimedia',
      ]) {
        expect(
          tester.getSize(find.widgetWithText(OutlinedButton, label)),
          size,
        );
      }
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      final enlarged = tester.getSize(permission);
      expect(enlarged.height, greaterThanOrEqualTo(size.height));
      for (final label in [
        'Abrir ajustes de notificaciones',
        'Revisar restricciones de batería',
        'Diagnóstico multimedia',
      ]) {
        expect(
          tester.getSize(find.widgetWithText(OutlinedButton, label)),
          enlarged,
        );
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(audio.close);
      library.dispose();
      notifications.dispose();
    },
  );
  testWidgets('el resaltado se recorta en la fila y se desplaza con ella', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final tracks = List.generate(
      40,
      (i) => Track(id: '/song$i', title: 'Song $i', folder: '.'),
    );
    final library = LibraryController(MemoryStore(), CoverFiles())
      ..loading = false
      ..root = '/synthetic'
      ..tracks = tracks;
    final audio = MusicHandler(player: FakePlayer());
    await audio.select(tracks, 0);
    await tester.pumpWidget(MusicApp(library: library, audio: audio));
    await tester.pumpAndSettle();
    final selected = find.byWidgetPredicate((w) => w is ListTile && w.selected);
    expect(selected, findsOneWidget);
    final surface = find
        .ancestor(of: selected, matching: find.byType(Material))
        .first;
    expect(tester.widget<Material>(surface).clipBehavior, Clip.hardEdge);
    expect(tester.getSize(surface).height, 72);
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(selected.hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(audio.close);
    library.dispose();
  });
  test(
    'retratos de perfil admiten acentos y evitan coincidencias parecidas',
    () async {
      final dir = await Directory.systemTemp.createTemp('rp_profile033_');
      final package = jsonDecode(
        await File('assets/themes/minimalista.rptheme').readAsString(),
      ) as Map;
      final png = base64Decode((package['images'] as Map)['play'] as String);
      final urls = <Uri>[];
      final service = ArtistPortraits(
        dir,
        request: (uri) async {
          urls.add(uri);
          if (uri.host == 'cdn-images.dzcdn.net') return png;
          return Uint8List.fromList(
            utf8.encode(
              jsonEncode({
                'data': [
                  {
                    'id': 33,
                    'name': 'Oscar Maydon',
                    'nb_fan': 1,
                    'picture_big': 'https://cdn-images.dzcdn.net/homonym.jpg',
                  },
                  {
                    'id': 11,
                    'name': 'Oscar Mason',
                    'picture_big': 'https://cdn-images.dzcdn.net/wrong.jpg',
                  },
                  {
                    'id': 22,
                    'name': 'Óscar Maydon',
                    'nb_fan': 1000,
                    'picture_big': 'https://cdn-images.dzcdn.net/correct.jpg',
                  },
                ],
              }),
            ),
          );
        },
      );
      final photo = await service.photo('oscar maydon');
      expect(photo, isNotNull);
      expect(photo!.credit, contains('Deezer'));
      expect(photo.credit, contains('/22'));
      expect(urls.last.path, '/correct.jpg');
      expect(urls.length, 2);
      service.dispose();
      await dir.delete(recursive: true);
    },
  );

  test(
    'respaldo busca en español y admite cantante sin MusicBrainz ID',
    () async {
      final dir = await Directory.systemTemp.createTemp('rp_spanish033_');
      final package = jsonDecode(
        await File('assets/themes/minimalista.rptheme').readAsString(),
      ) as Map;
      final png = base64Decode((package['images'] as Map)['play'] as String);
      final service = ArtistPortraits(
        dir,
        request: (uri) async {
          if (uri.host == 'thumb.wikimedia.org') return png;
          final Object data;
          if (uri.host == 'api.deezer.com') {
            data = {'data': []};
          } else if (uri.queryParameters['action'] == 'wbsearchentities') {
            data = {
              'search': uri.queryParameters['language'] == 'es'
                  ? [
                      {'id': 'Q1', 'label': 'Óscar Maydon'},
                    ]
                  : [],
            };
          } else if (uri.queryParameters['action'] == 'wbgetentities') {
            data = {
              'entities': {
                'Q1': {
                  'claims': {
                    'P106': [
                      {
                        'mainsnak': {
                          'datavalue': {
                            'value': {'id': 'Q177220'},
                          },
                        },
                      },
                    ],
                    'P18': [
                      {
                        'mainsnak': {
                          'datavalue': {'value': 'portrait.jpg'},
                        },
                      },
                    ],
                  },
                },
              },
            };
          } else {
            data = {
              'query': {
                'pages': {
                  '1': {
                    'imageinfo': [
                      {
                        'thumburl': 'https://thumb.wikimedia.org/portrait.jpg',
                        'descriptionurl': 'https://commons.wikimedia.org/wiki/File:portrait.jpg',
                      },
                    ],
                  },
                },
              },
            };
          }
          return Uint8List.fromList(utf8.encode(jsonEncode(data)));
        },
      );
      expect(await service.photo('Oscar Maydon'), isNotNull);
      service.dispose();
      await dir.delete(recursive: true);
    },
  );
  test(
    'una canción distingue el perfil y la caché se restaura sin reenviarla',
    () async {
      final dir = await Directory.systemTemp.createTemp('rp_hint034_');
      final package = jsonDecode(
        await File('assets/themes/minimalista.rptheme').readAsString(),
      ) as Map;
      final png = base64Decode((package['images'] as Map)['play'] as String);
      final urls = <Uri>[];
      final service = ArtistPortraits(
        dir,
        request: (uri) async {
          urls.add(uri);
          if (uri.host == 'cdn-images.dzcdn.net') return png;
          final Object data;
          if (uri.path == '/search') {
            expect(uri.queryParameters, {
              'q': 'Oscar Maydon Tu Boda',
              'limit': '25',
            });
            data = {
              'data': [
                {
                  'title': 'Otra canción',
                  'artist': {'id': 11, 'name': 'Oscar Maydon'},
                },
                {
                  'title': 'Tu Boda',
                  'artist': {'id': 12, 'name': 'Otro artista'},
                },
                {
                  'title': 'Tu Boda',
                  'artist': {'id': 22, 'name': 'Óscar Maydon'},
                },
              ],
            };
          } else {
            expect(uri.path, '/artist/22');
            data = {
              'id': 22,
              'name': 'Óscar Maydon',
              'picture_big': 'https://cdn-images.dzcdn.net/portrait.jpg',
            };
          }
          return Uint8List.fromList(utf8.encode(jsonEncode(data)));
        },
      );
      final first = service.photo('Oscar Maydon', trackTitle: 'Tu Boda');
      expect(
        identical(first, service.photo('Oscar Maydon', trackTitle: 'Tu Boda')),
        isTrue,
      );
      final image = await first;
      expect(image, isNotNull);
      expect(image!.credit, contains('/artist/22'));
      expect(urls.length, 3);
      service.dispose();
      final offline = ArtistPortraits(
        dir,
        request: (_) async => throw StateError('Offline'),
      );
      expect(
        (await offline.photo('Oscar Maydon', trackTitle: 'Tu Boda'))!.file.path,
        image.file.path,
      );
      expect(
        await offline.photo('Oscar Maydon', trackTitle: 'Canción diferente'),
        isNull,
      );
      offline.dispose();
      await dir.delete(recursive: true);
    },
  );

  test(
    'sin canción coincidente no se acepta el perfil obtenido solo por nombre',
    () async {
      final dir = await Directory.systemTemp.createTemp('rp_hint_missing034_');
      final urls = <Uri>[];
      final service = ArtistPortraits(
        dir,
        request: (uri) async {
          urls.add(uri);
          expect(uri.path, isNot('/search/artist'));
          return Uint8List.fromList(
            utf8.encode(
              jsonEncode(
                uri.host == 'api.deezer.com' ? {'data': []} : {'search': []},
              ),
            ),
          );
        },
      );
      expect(
        await service.photo('Los Fernandez', trackTitle: 'Por eso canto'),
        isNull,
      );
      expect(urls.first.queryParameters['q'], 'Los Fernandez Por eso canto');
      expect(urls.any((uri) => uri.host == 'cdn-images.dzcdn.net'), isFalse);
      service.dispose();
      await dir.delete(recursive: true);
    },
  );

  test('no se conserva un perfil cuyo nombre contradice la canción', () async {
    final dir = await Directory.systemTemp.createTemp('rp_hint_name034_');
    final service = ArtistPortraits(
      dir,
      request: (uri) async {
        final Object data;
        if (uri.path == '/search') {
          data = {
            'data': [
              {
                'title': 'Canción',
                'artist': {'id': 22, 'name': 'Mi artista'},
              },
            ],
          };
        } else if (uri.path == '/artist/22') {
          data = {
            'id': 22,
            'name': 'Otro artista',
            'picture_big': 'https://cdn-images.dzcdn.net/wrong.jpg',
          };
        } else {
          expect(uri.host, 'www.wikidata.org');
          data = {'search': []};
        }
        return Uint8List.fromList(utf8.encode(jsonEncode(data)));
      },
    );
    expect(await service.photo('Mi artista', trackTitle: 'Canción'), isNull);
    service.dispose();
    await dir.delete(recursive: true);
  });
  test('se descarta la foto de perfil que es una portada de álbum', () async {
    final dir = await Directory.systemTemp.createTemp('rp_hint_cover034_');
    final urls = <Uri>[];
    const hash = 'a7d4ed330584a3a80e6729197b1d8ef6';
    final service = ArtistPortraits(
      dir,
      request: (uri) async {
        urls.add(uri);
        final Object data;
        if (uri.path == '/search') {
          data = {
            'data': [
              {
                'title': 'Por eso canto',
                'artist': {'id': 22, 'name': 'Los Fernandez'},
              },
            ],
          };
        } else if (uri.path == '/artist/22') {
          data = {
            'id': 22,
            'name': 'Los Fernandez',
            'picture_big':
                'https://cdn-images.dzcdn.net/images/artist/$hash/500x500.jpg',
          };
        } else if (uri.path == '/artist/22/albums') {
          data = {
            'data': [
              {
                'title': 'Otra portada',
                'cover_big':
                    'https://cdn-images.dzcdn.net/images/cover/$hash/500x500.jpg',
              },
            ],
          };
        } else {
          data = {'search': []};
        }
        expect(uri.host, isNot('cdn-images.dzcdn.net'));
        return Uint8List.fromList(utf8.encode(jsonEncode(data)));
      },
    );
    expect(
      await service.photo('Los Fernandez', trackTitle: 'Por eso canto'),
      isNull,
    );
    expect(urls.any((uri) => uri.path == '/artist/22/albums'), isTrue);
    service.dispose();
    await dir.delete(recursive: true);
  });
  test('las fotos requieren activación y la preferencia se conserva', () async {
    final dir = await Directory.systemTemp.createTemp('rp_consent041_');
    final library = LibraryController(LocalStore(dir), CoverFiles());
    await library.initialize();
    expect(library.artistPhotosEnabled, isFalse);
    await library.setArtistPhotosEnabled(true);
    final restored = LibraryController(LocalStore(dir), CoverFiles());
    await restored.initialize();
    expect(restored.artistPhotosEnabled, isTrue);
    final previous = restored.portraits;
    await restored.setArtistPhotosEnabled(false);
    expect(identical(previous, restored.portraits), isFalse);
    final disabled = LibraryController(LocalStore(dir), CoverFiles());
    await disabled.initialize();
    expect(disabled.artistPhotosEnabled, isFalse);
    disabled.dispose();
    restored.dispose();
    library.dispose();
    await dir.delete(recursive: true);
  });

  testWidgets('Artistas explica y permite activar o retirar la consulta', (
    tester,
  ) async {
    final library = LibraryController(MemoryStore(), CoverFiles())
      ..loading = false
      ..root = '/synthetic'
      ..tracks = const [
        Track(
          id: '/song',
          title: 'Referencia',
          artist: 'Mi artista',
          folder: '.',
        ),
      ];
    final audio = MusicHandler(player: FakePlayer());
    await tester.pumpWidget(MusicApp(library: library, audio: audio));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Artistas'));
    await tester.pumpAndSettle();
    expect(find.byType(ArtistPhoto), findsNothing);
    final toggle = find.byKey(const ValueKey('artist-photo-consent'));
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.byType(ArtistPhoto), findsOneWidget);
    expect(
      tester.widget<ArtistPhoto>(find.byType(ArtistPhoto)).trackTitle,
      'Referencia',
    );
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.byType(ArtistPhoto), findsNothing);
    expect(library.artistPhotosEnabled, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(audio.close);
    library.dispose();
  });

  test('catálogo conserva base y elige la revisión compatible más alta', () {
    Map<String, Object> update(
      int revision, {
      String version = '0.4.1',
      int build = 33,
    }) => {
      'revision': revision,
      'minAppVersion': version,
      'minAppBuild': build,
      'url': 'miku-$revision.rptheme',
      'sha256': List.filled(64, 'a').join(),
    };
    final data = {
      'version': 1,
      'themes': [
        {
          'name': 'Miku',
          'url': 'miku-1.rptheme',
          'sha256': List.filled(64, 'b').join(),
          'updates': [
            update(2),
            update(4, version: '99.0.0'),
            update(3, build: 99999),
          ],
        },
      ],
    };
    final parsed = parseThemeCatalog(
      jsonEncode(data),
      Uri.parse('https://example.com/catalog.json'),
    );
    expect(parsed.single.revision, 2);
    expect(parsed.single.url.toString(), 'https://example.com/miku-2.rptheme');
    expect((data['themes'] as List).first['url'], 'miku-1.rptheme');
    (data['themes'] as List).first['updates'] = [update(3, build: 99999)];
    expect(
      parseThemeCatalog(
        jsonEncode(data),
        Uri.parse('https://example.com/catalog.json'),
      ).single.revision,
      1,
    );
    (data['themes'] as List).first['updates'] = [update(-1)];
    expect(
      () => parseThemeCatalog(
        jsonEncode(data),
        Uri.parse('https://example.com/catalog.json'),
      ),
      throwsFormatException,
    );
  });
}
