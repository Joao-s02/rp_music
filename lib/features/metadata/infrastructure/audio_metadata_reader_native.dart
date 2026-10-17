import 'dart:io';
import 'dart:typed_data';
import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;
import 'package:path/path.dart' as p;
import 'package:rp_music/features/metadata/domain/metadata_reader.dart';

MetadataReader createMetadataReader() => const AudioMetadataReaderNative();

class AudioMetadataReaderNative implements MetadataReader {
  const AudioMetadataReaderNative();

  @override
  Future<TrackMetadata> readMetadataFromFile(String path) async {
    final file = File(path);
    final fallbackTitle = p.basenameWithoutExtension(path);

    if (!await file.exists()) {
      return TrackMetadata(title: fallbackTitle);
    }

    try {
      final metadata = amr.readMetadata(file, getImage: true);
      return TrackMetadata(
        title: metadata.title?.isNotEmpty == true ? metadata.title : fallbackTitle,
        artist: metadata.artist?.isNotEmpty == true ? metadata.artist : null,
        album: metadata.album?.isNotEmpty == true ? metadata.album : null,
        duration: metadata.duration,
        trackNumber: metadata.trackNumber,
        discNumber: metadata.discNumber,
        year: metadata.year?.year,
        artworkBytes: metadata.pictures.isNotEmpty ? metadata.pictures.first.bytes : null,
        mimeType: 'image/jpeg',
      );
    } catch (_) {
      return TrackMetadata(title: fallbackTitle);
    }
  }

  @override
  Future<TrackMetadata> readMetadataFromBytes(Uint8List bytes, {String? fileName}) async {
    final fallbackTitle = fileName != null ? p.basenameWithoutExtension(fileName) : 'Audio Track';
    return TrackMetadata(title: fallbackTitle);
  }
}
