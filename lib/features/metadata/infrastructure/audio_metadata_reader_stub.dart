import 'dart:typed_data';
import 'package:rp_music/features/metadata/domain/metadata_reader.dart';

MetadataReader createMetadataReader() => const _StubMetadataReader();

class _StubMetadataReader implements MetadataReader {
  const _StubMetadataReader();

  @override
  Future<TrackMetadata> readMetadataFromFile(String path) async {
    return const TrackMetadata(title: 'Audio File');
  }

  @override
  Future<TrackMetadata> readMetadataFromBytes(Uint8List bytes, {String? fileName}) async {
    return TrackMetadata(title: fileName ?? 'Audio File');
  }
}
