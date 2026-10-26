class Track {
  const Track({
    required this.id,
    required this.title,
    required this.folder,
    this.artist = 'Artista desconocido',
    this.album = 'Sin álbum',
    this.durationMs = 0,
    this.size = 0,
    this.modifiedMs = 0,
    this.metadataLoaded = false,
    this.sourceId,
    this.sourceName,
    this.artwork,
  });
  final String id;
  final String title;
  final String folder;
  final String artist;
  final String album;
  final int durationMs;
  final int size;
  final int modifiedMs;
  final bool metadataLoaded;
  final String? sourceId, sourceName, artwork;
  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: json['id'] as String,
    title: json['title'] as String,
    folder: json['folder'] as String,
    artist: json['artist'] as String? ?? 'Artista desconocido',
    album: json['album'] as String? ?? 'Sin álbum',
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
    size: (json['size'] as num?)?.toInt() ?? 0,
    modifiedMs: (json['modifiedMs'] as num?)?.toInt() ?? 0,
    metadataLoaded: json['metadataLoaded'] as bool? ?? false,
    sourceId: json['sourceId'] as String?,
    sourceName: json['sourceName'] as String?,
    artwork: json['artwork'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'folder': folder,
    'artist': artist,
    'album': album,
    'durationMs': durationMs,
    'size': size,
    'modifiedMs': modifiedMs,
    'metadataLoaded': metadataLoaded,
    if (sourceId != null) 'sourceId': sourceId,
    if (sourceName != null) 'sourceName': sourceName,
    if (artwork != null) 'artwork': artwork,
  };
}
