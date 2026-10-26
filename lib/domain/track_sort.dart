import 'track.dart';

enum TrackSort {
  title('Título'),
  artist('Artista'),
  album('Álbum'),
  duration('Duración'),
  modified('Fecha de modificación'),
  size('Tamaño'),
  filename('Nombre del archivo');

  const TrackSort(this.label);
  final String label;
}

String _key(String text) {
  var result = text.toLowerCase();
  const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};
  accents.forEach((from, to) => result = result.replaceAll(from, to));
  return result;
}

String _filename(Track track) {
  String path;
  try {
    path = Uri.decodeFull(track.id);
  } on FormatException {
    path = track.id;
  }
  return _key(path.split('/').last.split('\\').last);
}

List<Track> sortTracks(Iterable<Track> tracks, TrackSort sort, bool ascending) {
  final result = tracks.toList();
  int compare(Track a, Track b) => switch (sort) {
    TrackSort.title => _key(a.title).compareTo(_key(b.title)),
    TrackSort.artist => _key(a.artist).compareTo(_key(b.artist)),
    TrackSort.album => _key(a.album).compareTo(_key(b.album)),
    TrackSort.duration => a.durationMs.compareTo(b.durationMs),
    TrackSort.modified => a.modifiedMs.compareTo(b.modifiedMs),
    TrackSort.size => a.size.compareTo(b.size),
    TrackSort.filename => _filename(a).compareTo(_filename(b)),
  };
  result.sort((a, b) {
    var order = compare(a, b);
    if (order == 0) order = _key(a.title).compareTo(_key(b.title));
    if (order == 0) order = a.id.compareTo(b.id);
    return ascending ? order : -order;
  });
  return result;
}
