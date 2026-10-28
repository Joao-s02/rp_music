import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Bounded aART reader for the MP4 field omitted by the metadata dependency.
String? mp4AlbumArtist(File file) {
  final reader = file.openSync();
  try {
    var offset = 0;
    final length = reader.lengthSync();
    while (offset + 8 <= length) {
      reader.setPositionSync(offset);
      final head = reader.readSync(16);
      if (head.length < 8) return null;
      var size = ByteData.sublistView(head).getUint32(0);
      var header = 8;
      if (size == 1) {
        if (head.length < 16) return null;
        size = ByteData.sublistView(head).getUint64(8);
        header = 16;
      }
      if (size == 0) size = length - offset;
      if (size < header || offset + size > length) return null;
      if (latin1.decode(head.sublist(4, 8)) == 'moov') {
        if (size > 8 * 1024 * 1024) return null;
        reader.setPositionSync(offset + header);
        return _find(reader.readSync(size - header), 0);
      }
      offset += size;
    }
  } catch (_) {
    return null;
  } finally {
    reader.closeSync();
  }
  return null;
}

String? _find(Uint8List bytes, int depth) {
  if (depth > 6) return null;
  for (var offset = 0; offset + 8 <= bytes.length;) {
    final size = ByteData.sublistView(bytes).getUint32(offset);
    if (size < 8 || offset + size > bytes.length) return null;
    final kind = latin1.decode(bytes.sublist(offset + 4, offset + 8));
    final start = offset + 8 + (kind == 'meta' ? 4 : 0);
    if (start > offset + size) return null;
    if (kind == 'aART') {
      final data = Uint8List.sublistView(bytes, start, offset + size);
      if (data.length >= 16 &&
          latin1.decode(data.sublist(4, 8)) == 'data' &&
          data.length <= 4112) {
        return utf8.decode(data.sublist(16), allowMalformed: true).trim();
      }
    }
    if (['udta', 'meta', 'ilst'].contains(kind)) {
      final result = _find(
        Uint8List.sublistView(bytes, start, offset + size),
        depth + 1,
      );
      if (result != null) return result;
    }
    offset += size;
  }
  return null;
}
