import 'dart:typed_data';
import 'package:rp_music/features/metadata/domain/track_metadata.dart';
export 'package:rp_music/features/metadata/domain/track_metadata.dart';

abstract interface class MetadataReader {
  Future<TrackMetadata> readMetadataFromFile(String path);
  Future<TrackMetadata> readMetadataFromBytes(Uint8List bytes, {String? fileName});
}
