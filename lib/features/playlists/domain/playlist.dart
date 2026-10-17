import 'package:rp_music/core/ids/ids.dart';

class Playlist {
  final PlaylistId id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int trackCount;

  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.trackCount = 0,
  });

  Playlist copyWith({
    PlaylistId? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? trackCount,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackCount: trackCount ?? this.trackCount,
    );
  }
}

class PlaylistEntry {
  final String id;
  final PlaylistId playlistId;
  final TrackId trackId;
  final int position;

  const PlaylistEntry({
    required this.id,
    required this.playlistId,
    required this.trackId,
    required this.position,
  });
}
