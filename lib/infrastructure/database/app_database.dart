import 'package:drift/drift.dart';
import 'package:rp_music/infrastructure/database/connection/connection.dart' as impl;
import 'package:rp_music/infrastructure/database/tables/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LibrarySourcesTable,
    TracksTable,
    ArtistsTable,
    TrackArtistsTable,
    AlbumsTable,
    TrackLocationsTable,
    PlaylistsTable,
    PlaylistEntriesTable,
    TrackUserStateTable,
    QueueEntriesTable,
    PlaybackSessionTable,
    ArtworksTable,
    SettingsTable,
    ScanRunsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? impl.connectDatabase(name: 'rp_music'));

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_tracks_title_sort ON tracks (title_sort, id);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_locations_source_gen ON track_locations (source_id, last_seen_generation);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_playlist_entries_pos ON playlist_entries (playlist_id, position);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_queue_entries_pos ON queue_entries (position);');
      },
      onCreate: (m) async {
        await m.createAll();
      },
    );
  }
}
