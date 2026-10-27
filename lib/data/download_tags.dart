import 'dart:convert';
import 'dart:typed_data';

/// Adds iTunes-compatible tags to a newly downloaded ISO-BMFF audio file.
/// The old moov is replaced by equally sized free space and the tagged moov is
/// appended. All media/fragment offsets remain unchanged; no audio is encoded.
class DownloadTags {
  static Uint8List mp4(
    Uint8List audio,
    Map<String, dynamic> tags, {
    Uint8List? cover,
    String? coverMime,
  }) {
    if (audio.length > 64 * 1024 * 1024) {
      throw const FormatException('Audio demasiado grande.');
    }
    final top = _boxes(audio);
    final moov = top.where((b) => b.type == 'moov').single;
    if (!top.any((b) => b.type == 'ftyp') ||
        moov.data.length > 8 * 1024 * 1024) {
      throw const FormatException('Contenedor de descarga no compatible.');
    }
    final replacements = <String, Uint8List>{};
    void text(String key, String atom) {
      final value = tags[key];
      if (value == null) return;
      if (value is! String ||
          utf8.encode(value).length > (key == 'lyrics' ? 262144 : 4096)) {
        throw const FormatException('Etiqueta incompatible.');
      }
      if (value.trim().isNotEmpty) {
        replacements[atom] = _box(atom, _data(1, utf8.encode(value.trim())));
      }
    }

    for (final entry in {
      'title': '©nam',
      'artist': '©ART',
      'album': '©alb',
      'albumArtist': 'aART',
      'date': '©day',
      'genre': '©gen',
      'lyrics': '©lyr',
    }.entries) {
      text(entry.key, entry.value);
    }
    void number(String key, String totalKey, String atom) {
      final value = tags[key];
      if (value == null) return;
      final total = tags[totalKey] ?? 0;
      if (value is! int ||
          value < 1 ||
          value > 65535 ||
          total is! int ||
          total < 0 ||
          total > 65535) {
        throw const FormatException('Número de pista/disco inválido.');
      }
      final bytes = ByteData(8)
        ..setUint16(2, value)
        ..setUint16(4, total);
      replacements[atom] = _box(atom, _data(0, bytes.buffer.asUint8List()));
    }

    number('trackNumber', 'trackTotal', 'trkn');
    number('discNumber', 'discTotal', 'disk');
    if (cover != null) {
      if (cover.length > 5 * 1024 * 1024 ||
          !['image/jpeg', 'image/png'].contains(coverMime)) {
        throw const FormatException('Portada incompatible.');
      }
      replacements['covr'] = _box(
        'covr',
        _data(coverMime == 'image/png' ? 14 : 13, cover),
      );
    }
    Uint8List ilst(Uint8List old) => _join([
      ..._boxes(old)
          .where((b) => !replacements.containsKey(b.type))
          .map((b) => b.raw),
      ...replacements.values,
    ]);
    var found = false;
    Uint8List rewrite(Uint8List data, String parent) {
      final output = <Uint8List>[];
      for (final b in _boxes(data)) {
        if (b.type == 'ilst') {
          found = true;
          output.add(_box('ilst', ilst(b.data)));
        } else if (b.type == 'udta') {
          output.add(_box('udta', rewrite(b.data, 'udta')));
        } else if (b.type == 'meta') {
          if (b.data.length < 4) {
            throw const FormatException('Metadatos MP4 dañados.');
          }
          output.add(
            _box(
              'meta',
              _join([
                Uint8List.sublistView(b.data, 0, 4),
                rewrite(Uint8List.sublistView(b.data, 4), 'meta'),
              ]),
            ),
          );
        } else {
          output.add(b.raw);
        }
      }
      return _join(output);
    }

    var body = rewrite(moov.data, 'moov');
    if (!found) {
      final hdlr = _box(
        'hdlr',
        _join([
          Uint8List(8),
          Uint8List.fromList(ascii.encode('mdir')),
          Uint8List(12),
          Uint8List.fromList([0]),
        ]),
      );
      body = _join([
        body,
        _box(
          'udta',
          _box(
            'meta',
            _join([Uint8List(4), hdlr, _box('ilst', ilst(Uint8List(0)))]),
          ),
        ),
      ]);
    }
    return _join([
      ...top.map(
        (b) => identical(b, moov)
            ? _box('free', Uint8List(b.raw.length - 8))
            : _explicitSize(b.raw),
      ),
      _box('moov', body),
    ]);
  }

  static Uint8List _explicitSize(Uint8List raw) {
    if (ByteData.sublistView(raw).getUint32(0) != 0) return raw;
    final copy = Uint8List.fromList(raw);
    ByteData.sublistView(copy).setUint32(0, copy.length);
    return copy;
  }

  static Uint8List _data(int type, List<int> value) => _box(
    'data',
    _join([
      (ByteData(8)..setUint32(0, type)).buffer.asUint8List(),
      Uint8List.fromList(value),
    ]),
  );
  static Uint8List _box(String type, Uint8List value) => _join([
    (ByteData(4)..setUint32(0, value.length + 8)).buffer.asUint8List(),
    Uint8List.fromList(latin1.encode(type)),
    value,
  ]);
  static Uint8List _join(Iterable<Uint8List> values) {
    final b = BytesBuilder(copy: false);
    for (final v in values) {
      b.add(v);
    }
    return b.takeBytes();
  }

  static List<_Box> _boxes(Uint8List data) {
    final result = <_Box>[];
    var offset = 0;
    while (offset < data.length) {
      if (data.length - offset < 8) {
        throw const FormatException('Contenedor truncado.');
      }
      final header = ByteData.sublistView(data, offset);
      var size = header.getUint32(0), width = 8;
      if (size == 1) {
        if (data.length - offset < 16) {
          throw const FormatException('Contenedor truncado.');
        }
        size = header.getUint64(8);
        width = 16;
      } else if (size == 0) {
        size = data.length - offset;
      }
      if (size < width || size > data.length - offset) {
        throw const FormatException('Tamaño de contenedor inválido.');
      }
      result.add(
        _Box(
          latin1.decode(data.sublist(offset + 4, offset + 8)),
          Uint8List.sublistView(data, offset, offset + size),
          Uint8List.sublistView(data, offset + width, offset + size),
        ),
      );
      offset += size;
    }
    return result;
  }
}

class _Box {
  _Box(this.type, this.raw, this.data);
  final String type;
  final Uint8List raw, data;
}
