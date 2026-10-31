import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/music_files.dart';

const recoveryMessage =
    'No se pudo recuperar la biblioteca guardada. El guardado está bloqueado para conservar los archivos originales.';

Map<String, dynamic> snapshot() => {
  'schema': 1,
  'root': 'respaldo',
  'tracks': [
    {'id': 'song', 'title': 'Canción', 'folder': '.'},
  ],
  'favorites': ['song', 'ausente'],
  'playlists': {
    'Viaje': ['song', 'ausente'],
  },
  'extensions': <dynamic>[],
};

class CountingStore extends LocalStore {
  CountingStore(super.directory);
  int saves = 0;
  @override
  Future<void> save(Map<String, dynamic> value) {
    saves++;
    return super.save(value);
  }
}

class MemoryStore extends CountingStore {
  MemoryStore(super.directory);
  Map<String, dynamic> value = snapshot();
  @override
  Future<Map<String, dynamic>> load() async => value;
  @override
  Future<void> save(Map<String, dynamic> value) async {
    saves++;
    this.value = value;
  }
}

void expectRecovered(LibraryController library) {
  expect(library.loading, isFalse);
  expect(library.message, isNull);
  expect(library.root, 'respaldo');
  expect(library.tracks.map((t) => t.id), ['song']);
  expect(library.remoteTracks, isEmpty);
  expect(library.favorites, {'song', 'ausente'});
  expect(library.playlists, {
    'Viaje': ['song', 'ausente'],
  });
  expect(library.playlistTracks('Viaje').single.id, 'song');
  expect(library.missingInPlaylist('Viaje'), 1);
  expect(library.extensions, isEmpty);
  expect(library.activeExtensionId, isNull);
  expect(library.playlistMeta, isEmpty);
  expect(library.volume, 1);
  expect(library.closeToTray, isTrue);
}

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('rp_a01_');
  });
  tearDown(() async => directory.delete(recursive: true));

  final invalid = <String, String Function()>{
    'principal truncado': () => '{"schema":1,',
    'favoritos con tipo inválido': () =>
        jsonEncode({...snapshot(), 'root': 'rechazado', 'favorites': 42}),
    'pista inválida': () => jsonEncode({
      ...snapshot(),
      'root': 'rechazado',
      'tracks': [
        {'id': 42},
      ],
    }),
    'esquema no admitido': () => jsonEncode({...snapshot(), 'schema': 2}),
    'entrada tardía de lista inválida': () => jsonEncode({
      ...snapshot(),
      'root': 'rechazado',
      'playlists': {
        'Primera': ['song'],
        'Última': ['song', 42],
      },
    }),
  };
  for (final entry in invalid.entries) {
    test(
      '${entry.key}: respaldo íntegro y bytes rechazados tras reinicio',
      () async {
        final rejected = utf8.encode(entry.value());
        final good = utf8.encode(jsonEncode(snapshot()));
        final main = File('${directory.path}/library.json');
        final backup = File('${directory.path}/library.backup.json');
        await main.writeAsBytes(rejected);
        await backup.writeAsBytes(good);
        final library = LibraryController(LocalStore(directory), MusicFiles());
        addTearDown(library.dispose);
        final publications = <String?>[];
        library.addListener(() => publications.add(library.root));
        await library.initialize();
        expectRecovered(library);
        expect(publications, ['respaldo']);
        expect(await main.readAsBytes(), rejected);
        expect(await backup.readAsBytes(), good);
        await library.setDark(false);
        expect(await backup.readAsBytes(), good);
        final restarted = LibraryController(
          LocalStore(directory),
          MusicFiles(),
        );
        addTearDown(restarted.dispose);
        await restarted.initialize();
        expectRecovered(restarted);
        expect(restarted.dark, isFalse);
        await restarted.setVolume(0.4);
        final again = LibraryController(LocalStore(directory), MusicFiles());
        addTearDown(again.dispose);
        await again.initialize();
        expect(again.favorites, {'song', 'ausente'});
        expect(again.playlists['Viaje'], ['song', 'ausente']);
        expect(again.volume, 0.4);
        final allBytes = await Future.wait(
          directory.listSync().whereType<File>().map((f) => f.readAsBytes()),
        );
        expect(allBytes.any((bytes) => listEquals(bytes, rejected)), isTrue);
      },
    );
  }

  test(
    'ambas copias inválidas no publican estado ni permiten guardar',
    () async {
      final main = File('${directory.path}/library.json');
      final backup = File('${directory.path}/library.backup.json');
      final bad = jsonEncode({...snapshot(), 'volume': 'inválido'});
      await main.writeAsString(bad);
      await backup.writeAsString('{roto');
      final store = CountingStore(directory);
      final library = LibraryController(store, MusicFiles());
      addTearDown(library.dispose);
      await library.initialize();
      expect(library.loading, isFalse);
      expect(library.message, recoveryMessage);
      expect(library.root, isNull);
      expect(library.tracks, isEmpty);
      expect(library.remoteTracks, isEmpty);
      expect(library.favorites, isEmpty);
      expect(library.playlists, isEmpty);
      expect(library.playlistMeta, isEmpty);
      expect(library.extensions, isEmpty);
      expect(library.activeExtensionId, isNull);
      expect(library.volume, 1);
      await library.setDark(false);
      await library.persist();
      expect(library.message, recoveryMessage);
      expect(store.saves, 0);
      expect(await main.readAsString(), bad);
      expect(await backup.readAsString(), '{roto');
      expect(directory.listSync().length, 2);
    },
  );

  test('primera ejecución vacía permite guardar normalmente', () async {
    final store = CountingStore(directory);
    final library = LibraryController(store, MusicFiles());
    addTearDown(library.dispose);
    await library.initialize();
    expect(library.message, isNull);
    expect(library.tracks, isEmpty);
    await library.setDark(false);
    expect(store.saves, 1);
    final restarted = LibraryController(LocalStore(directory), MusicFiles());
    addTearDown(restarted.dispose);
    await restarted.initialize();
    expect(restarted.dark, isFalse);
    expect(restarted.message, isNull);
  });

  test('esquema 1 conserva opcionales y referencias ausentes', () async {
    await File('${directory.path}/library.json')
        .writeAsString(jsonEncode(snapshot()));
    final library = LibraryController(LocalStore(directory), MusicFiles());
    addTearDown(library.dispose);
    await library.initialize();
    expectRecovered(library);
    expect(library.dark, isTrue);
    expect(library.ascending, isTrue);
    expect(library.tracks.single.artist, 'Artista desconocido');
    await library.setCloseToTray(false);
    final restarted = LibraryController(LocalStore(directory), MusicFiles());
    addTearDown(restarted.dispose);
    await restarted.initialize();
    expect(restarted.closeToTray, isFalse);
    expect(restarted.favorites, {'song', 'ausente'});
    expect(restarted.playlists['Viaje'], ['song', 'ausente']);
  });

  test('overrides existentes de load y save siguen utilizándose', () async {
    final store = MemoryStore(directory);
    final library = LibraryController(store, MusicFiles());
    addTearDown(library.dispose);
    await library.initialize();
    expectRecovered(library);
    await library.setDark(false);
    expect(store.saves, 1);
    expect(store.value['dark'], isFalse);
    expect(directory.listSync(), isEmpty);
  });
}
