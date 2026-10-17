import 'package:rp_music/core/ids/ids.dart';

class Track {
  final TrackId id;
  final String title;
  final String? artistName;
  final String? albumTitle;
  final AlbumId? albumId;
  final Duration? duration;
  final int? trackNo;
  final int? discNo;
  final int? year;
  final String? artworkId;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayedAt;

  const Track({
    required this.id,
    required this.title,
    this.artistName,
    this.albumTitle,
    this.albumId,
    this.duration,
    this.trackNo,
    this.discNo,
    this.year,
    this.artworkId,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayedAt,
  });

  Track copyWith({
    TrackId? id,
    String? title,
    String? artistName,
    String? albumTitle,
    AlbumId? albumId,
    Duration? duration,
    int? trackNo,
    int? discNo,
    int? year,
    String? artworkId,
    bool? isFavorite,
    int? playCount,
    DateTime? lastPlayedAt,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      albumTitle: albumTitle ?? this.albumTitle,
      albumId: albumId ?? this.albumId,
      duration: duration ?? this.duration,
      trackNo: trackNo ?? this.trackNo,
      discNo: discNo ?? this.discNo,
      year: year ?? this.year,
      artworkId: artworkId ?? this.artworkId,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}
