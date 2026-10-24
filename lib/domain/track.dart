class Track {
  const Track({
    required this.id,
    required this.title,
    required this.folder,
    this.artist = 'Artista desconocido',
    this.album = 'Sin álbum',
    this.durationMs = 0,
  });
  final String id;
  final String title;
  final String folder;
  final String artist;
  final String album;
  final int durationMs;
  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: json['id'] as String,
    title: json['title'] as String,
    folder: json['folder'] as String,
    artist: json['artist'] as String? ?? 'Artista desconocido',
    album: json['album'] as String? ?? 'Sin álbum',
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'folder': folder,
    'artist': artist,
    'album': album,
    'durationMs': durationMs,
  };
}
