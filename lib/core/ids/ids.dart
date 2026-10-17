import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String newId() => _uuid.v4();

extension type const TrackId(String value) {
  static TrackId generate() => TrackId(newId());
}

extension type const SourceId(String value) {
  static SourceId generate() => SourceId(newId());
}

extension type const EntryId(String value) {
  static EntryId generate() => EntryId(newId());
}

extension type const PlaylistId(String value) {
  static PlaylistId generate() => PlaylistId(newId());
}

extension type const AlbumId(String value) {
  static AlbumId generate() => AlbumId(newId());
}

extension type const ArtistId(String value) {
  static ArtistId generate() => ArtistId(newId());
}
