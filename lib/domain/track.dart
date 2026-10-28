class Track {
  const Track({
    required this.id,
    required this.title,
    required this.folder,
    this.artist = 'Artista desconocido',
    this.album = 'Sin álbum',
    this.albumArtist = '',
    this.trackNumber = 0,
    this.discNumber = 0,
    this.durationMs = 0,
    this.size = 0,
    this.modifiedMs = 0,
    this.metadataLoaded = false,
    this.metadataVersion = 0,
    this.sourceId,
    this.sourceName,
    this.artwork,
  });
  final String id;
  final String title;
  final String folder;
  final String artist;
  final String album, albumArtist;
  final int trackNumber, discNumber;
  String get albumKey =>
      '$album\n${albumArtist.isEmpty ? artist : albumArtist}';
  final int durationMs;
  final int size;
  final int modifiedMs;
  final bool metadataLoaded;
  final int metadataVersion;
  final String? sourceId, sourceName, artwork;
  List<String> get artists {
    final seen = <String>{};
    final names = artist
        .split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty && seen.add(name.toLowerCase()))
        .toList();
    return names.isEmpty ? ['Artista desconocido'] : names;
  }

  String get format {
    if (sourceId != null) return 'En línea';
    String path = id;
    try {
      path = Uri.decodeComponent(id);
    } catch (_) {}
    final extension = path.split('.').last.toUpperCase();
    return [
          'FLAC',
          'MP3',
          'M4A',
          'MP4',
          'WAV',
          'OPUS',
          'OGG',
          'AAC',
        ].contains(extension)
        ? extension
        : 'Audio';
  }

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: json['id'] as String,
    title: json['title'] as String,
    folder: json['folder'] as String,
    artist: json['artist'] as String? ?? 'Artista desconocido',
    album: json['album'] as String? ?? 'Sin álbum',
    albumArtist: json['albumArtist'] as String? ?? '',
    trackNumber: (json['trackNumber'] as num?)?.toInt() ?? 0,
    discNumber: (json['discNumber'] as num?)?.toInt() ?? 0,
    durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
    size: (json['size'] as num?)?.toInt() ?? 0,
    modifiedMs: (json['modifiedMs'] as num?)?.toInt() ?? 0,
    metadataLoaded: json['metadataLoaded'] as bool? ?? false,
    metadataVersion: (json['metadataVersion'] as num?)?.toInt() ?? 0,
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
    if (albumArtist.isNotEmpty) 'albumArtist': albumArtist,
    if (trackNumber > 0) 'trackNumber': trackNumber,
    if (discNumber > 0) 'discNumber': discNumber,
    'durationMs': durationMs,
    'size': size,
    'modifiedMs': modifiedMs,
    'metadataLoaded': metadataLoaded,
    if (metadataVersion > 0) 'metadataVersion': metadataVersion,
    if (sourceId != null) 'sourceId': sourceId,
    if (sourceName != null) 'sourceName': sourceName,
    if (artwork != null) 'artwork': artwork,
  };
}
