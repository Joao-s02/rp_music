import 'package:drift/drift.dart';
import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/library/domain/library_repository.dart';
import 'package:rp_music/features/library/domain/library_source.dart';
import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/library/domain/track_location.dart';
import 'package:rp_music/features/queue/domain/playback_queue.dart';
import 'package:rp_music/features/queue/domain/queue_entry.dart';
import 'package:rp_music/features/settings/domain/app_settings.dart';
import 'package:rp_music/infrastructure/database/app_database.dart';

class DriftLibraryRepository implements LibraryRepository {
  final AppDatabase _db;

  DriftLibraryRepository(this._db);

  @override
  Future<void> saveSource(LibrarySource source) async {
    await _db.into(_db.librarySourcesTable).insertOnConflictUpdate(
      LibrarySourcesTableCompanion(
        id: Value(source.id.value),
        kind: Value(source.kind.name),
        locator: Value(source.locator),
        status: Value(source.status.name),
        lastSuccessfulScan: Value(source.lastSuccessfulScan?.millisecondsSinceEpoch),
        scanGeneration: Value(source.scanGeneration),
      ),
    );
  }

  @override
  Future<List<LibrarySource>> getAllSources() async {
    final rows = await _db.select(_db.librarySourcesTable).get();
    return rows.map((r) => LibrarySource(
      id: SourceId(r.id),
      kind: SourceKind.values.byName(r.kind),
      locator: r.locator,
      status: SourceStatus.values.byName(r.status),
      lastSuccessfulScan: r.lastSuccessfulScan != null ? DateTime.fromMillisecondsSinceEpoch(r.lastSuccessfulScan!) : null,
      scanGeneration: r.scanGeneration,
    )).toList();
  }

  @override
  Future<LibrarySource?> getSource(SourceId id) async {
    final row = await (_db.select(_db.librarySourcesTable)..where((tbl) => tbl.id.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    return LibrarySource(
      id: SourceId(row.id),
      kind: SourceKind.values.byName(row.kind),
      locator: row.locator,
      status: SourceStatus.values.byName(row.status),
      lastSuccessfulScan: row.lastSuccessfulScan != null ? DateTime.fromMillisecondsSinceEpoch(row.lastSuccessfulScan!) : null,
      scanGeneration: row.scanGeneration,
    );
  }

  @override
  Future<void> deleteSource(SourceId id) async {
    await (_db.delete(_db.librarySourcesTable)..where((tbl) => tbl.id.equals(id.value))).go();
  }

  @override
  Future<void> upsertTrack(Track track, TrackLocation location) async {
    await _db.transaction(() async {
      final titleSort = track.title.toLowerCase().trim();

      await _db.into(_db.tracksTable).insertOnConflictUpdate(
        TracksTableCompanion(
          id: Value(track.id.value),
          title: Value(track.title),
          titleSort: Value(titleSort),
          artistName: Value(track.artistName),
          albumTitle: Value(track.albumTitle),
          albumId: Value(track.albumId?.value),
          durationMs: Value(track.duration?.inMilliseconds),
          trackNo: Value(track.trackNo),
          discNo: Value(track.discNo),
          year: Value(track.year),
          artworkId: Value(track.artworkId),
        ),
      );

      await _db.into(_db.trackLocationsTable).insertOnConflictUpdate(
        TrackLocationsTableCompanion(
          id: Value(location.id),
          trackId: Value(track.id.value),
          sourceId: Value(location.sourceId.value),
          locatorKey: Value(location.locatorKey),
          size: Value(location.size),
          modifiedAt: Value(location.modifiedAt?.millisecondsSinceEpoch),
          providerVersion: Value(location.providerVersion),
          fingerprint: Value(location.fingerprint),
          availability: Value(location.availability.name),
          lastSeenGeneration: Value(location.lastSeenGeneration),
        ),
      );
    });
  }

  @override
  Future<Track?> getTrack(TrackId id) async {
    final query = _db.select(_db.tracksTable).join([
      leftOuterJoin(_db.trackUserStateTable, _db.trackUserStateTable.trackId.equalsExp(_db.tracksTable.id)),
    ])..where(_db.tracksTable.id.equals(id.value));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapTrackWithUser(row);
  }

  @override
  Future<TrackLocation?> getLocationForTrack(TrackId id) async {
    final row = await (_db.select(_db.trackLocationsTable)..where((tbl) => tbl.trackId.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    return _mapLocation(row);
  }

  @override
  Future<TrackLocation?> getLocationByLocator(SourceId sourceId, String locatorKey) async {
    final row = await (_db.select(_db.trackLocationsTable)
      ..where((tbl) => tbl.sourceId.equals(sourceId.value) & tbl.locatorKey.equals(locatorKey))).getSingleOrNull();
    if (row == null) return null;
    return _mapLocation(row);
  }

  @override
  Future<List<Track>> getTracks({int limit = 100, int offset = 0, String? searchQuery}) async {
    final query = _db.select(_db.tracksTable).join([
      leftOuterJoin(_db.trackUserStateTable, _db.trackUserStateTable.trackId.equalsExp(_db.tracksTable.id)),
    ]);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where(_db.tracksTable.titleSort.like(term) | _db.tracksTable.artistName.lower().like(term));
    }

    query
      ..orderBy([OrderingTerm.asc(_db.tracksTable.titleSort), OrderingTerm.asc(_db.tracksTable.id)])
      ..limit(limit, offset: offset);

    final rows = await query.get();
    return rows.map(_mapTrackWithUser).toList();
  }

  @override
  Stream<List<Track>> watchTracks({String? searchQuery}) {
    final query = _db.select(_db.tracksTable).join([
      leftOuterJoin(_db.trackUserStateTable, _db.trackUserStateTable.trackId.equalsExp(_db.tracksTable.id)),
    ]);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where(_db.tracksTable.titleSort.like(term) | _db.tracksTable.artistName.lower().like(term));
    }

    query.orderBy([OrderingTerm.asc(_db.tracksTable.titleSort), OrderingTerm.asc(_db.tracksTable.id)]);

    return query.watch().map((rows) => rows.map(_mapTrackWithUser).toList());
  }

  @override
  Future<void> toggleFavorite(TrackId id) async {
    final userState = await (_db.select(_db.trackUserStateTable)..where((tbl) => tbl.trackId.equals(id.value))).getSingleOrNull();
    final currentFav = userState?.favorite ?? false;
    await _db.into(_db.trackUserStateTable).insertOnConflictUpdate(
      TrackUserStateTableCompanion(
        trackId: Value(id.value),
        favorite: Value(!currentFav),
        playCount: Value(userState?.playCount ?? 0),
        lastPlayedAt: Value(userState?.lastPlayedAt),
      ),
    );
  }

  @override
  Future<void> incrementPlayCount(TrackId id) async {
    final userState = await (_db.select(_db.trackUserStateTable)..where((tbl) => tbl.trackId.equals(id.value))).getSingleOrNull();
    final currentCount = userState?.playCount ?? 0;
    await _db.into(_db.trackUserStateTable).insertOnConflictUpdate(
      TrackUserStateTableCompanion(
        trackId: Value(id.value),
        favorite: Value(userState?.favorite ?? false),
        playCount: Value(currentCount + 1),
        lastPlayedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Future<void> updateLocationAvailability(String locationId, LocationAvailability availability) async {
    await (_db.update(_db.trackLocationsTable)..where((tbl) => tbl.id.equals(locationId))).write(
      TrackLocationsTableCompanion(
        availability: Value(availability.name),
      ),
    );
  }

  // Session & Queue Persistence
  @override
  Future<void> savePlaybackSession({
    required String sessionId,
    required int queueRevision,
    required EntryId? currentEntryId,
    required int positionMs,
    required RepeatMode repeatMode,
    required bool isShuffle,
    required int? shuffleSeed,
  }) async {
    await _db.into(_db.playbackSessionTable).insertOnConflictUpdate(
      PlaybackSessionTableCompanion(
        id: Value(sessionId),
        queueRevision: Value(queueRevision),
        currentEntryId: Value(currentEntryId?.value),
        positionMs: Value(positionMs),
        repeatMode: Value(repeatMode.name),
        isShuffle: Value(isShuffle),
        shuffleSeed: Value(shuffleSeed),
      ),
    );
  }

  @override
  Future<PlaybackSessionData?> loadPlaybackSession() async {
    final row = await (_db.select(_db.playbackSessionTable)..limit(1)).getSingleOrNull();
    if (row == null) return null;
    return PlaybackSessionData(
      id: row.id,
      queueRevision: row.queueRevision,
      currentEntryId: row.currentEntryId != null ? EntryId(row.currentEntryId!) : null,
      positionMs: row.positionMs,
      repeatMode: RepeatMode.values.where((e) => e.name == row.repeatMode).firstOrNull ?? RepeatMode.off,
      isShuffle: row.isShuffle,
      shuffleSeed: row.shuffleSeed,
    );
  }

  @override
  Future<void> saveQueue(PlaybackQueue queue) async {
    await _db.transaction(() async {
      await _db.delete(_db.queueEntriesTable).go();
      for (final entry in queue.entries) {
        await _db.into(_db.queueEntriesTable).insert(
          QueueEntriesTableCompanion(
            entryId: Value(entry.entryId.value),
            trackId: Value(entry.trackId.value),
            position: Value(entry.position),
            shufflePosition: Value(entry.shufflePosition),
          ),
        );
      }
    });
  }

  @override
  Future<PlaybackQueue> loadQueue() async {
    final rows = await (_db.select(_db.queueEntriesTable)..orderBy([(tbl) => OrderingTerm.asc(tbl.position)])).get();
    final entries = rows.map((r) => QueueEntry(
      entryId: EntryId(r.entryId),
      trackId: TrackId(r.trackId),
      position: r.position,
      shufflePosition: r.shufflePosition,
    )).toList();

    final session = await loadPlaybackSession();
    if (session == null) {
      return PlaybackQueue(entries: entries);
    }

    return PlaybackQueue(
      entries: entries,
      currentEntryId: session.currentEntryId ?? entries.firstOrNull?.entryId,
      isShuffle: session.isShuffle,
      shuffleSeed: session.shuffleSeed ?? 0,
      repeatMode: session.repeatMode,
      revision: session.queueRevision,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _db.into(_db.settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion(
        key: const Value('app_settings'),
        valueJson: Value(settings.toJson().toString()),
        schemaVersion: const Value(1),
      ),
    );
  }

  Track _mapTrackWithUser(TypedResult row) {
    final t = row.readTable(_db.tracksTable);
    final u = row.readTableOrNull(_db.trackUserStateTable);

    return Track(
      id: TrackId(t.id),
      title: t.title,
      artistName: t.artistName,
      albumTitle: t.albumTitle,
      albumId: t.albumId != null ? AlbumId(t.albumId!) : null,
      duration: t.durationMs != null ? Duration(milliseconds: t.durationMs!) : null,
      trackNo: t.trackNo,
      discNo: t.discNo,
      year: t.year,
      artworkId: t.artworkId,
      isFavorite: u?.favorite ?? false,
      playCount: u?.playCount ?? 0,
      lastPlayedAt: u?.lastPlayedAt != null ? DateTime.fromMillisecondsSinceEpoch(u!.lastPlayedAt!) : null,
    );
  }

  TrackLocation _mapLocation(TrackLocationsTableData r) {
    return TrackLocation(
      id: r.id,
      trackId: TrackId(r.trackId),
      sourceId: SourceId(r.sourceId),
      locatorKey: r.locatorKey,
      size: r.size,
      modifiedAt: r.modifiedAt != null ? DateTime.fromMillisecondsSinceEpoch(r.modifiedAt!) : null,
      providerVersion: r.providerVersion,
      fingerprint: r.fingerprint,
      availability: LocationAvailability.values.byName(r.availability),
      lastSeenGeneration: r.lastSeenGeneration,
    );
  }
}
