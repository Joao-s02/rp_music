import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/data/download_tags.dart';
import 'package:rp_music/data/embedded_lyrics.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/lyrics.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/lyrics/lyrics_controller.dart';
import 'package:rp_music/sources/extension_source_service.dart';
import 'package:rp_music/sources/download_enrichment.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'program_system_test.dart' show Registry;
import 'playback_and_ui_test.dart' show FakePlayer;
import 'extension_source_test.dart' show cloudPackage;

Uint8List box(String name, List<int> body) => Uint8List.fromList([
  ...(ByteData(4)..setUint32(0, body.length + 8)).buffer.asUint8List(),
  ...latin1.encode(name),
  ...body,
]);

class ReadOnlyFiles extends MusicFiles {
  String? text;
  int calls = 0;
  @override
  Future<String?> embeddedLyrics(String id) async {
    calls++;
    return text;
  }
}

class LyricsService extends ExtensionSourceService {
  LyricsService(super.programs) : super(platform: 'windows');
  int calls = 0;
  Map<String, dynamic> result = {'syncedLyrics': '[00:01]Encontrada'};
  Completer<void>? gate;
  @override
  Future<Map<String, dynamic>> invoke(
    String id,
    String operation,
    Map<String, dynamic> input, {
    bool localLyrics = false,
  }) async {
    calls++;
    await gate?.future;
    return result;
  }
}

ProgramPackage provider() => ProgramPackage.parse({
  'apiVersion': 2,
  'id': 'test.lyrics',
  'name': 'Letras sintéticas',
  'version': '1.0.0',
  'minAppVersion': '0.3.5',
  'description': 'Prueba de contrato genérico.',
  'permissions': ['network.http', 'library.read', 'lyrics.cache'],
  'capabilities': ['lyrics'],
  'sourceConfig': {
    'name': 'Prueba',
    'domains': ['example.com'],
    'platforms': ['windows', 'android'],
  },
  'source': 'String run(String request) => "{}";',
});

void main() {
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('lyrics035_');
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });

  test(
    'M4A incrusta UTF-8, portada y números sin mover ni alterar audio',
    () async {
      final media = box('mdat', List.generate(256, (i) => i));
      final source = Uint8List.fromList([
        ...box('ftyp', ascii.encode('M4A \x00\x00\x00\x00M4A ')),
        ...box('moov', []),
        ...media,
      ]);
      final before = sha256.convert(source).toString();
      final tagged = DownloadTags.mp4(
        source,
        {
          'title': 'Canción ñ',
          'artist': 'Artista',
          'album': 'Álbum',
          'albumArtist': 'Artista',
          'lyrics': '[00:01]Línea ñ\n[00:02]Otra',
          'date': '2024-05-01',
          'trackNumber': 2,
          'trackTotal': 12,
          'discNumber': 1,
          'discTotal': 1,
        },
        cover: Uint8List.fromList([255, 216, 255, 217]),
        coverMime: 'image/jpeg',
      );
      final location = source.length - media.length;
      expect(tagged.sublist(location, location + media.length), media);
      expect(sha256.convert(source).toString(), before);
      final file = File('${root.path}/tagged.m4a')..writeAsBytesSync(tagged);
      final metadata = readMetadata(file, getImage: true);
      expect(metadata.title, 'Canción ñ');
      expect(metadata.album, 'Álbum');
      expect(metadata.trackNumber, 2);
      expect(metadata.pictures.single.bytes, [255, 216, 255, 217]);
      expect(
        await MusicFiles().embeddedLyrics(file.path),
        '[00:01]Línea ñ\n[00:02]Otra',
      );
    },
  );

  test(
    'M4A con mdat hasta EOF y reemplazo de etiquetas conserva carga útil',
    () async {
      final media = box('mdat', [1, 2, 3, 4]);
      ByteData.sublistView(media).setUint32(0, 0);
      final source = Uint8List.fromList([
        ...box('ftyp', ascii.encode('M4A \x00\x00\x00\x00M4A ')),
        ...box('moov', []),
        ...media,
      ]);
      final first = DownloadTags.mp4(source, {
        'title': 'Primero',
        'lyrics': 'Letra',
      });
      final twice = DownloadTags.mp4(first, {
        'title': 'Segundo',
        'lyrics': 'Otra letra',
      });
      final file = File('${root.path}/twice.m4a')..writeAsBytesSync(twice);
      expect(readMetadata(file).title, 'Segundo');
      expect(EmbeddedLyrics.read(file), 'Otra letra');
      expect(
        () => DownloadTags.mp4(Uint8List.fromList([1, 2, 3]), {}),
        throwsFormatException,
      );
    },
  );

  test('SYLT v2.3 milisegundos se convierte en LRC y sigue seek', () {
    final body = <int>[3, ...ascii.encode('spa'), 2, 1, 0];
    for (final entry in {'Primera': 1000, 'Segunda': 2350}.entries) {
      body.addAll([
        ...utf8.encode(entry.key),
        0,
        ...(ByteData(4)..setUint32(0, entry.value)).buffer.asUint8List(),
      ]);
    }
    final frame = Uint8List.fromList([
      ...ascii.encode('SYLT'),
      ...(ByteData(4)..setUint32(0, body.length)).buffer.asUint8List(),
      0,
      0,
      ...body,
    ]);
    final text = EmbeddedLyrics.id3(frame, 3, 0)!;
    final parsed = Lyrics.parse(text);
    expect(parsed.lines.map((l) => l.text), ['Primera', 'Segunda']);
    expect(parsed.activeAt(const Duration(milliseconds: 2400)), 1);
    expect(parsed.activeAt(Duration.zero), -1);
    expect(
      EmbeddedLyrics.id3(Uint8List.sublistView(frame, 0, 12), 3, 0),
      isNull,
    );
  });

  test(
    'incrustadas tienen prioridad; caché persiste sin modificar canción',
    () async {
      final original = File('${root.path}/song.mp3')
        ..writeAsBytesSync([1, 2, 3]);
      final hash = sha256.convert(original.readAsBytesSync());
      final files = ReadOnlyFiles()..text = 'Ya incrustada';
      final programs = ProgramController(Registry());
      final p = provider();
      programs.installed[p.id] = InstalledProgram(
        p,
        p.permissions,
        enabled: true,
      );
      programs.owners['lyrics'] = p.id;
      final service = LyricsService(programs);
      var controller = LyricsController(
        root,
        files,
        programs,
        service: service,
      );
      final track = Track(id: original.path, title: 'Prueba', folder: '.');
      expect((await controller.ensure(track))!.plain, 'Ya incrustada');
      expect(service.calls, 0);
      controller.dispose();
      files.text = null;
      controller = LyricsController(root, files, programs, service: service);
      expect((await controller.ensure(track))!.lines.single.text, 'Encontrada');
      expect(service.calls, 1);
      controller.dispose();
      controller = LyricsController(root, files, programs, service: service);
      expect((await controller.ensure(track))!.lines.single.text, 'Encontrada');
      expect(service.calls, 1);
      expect(sha256.convert(original.readAsBytesSync()), hash);
      controller.dispose();
      programs.dispose();
    },
  );

  test('ausencia evita reconsultas incluso tras reiniciar; reintento manual funciona', () async {
    final files = ReadOnlyFiles();
    final programs = ProgramController(Registry());
    final p = provider();
    programs.installed[p.id] = InstalledProgram(
      p,
      p.permissions,
      enabled: true,
    );
    programs.owners['lyrics'] = p.id;
    final service = LyricsService(programs)..result = {'plainLyrics': ''};
    const track = Track(id: '/missing.mp3', title: 'Prueba', folder: '.');
    var controller = LyricsController(root, files, programs, service: service);
    await controller.ensure(track);
    await controller.ensure(track);
    expect(service.calls, 1);
    controller.dispose();
    controller = LyricsController(root, files, programs, service: service);
    await controller.ensure(track);
    expect(service.calls, 1);
    service.result = {'plainLyrics': 'Nueva'};
    expect(
      (await controller.ensure(track, forceNetwork: true))!.plain,
      'Nueva',
    );
    expect(service.calls, 2);
    controller.dispose();
    programs.dispose();
  });

  test('revocar proveedor descarta respuesta antes de guardar letra', () async {
    final programs = ProgramController(Registry());
    final p = provider();
    programs.installed[p.id] = InstalledProgram(
      p,
      p.permissions,
      enabled: true,
    );
    programs.owners['lyrics'] = p.id;
    final gate = Completer<void>();
    final service = LyricsService(programs)..gate = gate;
    final controller = LyricsController(
      root,
      ReadOnlyFiles(),
      programs,
      service: service,
    );
    const track = Track(id: '/a.mp3', title: 'Prueba', folder: '.');
    final task = controller.ensure(track);
    while (service.calls == 0) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    programs.installed[p.id]!.enabled = false;
    gate.complete();
    await task;
    expect(controller.values, isEmpty);
    expect(controller.file(track.id).existsSync(), isFalse);
    controller.dispose();
    programs.dispose();
  });

  test(
    'seleccionar canción local inicia búsqueda sin abrir pantalla de letras',
    () async {
      final programs = ProgramController(Registry());
      final p = provider();
      programs.installed[p.id] = InstalledProgram(
        p,
        p.permissions,
        enabled: true,
      );
      programs.owners['lyrics'] = p.id;
      final service = LyricsService(programs);
      final audio = MusicHandler(player: FakePlayer());
      final controller = LyricsController(
        root,
        ReadOnlyFiles(),
        programs,
        service: service,
      )..follow(audio);
      await audio.select([
        const Track(id: '/auto.mp3', title: 'Automática', folder: '.'),
      ], 0);
      final deadline = DateTime.now().add(const Duration(seconds: 3));
      while (!controller.values.containsKey('/auto.mp3') &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(service.calls, 1);
      expect(controller.file('/auto.mp3').existsSync(), isTrue);
      controller.dispose();
      await audio.close();
      programs.dispose();
    },
  );

  test(
    'el escritor aislado recibe datos sin capturar el registro de extensiones',
    () async {
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
      final port = ReceivePort();
      programs.addListener(() {
        port.sendPort.send('Cambio');
      });
      final service = LyricsService(programs)
        ..result = {
          'tags': {'title': 'Etiquetada', 'artist': 'Artista'},
          'plainLyrics': 'Letra sintética',
          'complete': false,
        };
      final bytes = Uint8List.fromList([
        ...box('ftyp', ascii.encode('M4A \x00\x00\x00\x00M4A ')),
        ...box('moov', []),
        ...box('mdat', [1, 2, 3]),
      ]);
      try {
        final result = await DownloadEnrichment.apply(
          Track(
            id: ExtensionSourceService.trackId(p.id, 'test'),
            sourceId: p.id,
            title: 'Inicial',
            folder: '.',
          ),
          bytes,
          'audio/mp4',
          service,
        );
        final file = File('${root.path}/isolated.m4a')
          ..writeAsBytesSync(result.bytes);
        // Download metadata must not replace the selected song's identity.
        expect(readMetadata(file).title, 'Inicial');
        expect(EmbeddedLyrics.read(file), 'Letra sintética');
      } finally {
        port.close();
        programs.dispose();
      }
    },
  );

  test('una importación manual durante búsqueda no es reemplazada por respuesta tardía', () async {
    final programs = ProgramController(Registry());
    final p = provider();
    programs.installed[p.id] = InstalledProgram(
      p,
      p.permissions,
      enabled: true,
    );
    programs.owners['lyrics'] = p.id;
    final gate = Completer<void>();
    final service = LyricsService(programs)..gate = gate;
    final controller = LyricsController(
      root,
      ReadOnlyFiles(),
      programs,
      service: service,
    );
    const track = Track(id: '/manual.mp3', title: 'Prueba', folder: '.');
    final task = controller.ensure(track);
    while (service.calls == 0) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    await controller.save(track.id, 'Elegida por el usuario');
    gate.complete();
    await task;
    expect(controller.values[track.id]!.plain, 'Elegida por el usuario');
    expect(
      await controller.file(track.id).readAsString(),
      'Elegida por el usuario',
    );
    controller.dispose();
    programs.dispose();
  });
}
