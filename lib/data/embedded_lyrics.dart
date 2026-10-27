import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class EmbeddedLyrics {
  static String? read(File file) {
    final reader = file.openSync();
    String? synced;
    try {
      final header = reader.readSync(10);
      if (header.length == 10 &&
          ascii.decode(header.sublist(0, 3), allowInvalid: true) == 'ID3' &&
          [3, 4].contains(header[3]) &&
          header[5] & 0x80 == 0) {
        final size = _syncSafe(header, 6);
        if (size <= 16 * 1024 * 1024 && size <= reader.lengthSync() - 10) {
          synced = id3(reader.readSync(size), header[3], header[5]);
        }
      }
    } finally {
      reader.closeSync();
    }
    final text = synced ?? readMetadata(file, getImage: false).lyrics;
    if (text == null || text.trim().isEmpty) return null;
    if (utf8.encode(text).length > 262144) {
      throw const FormatException('La letra incrustada supera 256 KB.');
    }
    return text.replaceFirst('\ufeff', '').trim();
  }

  static int _syncSafe(List<int> data, int offset) =>
      (data[offset] & 127) << 21 |
      (data[offset + 1] & 127) << 14 |
      (data[offset + 2] & 127) << 7 |
      data[offset + 3] & 127;

  /// ID3v2.3/2.4 synchronized text with millisecond timestamps (SYLT).
  static String? id3(Uint8List body, int version, int flags) {
    var offset = 0;
    if (flags & 0x40 != 0) {
      if (body.length < 4) return null;
      offset = version == 4
          ? _syncSafe(body, 0)
          : ByteData.sublistView(body).getUint32(0) + 4;
    }
    while (offset >= 0 && offset + 10 <= body.length) {
      final type = latin1.decode(body.sublist(offset, offset + 4));
      if (!RegExp(r'^[A-Z0-9]{4}$').hasMatch(type)) break;
      final size = version == 4
          ? _syncSafe(body, offset + 4)
          : ByteData.sublistView(body).getUint32(offset + 4);
      final formatFlags = body[offset + 9];
      offset += 10;
      if (size <= 0 || size > body.length - offset) break;
      if (type == 'SYLT' &&
          (version == 4 ? formatFlags & 0x4f == 0 : formatFlags & 0xe0 == 0)) {
        final value = _sylt(Uint8List.sublistView(body, offset, offset + size));
        if (value != null) return value;
      }
      offset += size;
    }
    return null;
  }

  static String? _sylt(Uint8List data) {
    if (data.length < 7 || data[0] > 3 || data[4] != 2 || data[5] != 1) {
      return null;
    }
    final encoding = data[0];
    final width = encoding == 1 || encoding == 2 ? 2 : 1;
    var offset = 6;
    var littleEndian = false;
    String? readText() {
      final start = offset;
      while (offset + width <= data.length) {
        if (data[offset] == 0 && (width == 1 || data[offset + 1] == 0)) {
          final bytes = data.sublist(start, offset);
          offset += width;
          if (encoding == 0) return latin1.decode(bytes);
          if (encoding == 3) return utf8.decode(bytes, allowMalformed: true);
          var from = 0;
          if (bytes.length >= 2 && bytes[0] == 255 && bytes[1] == 254) {
            littleEndian = true;
            from = 2;
          } else if (bytes.length >= 2 && bytes[0] == 254 && bytes[1] == 255) {
            littleEndian = false;
            from = 2;
          }
          final units = <int>[];
          for (var i = from; i + 1 < bytes.length; i += 2) {
            units.add(
              littleEndian
                  ? bytes[i] | bytes[i + 1] << 8
                  : bytes[i] << 8 | bytes[i + 1],
            );
          }
          return String.fromCharCodes(units);
        }
        offset += width;
      }
      return null;
    }

    if (readText() == null) {
      return null; // Description, with its own terminator.
    }
    final output = StringBuffer();
    while (offset < data.length) {
      final text = readText();
      if (text == null || data.length - offset < 4) return null;
      final ms = ByteData.sublistView(data).getUint32(offset);
      offset += 4;
      if (ms >= 60000000) return null;
      final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
      final seconds = ((ms ~/ 1000) % 60).toString().padLeft(2, '0');
      final fraction = (ms % 1000).toString().padLeft(3, '0');
      output.writeln(
        '[$minutes:$seconds.$fraction]${text.replaceAll(RegExp(r'[\r\n]+'), ' ').trim()}',
      );
      if (output.length > 262144) {
        throw const FormatException('Letra demasiado grande.');
      }
    }
    return output.isEmpty ? null : output.toString().trim();
  }
}
