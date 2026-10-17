import 'dart:typed_data';
import 'package:rp_music/features/metadata/domain/metadata_reader.dart';

MetadataReader createMetadataReader() => const AudioMetadataReaderWeb();

class AudioMetadataReaderWeb implements MetadataReader {
  const AudioMetadataReaderWeb();

  @override
  Future<TrackMetadata> readMetadataFromFile(String path) async {
    return TrackMetadata(title: path);
  }

  @override
  Future<TrackMetadata> readMetadataFromBytes(Uint8List bytes, {String? fileName}) async {
    var title = 'Web Track';
    if (fileName != null) {
      final dotIdx = fileName.lastIndexOf('.');
      title = dotIdx > 0 ? fileName.substring(0, dotIdx) : fileName;
    }
    return TrackMetadata(title: title);
  }
}
