import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/data/download_tags.dart';
import 'package:rp_music/data/embedded_lyrics.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/lyrics.dart';

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
}
