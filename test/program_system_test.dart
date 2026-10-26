import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_coordinator.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/program_snapshot.dart';

import 'playback_and_ui_test.dart' show FakePlayer;

import 'package:rp_music/playback/music_handler.dart';

class Registry extends LocalStore {
  Registry() : super(Directory('unused-program-registry'));
  Map<String, dynamic> data = {};
  @override
  Future<void> save(Map<String, dynamic> value) async {
    data = Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);
  }

  @override
  Future<Map<String, dynamic>> load() async =>
      Map<String, dynamic>.from(jsonDecode(jsonEncode(data)) as Map);
}

Future<ProgramPackage> example(String name) async => ProgramPackage.parse(
  Map<String, dynamic>.from(
    jsonDecode(
      await File('examples/extensions/programables/$name.rpmx').readAsString(),
    ) as Map,
  ),
);
const a = Track(
  id: '/private/a.mp3',
  title: 'A',
  artist: 'Uno',
  album: 'Álbum',
  folder: 'Rock',
  durationMs: 120000,
);
const b = Track(
  id: '/private/b.mp3',
  title: 'B',
  artist: 'Dos',
  album: 'Otro',
  folder: 'Pop',
  durationMs: 240000,
);
void main() {
  test('paquetes corresponden al código fuente y rechazan permisos no soportados', () async {
    for (final name in ['biblioteca-viva', 'pulso-nocturno']) {
      final package = await example(name);
      expect(
        package.source,
        (await File(
          'examples/extensions/programables/${name.replaceAll('-', '_')}.dart',
        ).readAsString()).replaceAll('\r\n', '\n'),
      );
      expect(
        () => ProgramPackage.parse({
          ...package.toJson(),
          'permissions': ['files.write'],
        }),
        throwsFormatException,
      );
    }
  });
  test('instalar no ejecuta sin consentimiento y conserva la personalización al reiniciar', () async {
    final package = await example('biblioteca-viva');
    final store = Registry();
    final programs = ProgramController(store);
    await programs.install(package, {'library.read'});
    expect(programs.owner('library'), isNull);
    expect(
      await programs.invoke(package.id, 'library', {'tracks': []}),
      isNull,
    );
    await programs.setGrants(package.id, package.permissions);
    await programs.setEnabled(package.id, true);
    final snapshot = ProgramSnapshot([a, b], {a.id});
    final result = await programs.invoke(package.id, 'library', {
      'tracks': snapshot.rows,
      'filters': {'favorites': true},
    });
    expect(result, isNotNull, reason: programs.installed[package.id]!.error);
    expect(snapshot.resolve(result!['ids']).single.id, a.id);
    final restored = ProgramController(store);
    await restored.initialize();
    expect(restored.owner('library')!.package.id, package.id);
    expect(restored.privateData[package.id]?['filters']['favorites'], true);
    programs.dispose();
    restored.dispose();
  });
  test('filtros combinados ejecutados por programa Dart real', () async {
    final package = await example('biblioteca-viva');
    final programs = ProgramController(Registry());
    await programs.install(package, package.permissions);
    final snapshot = ProgramSnapshot([a, b], {a.id});
    final filtered = await programs.invoke(package.id, 'library', {
      'tracks': snapshot.rows,
      'filters': {
        'artist': 'Uno',
        'folder': 'Rock',
        'maxSeconds': 180,
        'favorites': true,
        'query': 'álbum',
      },
    });
    expect(filtered, isNotNull, reason: programs.installed[package.id]!.error);
    expect(snapshot.resolve(filtered!['ids']).map((track) => track.id), [a.id]);
    final empty = await programs.invoke(package.id, 'library', {
      'tracks': snapshot.rows,
      'filters': {'artist': 'Dos', 'maxSeconds': 180},
    });
    expect(empty!['ids'], isEmpty);
    expect(snapshot.rows.first['id'], isNot(contains('/private/')));
    expect(() => snapshot.resolve(['/private/a.mp3']), throwsFormatException);
    expect(
      () => snapshot.resolve([
        snapshot.rows.first['id'],
        snapshot.rows.first['id'],
      ]),
      throwsFormatException,
    );
    programs.dispose();
  });
  test('varias activas: conflictos requieren selección, actualización inválida conserva la anterior', () async {
    final first = await example('biblioteca-viva');
    final second = ProgramPackage.parse({
      ...first.toJson(),
      'id': 'otro.autor',
      'name': 'Otra biblioteca',
    });
    final programs = ProgramController(Registry());
    await programs.install(first, first.permissions);
    await programs.install(second, second.permissions);
    expect(programs.installed.values.where((item) => item.enabled).length, 2);
    expect(programs.owner('library')!.package.id, first.id);
    await programs.choose('library', second.id);
    expect(programs.owner('library')!.package.id, second.id);
    final invalid = ProgramPackage.parse({
      ...second.toJson(),
      'source': 'not valid dart',
    });
    await expectLater(
      programs.install(invalid, invalid.permissions),
      throwsFormatException,
    );
    expect(programs.installed[second.id]!.package.source, second.source);
    await programs.setGrants(second.id, {});
    expect(programs.owner('library'), isNull);
    expect(programs.installed[first.id]!.enabled, true);
    programs.dispose();
  });
  test('tres fallos aíslan la extensión; recuperación desactiva solo la que quedó ejecutándose', () async {
    final package = await example('pulso-nocturno');
    final bad = ProgramPackage.parse({
      ...package.toJson(),
      'source': "String run(String input) { throw 'fallo de prueba'; }",
    });
    final store = Registry();
    final programs = ProgramController(store);
    await programs.install(bad, bad.permissions);
    for (var i = 0; i < 3; i++) {
      expect(await programs.invoke(bad.id, 'player', {}), isNull);
    }
    expect(programs.installed[bad.id]!.enabled, false);
    expect(programs.owner('player'), isNull);
    await programs.install(package, package.permissions);
    store.data['running'] = package.id;
    final restored = ProgramController(store);
    await restored.initialize();
    expect(restored.installed[package.id]!.enabled, false);
    expect(restored.installed[package.id]!.error, isNotNull);
    programs.dispose();
    restored.dispose();
  });
  test(
    'listas automáticas se recalculan y desactivar conserva datos/carátula',
    () async {
      final package = await example('biblioteca-viva');
      final library = LibraryController(Registry(), MusicFiles())
        ..loading = false
        ..tracks = [a];
      final programs = ProgramController(Registry());
      await programs.install(package, package.permissions);
      library.attachPrograms(programs);
      await library.createSmartPlaylist(
        'Rock corto',
        package.id,
        {'maxSeconds': 180},
        [a.id],
      );
      await library.setPlaylistCover('Rock corto', 'private-cover.png');
      final audio = MusicHandler(player: FakePlayer());
      final coordinator = ProgramCoordinator(library, programs, audio);
      library.tracks = [
        a,
        b,
        const Track(
          id: '/private/c.mp3',
          title: 'C',
          folder: 'Rock',
          durationMs: 1000,
        ),
      ];
      await coordinator.refresh();
      expect(library.playlists['Rock corto'], [a.id, '/private/c.mp3']);
      await programs.setEnabled(package.id, false);
      library.tracks = [a, b];
      await coordinator.refresh();
      expect(library.playlists['Rock corto'], [a.id, '/private/c.mp3']);
      expect(library.playlistMeta['Rock corto']?['cover'], 'private-cover.png');
      await programs.setEnabled(package.id, true);
      await coordinator.refresh();
      expect(library.playlists['Rock corto'], [a.id]);
      await library.addToPlaylist('Rock corto', b.id);
      expect(library.playlists['Rock corto'], [a.id]);
      coordinator.dispose();
      library.dispose();
      programs.dispose();
      await audio.close();
    },
  );
  test(
    'política programable elige otro artista y reproductor devuelve un diseño',
    () async {
      final package = await example('pulso-nocturno');
      final library = LibraryController(Registry(), MusicFiles())
        ..loading = false
        ..tracks = [a, b];
      final programs = ProgramController(Registry());
      await programs.install(package, package.permissions);
      library.attachPrograms(programs);
      final audio = MusicHandler(player: FakePlayer());
      final coordinator = ProgramCoordinator(library, programs, audio);
      await audio.select([a, b], 0, autoplay: false);
      audio.shuffle = true;
      await audio.skipToNext();
      expect(audio.mediaItem.value!.id, b.id);
      final view = await programs.invoke(package.id, 'player', {'title': 'B'});
      expect(view!['layout'], 'controlsFirst');
      await programs.restoreBase();
      expect(programs.owner('shuffle'), isNull);
      coordinator.dispose();
      library.dispose();
      programs.dispose();
      await audio.close();
    },
  );
}
