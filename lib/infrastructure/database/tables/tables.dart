import 'package:drift/drift.dart';

class LibrarySourcesTable extends Table {
  @override
  String get tableName => 'library_sources';

  TextColumn get id => text()();
  TextColumn get kind => text()(); // folder, mediaStore, filePicker, opfs
  TextColumn get locator => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get lastSuccessfulScan => integer().nullable()();
  IntColumn get scanGeneration => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class TracksTable extends Table {
  @override
  String get tableName => 'tracks';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get titleSort => text()();
  TextColumn get artistName => text().nullable()();
  TextColumn get albumTitle => text().nullable()();
  TextColumn get albumId => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get trackNo => integer().nullable()();
  IntColumn get discNo => integer().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get artworkId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ArtistsTable extends Table {
  @override
  String get tableName => 'artists';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sortName => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class TrackArtistsTable extends Table {
  @override
  String get tableName => 'track_artists';

  TextColumn get trackId => text().references(TracksTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get artistId => text().references(ArtistsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text().withDefault(const Constant('primary'))();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {trackId, artistId};
}

class AlbumsTable extends Table {
  @override
  String get tableName => 'albums';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get albumArtist => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get groupingKey => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class TrackLocationsTable extends Table {
  @override
  String get tableName => 'track_locations';

  TextColumn get id => text()();
  TextColumn get trackId => text().references(TracksTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get sourceId => text().references(LibrarySourcesTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get locatorKey => text()();
  IntColumn get size => integer()();
  IntColumn get modifiedAt => integer().nullable()();
  TextColumn get providerVersion => text().nullable()();
  TextColumn get fingerprint => text().nullable()();
  TextColumn get availability => text().withDefault(const Constant('available'))();
  IntColumn get lastSeenGeneration => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {sourceId, locatorKey},
  ];
}

class PlaylistsTable extends Table {
  @override
  String get tableName => 'playlists';

  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaylistEntriesTable extends Table {
  @override
  String get tableName => 'playlist_entries';

  TextColumn get id => text()();
  TextColumn get playlistId => text().references(PlaylistsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get trackId => text().references(TracksTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class TrackUserStateTable extends Table {
  @override
  String get tableName => 'track_user_state';

  TextColumn get trackId => text().references(TracksTable, #id, onDelete: KeyAction.cascade)();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  IntColumn get lastPlayedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {trackId};
}

class QueueEntriesTable extends Table {
  @override
  String get tableName => 'queue_entries';

  TextColumn get entryId => text()();
  TextColumn get trackId => text().references(TracksTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get shufflePosition => integer()();

  @override
  Set<Column> get primaryKey => {entryId};
}

class PlaybackSessionTable extends Table {
  @override
  String get tableName => 'playback_session';

  TextColumn get id => text()();
  IntColumn get queueRevision => integer().withDefault(const Constant(0))();
  TextColumn get currentEntryId => text().nullable()();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();
  IntColumn get shuffleSeed => integer().nullable()();
  BoolColumn get isShuffle => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ArtworksTable extends Table {
  @override
  String get tableName => 'artworks';

  TextColumn get id => text()();
  TextColumn get contentHash => text()();
  TextColumn get cacheKey => text()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get byteSize => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {key};
}

class ScanRunsTable extends Table {
  @override
  String get tableName => 'scan_runs';

  TextColumn get id => text()();
  TextColumn get sourceId => text().references(LibrarySourcesTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get generation => integer()();
  TextColumn get status => text()();
  TextColumn get cursor => text().nullable()();
  TextColumn get countersJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
