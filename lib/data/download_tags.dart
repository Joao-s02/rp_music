import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

/// Adds iTunes-compatible tags to a newly downloaded ISO-BMFF audio file.
/// Flat files keep their media offsets using a trailing moov. Fragmented files
/// keep their initialization before the fragments and require relative offsets.
/// Audio is never re-encoded.
class DownloadTags {
  /// Streams media payloads unchanged; only bounded MP4 headers enter memory.
  static Future<File> mp4File(
    File audio,
    Map<String, dynamic> tags, {
    Uint8List? cover,
    String? coverMime,
  }) async {
    final input = await audio.open();
    final boxes =
        <({String type, int start, int size, int width, Uint8List raw})>[];
    try {
      final length = await input.length();
      var offset = 0, metadataBytes = 0;
      while (offset < length) {
        await input.setPosition(offset);
        final header = await input.read(16.clamp(0, length - offset));
        if (header.length < 8) {
          throw const FormatException('Contenedor truncado.');
        }
        final view = ByteData.sublistView(header);
        var size = view.getUint32(0), width = 8;
        if (size == 1) {
          if (header.length < 16) {
            throw const FormatException('Cabecera truncada.');
          }
          size = view.getUint64(8);
          width = 16;
        } else if (size == 0) {
          size = length - offset;
        }
        if (size < width || size > length - offset) {
          throw const FormatException('Tamaño MP4 inválido.');
        }
        final type = latin1.decode(header.sublist(4, 8));
        Uint8List raw;
        if (type == 'mdat') {
          raw = _box('mdat', Uint8List(0));
        } else {
          metadataBytes += size;
          if (metadataBytes > 32 * 1024 * 1024 || size > 8 * 1024 * 1024) {
            throw const FormatException('Cabeceras MP4 demasiado grandes.');
          }
          await input.setPosition(offset);
          raw = await input.read(size);
          if (raw.length != size) {
            throw const FormatException('Contenedor truncado.');
          }
          raw = _explicitSize(raw);
        }
        boxes.add((
          type: type,
          start: offset,
          size: size,
          width: width,
          raw: raw,
        ));
        offset += size;
      }
    } finally {
      await input.close();
    }
    // Reuse exactly the same metadata writer and fragmented-offset validation.
    final tagged = _boxes(
      mp4(
        _join(boxes.map((b) => b.raw)),
        tags,
        cover: cover,
        coverMime: coverMime,
      ),
    );
    final newMoov = tagged.singleWhere((b) => b.type == 'moov').raw;
    final original = boxes.indexWhere((b) => b.type == 'moov');
    final fragment = boxes.indexWhere((b) => b.type == 'moof');
    final index = boxes.indexWhere((b) => b.type == 'sidx');
    final insertion = fragment < 0
        ? boxes.length
        : original < fragment
        ? original
        : index >= 0 && index < fragment
        ? index
        : fragment;
    final result = File('${audio.path}.tagged');
    final sink = result.openWrite();
    try {
      for (var i = 0; i <= boxes.length; i++) {
        if (i == insertion) sink.add(newMoov);
        if (i == boxes.length) break;
        final box = boxes[i];
        if (i == original) {
          if (fragment < 0) sink.add(_box('free', Uint8List(box.size - 8)));
          continue;
        }
        // Explicit size also handles an original trailing mdat with size zero.
        final header = ByteData(box.width)
          ..setUint32(0, box.width == 16 ? 1 : box.size);
        header.buffer.asUint8List().setRange(4, 8, latin1.encode(box.type));
        if (box.width == 16) header.setUint64(8, box.size);
        sink.add(header.buffer.asUint8List());
        await sink.addStream(
          audio.openRead(box.start + box.width, box.start + box.size),
        );
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
    return result;
  }

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
    if (top.any((b) => b.type == 'moof')) {
      return _fragmented(top, moov, body);
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

  static Uint8List _fragmented(List<_Box> top, _Box moov, Uint8List body) {
    final firstFragment = top.indexWhere((b) => b.type == 'moof');
    final original = top.indexOf(moov);
    final firstIndex = top.indexWhere((b) => b.type == 'sidx');
    // A trailing initialization is the broken layout emitted by 0.3.5. It can
    // be repaired only when the relative-addressing checks below succeed.
    if ((original > firstFragment && original != top.length - 1) ||
        (original < firstFragment &&
            firstIndex >= 0 &&
            firstIndex < original) ||
        top.any((b) => ['mfra', 'tfra'].contains(b.type)) ||
        top.take(firstFragment).any((b) => b.type == 'mdat')) {
      throw const FormatException('Índices de MP4 fragmentado no compatibles.');
    }
    void checkTables(Uint8List data, int depth) {
      if (depth > 16) {
        throw const FormatException('Contenedor demasiado profundo.');
      }
      for (final child in _boxes(data)) {
        if (['stco', 'co64'].contains(child.type)) {
          if (child.data.length < 8 ||
              ByteData.sublistView(child.data).getUint32(4) != 0) {
            throw const FormatException(
              'Desplazamientos absolutos no compatibles.',
            );
          }
        } else if ([
          'trak',
          'mdia',
          'minf',
          'stbl',
          'mvex',
        ].contains(child.type)) {
          checkTables(child.data, depth + 1);
        }
      }
    }

    checkTables(moov.data, 0);
    for (final fragment in top.where((b) => b.type == 'moof')) {
      final tracks = _boxes(fragment.data)
          .where((b) => b.type == 'traf')
          .toList();
      if (tracks.isEmpty) throw const FormatException('Fragmento sin pistas.');
      for (final track in tracks) {
        final children = _boxes(track.data);
        final headers = children.where((b) => b.type == 'tfhd').toList();
        if (headers.length != 1 ||
            headers.single.data.length < 8 ||
            children.any((b) => ['saio', 'senc'].contains(b.type))) {
          throw const FormatException('Cabecera de fragmento no compatible.');
        }
        final flags =
            ByteData.sublistView(headers.single.data).getUint32(0) & 0xffffff;
        if (flags & 0x020000 == 0 || flags & 1 != 0) {
          throw const FormatException(
            'El fragmento no usa posiciones relativas.',
          );
        }
        final runs = children.where((b) => b.type == 'trun').toList();
        if (runs.isEmpty ||
            runs.first.data.length < 12 ||
            ByteData.sublistView(runs.first.data).getUint32(0) & 1 == 0) {
          throw const FormatException(
            'Fragmento sin posición de audio relativa.',
          );
        }
      }
    }
    final insertion = original < firstFragment
        ? original
        : firstIndex >= 0 && firstIndex < firstFragment
        ? firstIndex
        : firstFragment;
    final output = <Uint8List>[];
    for (var i = 0; i < top.length; i++) {
      if (i == insertion) output.add(_box('moov', body));
      if (i != original) output.add(_explicitSize(top[i].raw));
    }
    // sidx and all moof/mdat pairs move together; their relative offsets and
    // every media byte are unchanged. Absolute-offset variants fail closed.
    return _join(output);
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
