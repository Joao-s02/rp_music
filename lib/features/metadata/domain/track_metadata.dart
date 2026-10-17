import 'dart:typed_data';

class TrackMetadata {
  final String? title;
  final String? artist;
  final String? album;
  final Duration? duration;
  final int? trackNumber;
  final int? discNumber;
  final int? year;
  final Uint8List? artworkBytes;
  final String? mimeType;

  const TrackMetadata({
    this.title,
    this.artist,
    this.album,
    this.duration,
    this.trackNumber,
    this.discNumber,
    this.year,
    this.artworkBytes,
    this.mimeType,
  });
}
