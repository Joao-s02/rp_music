import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/data/download_tags.dart';

Uint8List atom(String type, List<int> data) => Uint8List.fromList([
  ...(ByteData(4)..setUint32(0, data.length + 8)).buffer.asUint8List(),
  ...latin1.encode(type),
  ...data,
]);
List<({String type, Uint8List raw})> atoms(Uint8List bytes) {
  final result = <({String type, Uint8List raw})>[];
  var offset = 0;
  while (offset < bytes.length) {
    final size = ByteData.sublistView(bytes).getUint32(offset);
    result.add((
      type: latin1.decode(bytes.sublist(offset + 4, offset + 8)),
      raw: Uint8List.sublistView(bytes, offset, offset + size),
    ));
    offset += size;
  }
  return result;
}

Uint8List fragment({int flags = 0x020000}) => atom(
  'moof',
  atom('traf', [
    ...atom(
      'tfhd',
      (ByteData(8)
            ..setUint32(0, flags)
            ..setUint32(4, 1))
          .buffer
          .asUint8List(),
    ),
    ...atom(
      'trun',
      (ByteData(12)
            ..setUint32(0, 1)
            ..setUint32(4, 1)
            ..setInt32(8, 68))
          .buffer
          .asUint8List(),
    ),
  ]),
);

void main() {
  final ftyp = atom('ftyp', ascii.encode('dash\x00\x00\x00\x00iso6mp41'));
  final moov = atom('moov', []);
  final sidx = atom('sidx', List.filled(24, 0));
  final mdat = atom('mdat', List.generate(64, (i) => i));
  test(
    'fragmented MP4 keeps initialization before index and audio fragments',
    () {
      final moof = fragment();
      final original = Uint8List.fromList([
        ...ftyp,
        ...moov,
        ...sidx,
        ...moof,
        ...mdat,
      ]);
      final output = DownloadTags.mp4(original, {
        'title': 'Prueba',
        'lyrics': '[00:01]Texto',
      });
      final boxes = atoms(output);
      expect(boxes.map((b) => b.type), [
        'ftyp',
        'moov',
        'sidx',
        'moof',
        'mdat',
      ]);
      expect(boxes.firstWhere((b) => b.type == 'sidx').raw, sidx);
      expect(boxes.firstWhere((b) => b.type == 'moof').raw, moof);
      expect(boxes.firstWhere((b) => b.type == 'mdat').raw, mdat);
      expect(atoms(original)[1].raw, moov);
    },
  );
  test(
    'repairs trailing initialization from 0.3.5 without changing fragments',
    () {
      final moof = fragment();
      final broken = Uint8List.fromList([
        ...ftyp,
        ...atom('free', []),
        ...sidx,
        ...moof,
        ...mdat,
        ...moov,
      ]);
      final output = DownloadTags.mp4(broken, {});
      final boxes = atoms(output);
      expect(boxes.map((b) => b.type), [
        'ftyp',
        'free',
        'moov',
        'sidx',
        'moof',
        'mdat',
      ]);
      expect(boxes.firstWhere((b) => b.type == 'moof').raw, moof);
      expect(boxes.firstWhere((b) => b.type == 'mdat').raw, mdat);
    },
  );
  test(
    'absolute fragment offsets are rejected rather than silently damaged',
    () {
      for (final flags in [0, 0x020001]) {
        final input = Uint8List.fromList([
          ...ftyp,
          ...moov,
          ...sidx,
          ...fragment(flags: flags),
          ...mdat,
        ]);
        expect(
          () => DownloadTags.mp4(input, {'title': 'Prueba'}),
          throwsFormatException,
        );
      }
    },
  );
  test('unsupported random access indexes are rejected', () {
    final input = Uint8List.fromList([
      ...ftyp,
      ...moov,
      ...sidx,
      ...fragment(),
      ...mdat,
      ...atom('mfra', []),
    ]);
    expect(() => DownloadTags.mp4(input, {}), throwsFormatException);
  });
}
