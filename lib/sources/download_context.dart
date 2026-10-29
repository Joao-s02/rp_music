import '../domain/track.dart';

/// One immutable album identity shared by every file in a batch.
class DownloadContext {
  const DownloadContext({
    required this.album,
    required this.albumArtist,
    this.artwork,
    this.trackNumber,
    this.trackTotal,
    this.discNumber,
  });
  final String album, albumArtist;
  final String? artwork;
  final int? trackNumber, trackTotal, discNumber;
  Map<String, dynamic> get tags => {
    'album': album,
    'albumArtist': albumArtist,
    if (trackNumber != null) 'trackNumber': trackNumber,
    if (trackTotal != null) 'trackTotal': trackTotal,
    if (discNumber != null) 'discNumber': discNumber,
  };
  DownloadContext at(int number, int total) => DownloadContext(
    album: album,
    albumArtist: albumArtist,
    artwork: artwork,
    trackNumber: number,
    trackTotal: total,
    discNumber: discNumber,
  );

  /// Known source album wins over a lyrics/recording search result.
  static Map<String, dynamic> merge(
    Track track,
    Map<String, dynamic> remote,
    DownloadContext? context,
  ) {
    final known =
        track.album.trim().isNotEmpty &&
        ![
          'sin álbum',
          'sin album',
          'unknown album',
          'álbum desconocido',
          'album desconocido',
        ].contains(normalize(track.album));
    final tags = <String, dynamic>{
      'title': track.title,
      'artist': track.artist,
    };
    final sameAlbum =
        known &&
        normalize(track.album) == normalize('${remote['album'] ?? ''}');
    if (sameAlbum || (!known && remote['albumVerified'] == true)) {
      for (final key in [
        'album',
        'albumArtist',
        'date',
        'genre',
        'trackNumber',
        'trackTotal',
        'discNumber',
        'discTotal',
      ]) {
        if (remote[key] != null) tags[key] = remote[key];
      }
    }
    if (known) tags['album'] = track.album;
    if (track.albumArtist.isNotEmpty) tags['albumArtist'] = track.albumArtist;
    if (context != null) {
      // Never retain numbering/date from a different edition.
      for (final key in [
        'date',
        'genre',
        'trackNumber',
        'trackTotal',
        'discNumber',
        'discTotal',
      ]) {
        tags.remove(key);
      }
      tags.addAll(context.tags);
    }
    return tags;
  }

  static String normalize(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}
