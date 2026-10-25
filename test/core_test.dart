import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/extension_manifest.dart';
import 'package:rp_music/domain/track.dart';

class FakeFiles extends MusicFiles {
  bool fail = false;
  String? selection;
  bool preview = false;
  Future<void> Function()? beforeFinish;
  List<Track> result = const [Track(id: 'song', title: 'Canción', folder: '.')];
  @override
  Future<String?> chooseRoot() async => selection;
  @override
  Future<ScanResult> scan(
    String root, {
    List<Track> cached = const [],
    void Function(ScanProgress)? onProgress,
  }) async {
    if (preview) {
      onProgress?.call(ScanProgress(result, 0, result.length, discovery: true));
    }
    await beforeFinish?.call();
    if (fail) throw const FileSystemException('Sin acceso');
    return ScanResult(result, 0);
  }
}

void main() {
  late Directory temporary;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('rp_music_test_');
  });
  tearDown(() async {
    await temporary.delete(recursive: true);
  });

  test(
    'listas cuentan disponibles y conservan referencias al cambiar de raíz',
    () async {
      final files = FakeFiles();
      final controller = LibraryController(LocalStore(temporary), files);
      await controller.initialize();
      await controller.refresh('primera');
      await controller.addPlaylist('Viaje');
      await controller.addToPlaylist('Viaje', 'song');
      files.result = const [Track(id: 'otra', title: 'Otra', folder: '.')];
      await controller.refresh('segunda');
      expect(controller.playlistTracks('Viaje'), isEmpty);
      expect(controller.missingInPlaylist('Viaje'), 1);
      expect(controller.playlists['Viaje'], ['song']);
      files.result = const [Track(id: 'song', title: 'Canción', folder: '.')];
      await controller.refresh('primera');
      expect(controller.playlistTracks('Viaje').single.id, 'song');
      await controller.removeFromPlaylist('Viaje', 'song');
      final restored = LibraryController(LocalStore(temporary), files);
      await restored.initialize();
      expect(restored.playlists['Viaje'], isEmpty);
      controller.dispose();
      restored.dispose();
    },
  );

  test(
    'quitar no disponibles limpia solo las referencias ajenas al catálogo',
    () async {
      final controller = LibraryController(LocalStore(temporary), FakeFiles());
      await controller.initialize();
      await controller.refresh('raíz');
      await controller.addPlaylist('Lista');
      await controller.addToPlaylist('Lista', 'song');
      await controller.addToPlaylist('Lista', 'ausente');
      await controller.removeMissingFromPlaylist('Lista');
      expect(controller.playlists['Lista'], ['song']);
      controller.dispose();
    },
  );

  test('escaneo publica archivos antes de etiquetas y reutiliza solo huellas intactas', () async {
    final file = await File('${temporary.path}/prueba.mp3').writeAsBytes([0]);
    final stat = await file.stat();
    final scannedId = scanDirectory(temporary.path).tracks.single.id;
    final cached = Track(
      id: scannedId,
      title: 'Etiqueta cacheada',
      folder: '.',
      size: stat.size,
      modifiedMs: stat.modified.millisecondsSinceEpoch,
      metadataLoaded: true,
    );
    final progress = <ScanProgress>[];
    final result = await MusicFiles().scan(
      temporary.path,
      cached: [cached],
      onProgress: progress.add,
    );
    expect(progress.first.discovery, isTrue);
    expect(progress.first.processed, 0);
    expect(progress.first.batch.single.metadataLoaded, isFalse);
    expect(result.tracks.single.title, 'Etiqueta cacheada');
    expect(result.skipped, 0);
    await file.writeAsBytes([0, 1]);
    final changed = scanDirectory(temporary.path, cached: [cached]);
    expect(changed.tracks.single.title, 'prueba');
    expect(changed.skipped, 1);
  });

  test(
    'escaneo recursivo incluye formatos, respeta raíz y omite no musicales',
    () async {
      final nested = await Directory('${temporary.path}/Álbum').create();
      for (final extension in ['MP3', 'flac', 'm4a', 'mp4', 'wav', 'opus']) {
        await File('${nested.path}/Tema.$extension').writeAsBytes([0]);
      }
      await File('${nested.path}/notas.txt').writeAsString('no audio');
      final result = scanDirectory(temporary.path);
      expect(result.tracks, hasLength(6));
      expect(result.tracks.every((t) => t.folder == 'Álbum'), isTrue);
      expect(result.tracks.every((t) => t.title == 'Tema'), isTrue);
      expect(
        result.skipped,
        6,
      ); // Invalid tags fall back to file names, without dropping tracks.
    },
  );

  test('WAV válido conserva duración sin cargar imágenes', () async {
    final bytes = ByteData(44 + 16000);
    void ascii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    bytes.setUint32(4, bytes.lengthInBytes - 8, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, 8000, Endian.little);
    bytes.setUint32(28, 16000, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    bytes.setUint32(40, 16000, Endian.little);
    await File('${temporary.path}/Silencio.wav')
        .writeAsBytes(bytes.buffer.asUint8List());
    final result = scanDirectory(temporary.path);
    expect(result.tracks.single.durationMs, 1000);
    expect(result.skipped, 0);
  });

  test(
    'guardados concurrentes conservan el más reciente y recuperan el respaldo',
    () async {
      final store = LocalStore(temporary);
      await Future.wait([
        store.save({'revision': 1}),
        store.save({'revision': 2}),
      ]);
      expect((await store.load())['revision'], 2);
      await File('${temporary.path}/library.json').writeAsString('{roto');
      expect((await store.load())['revision'], 1);
    },
  );

  test(
    'cancelar o fallar un cambio de raíz conserva la biblioteca anterior',
    () async {
      final files = FakeFiles();
      final controller = LibraryController(LocalStore(temporary), files);
      await controller.initialize();
      await controller.refresh('original');
      await controller.chooseRoot();
      expect(controller.root, 'original');
      files.fail = true;
      files.preview = true;
      files.result = const [
        Track(id: 'preview', title: 'Temporal', folder: '.'),
      ];
      files.beforeFinish = () async {
        expect(controller.tracks.single.id, 'preview');
        await controller.toggleFavorite('song');
        final snapshot = await controller.store.load();
        expect(snapshot['root'], 'original');
        expect((snapshot['tracks'] as List).single['id'], 'song');
      };
      await controller.refresh('otra');
      expect(controller.root, 'original');
      expect(controller.tracks.single.id, 'song');
      expect(controller.scanning, isFalse);
      controller.dispose();
    },
  );

  test(
    'favoritos y listas sobreviven un reinicio y evitan duplicados',
    () async {
      final controller = LibraryController(LocalStore(temporary), FakeFiles());
      await controller.initialize();
      await controller.refresh('raíz');
      await controller.toggleFavorite('song');
      await controller.addPlaylist('Viaje');
      await controller.addToPlaylist('Viaje', 'song');
      await controller.addToPlaylist('Viaje', 'song');
      final restored = LibraryController(LocalStore(temporary), FakeFiles());
      await restored.initialize();
      expect(restored.favorites, {'song'});
      expect(restored.playlists['Viaje'], ['song']);
      expect(restored.root, 'raíz');
      controller.dispose();
      restored.dispose();
    },
  );

  Map<String, dynamic> example() =>
      jsonDecode(File('examples/extensions/descubrir.json').readAsStringSync())
          as Map<String, dynamic>;
  test('ejemplo instalable conserva pantalla y acción al serializar', () {
    final extension = ExtensionManifest.parse(example());
    final restored = ExtensionManifest.parse(extension.toJson());
    expect(restored.layout, 'cards');
    expect(restored.randomAction, isTrue);
    expect(restored.accent, 0xffc6b5ed);
  });
  test('rechaza extensiones con permisos, acciones o API no admitidos', () {
    for (final change in [
      {
        'permissions': ['filesystem'],
      },
      {
        'actions': ['execute'],
      },
      {'apiVersion': 2},
      {
        'screen': {'layout': 'html', 'accent': '#ffffff'},
      },
      {'id': '../escape'},
    ]) {
      expect(
        () => ExtensionManifest.parse({...example(), ...change}),
        throwsFormatException,
      );
    }
  });
  test('selección de extensión y retorno a base son persistentes', () async {
    final controller = LibraryController(LocalStore(temporary), FakeFiles());
    await controller.initialize();
    controller.extensions.add(ExtensionManifest.parse(example()));
    await controller.activateExtension('rp.descubrir');
    final restored = LibraryController(LocalStore(temporary), FakeFiles());
    await restored.initialize();
    expect(restored.activeExtension?.id, 'rp.descubrir');
    await restored.removeExtension('rp.descubrir');
    expect(restored.activeExtension, isNull);
    expect(restored.extensions, isEmpty);
    controller.dispose();
    restored.dispose();
  });
}
