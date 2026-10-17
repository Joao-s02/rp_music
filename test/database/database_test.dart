import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/library/domain/library_source.dart';
import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/library/domain/track_location.dart';
import 'package:rp_music/features/library/infrastructure/drift_library_repository.dart';
import 'package:rp_music/features/queue/domain/playback_queue.dart';
import 'package:rp_music/infrastructure/database/app_database.dart';

void main() {
  late AppDatabase db;
  late DriftLibraryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftLibraryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Database & Repository Tests', () {
    test('Can save and retrieve sources', () async {
      final source = LibrarySource(
        id: SourceId.generate(),
        kind: SourceKind.folder,
        locator: 'C:\\Music',
        status: SourceStatus.active,
        scanGeneration: 1,
      );

      await repo.saveSource(source);
      final sources = await repo.getAllSources();
      expect(sources.length, 1);
      expect(sources.first.locator, 'C:\\Music');
      expect(sources.first.id, source.id);
    });

    test('Can upsert track and retrieve it with normalized title search', () async {
      final source = LibrarySource(
        id: SourceId.generate(),
        kind: SourceKind.folder,
        locator: 'C:\\Music',
      );
      await repo.saveSource(source);

      final trackId = TrackId.generate();
      final track = Track(
        id: trackId,
        title: 'Bohemian Rhapsody',
        artistName: 'Queen',
        albumTitle: 'A Night at the Opera',
        duration: const Duration(minutes: 5, seconds: 55),
      );

      final location = TrackLocation(
        id: newId(),
        trackId: trackId,
        sourceId: source.id,
        locatorKey: 'C:\\Music\\queen.mp3',
        size: 8000000,
        lastSeenGeneration: 1,
      );

      await repo.upsertTrack(track, location);

      final fetched = await repo.getTrack(trackId);
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Bohemian Rhapsody');
      expect(fetched.artistName, 'Queen');
      expect(fetched.duration?.inSeconds, 355);

      // Search matching
      final searchResults = await repo.getTracks(searchQuery: 'bohem');
      expect(searchResults.length, 1);
      expect(searchResults.first.id, trackId);

      // Search non-matching
      final emptyResults = await repo.getTracks(searchQuery: 'metallica');
      expect(emptyResults.isEmpty, true);
    });

    test('Favorite and play count updates', () async {
      final source = LibrarySource(
        id: SourceId.generate(),
        kind: SourceKind.folder,
        locator: 'C:\\Music',
      );
      await repo.saveSource(source);

      final trackId = TrackId.generate();
      final track = Track(id: trackId, title: 'Track 1');
      final location = TrackLocation(
        id: newId(),
        trackId: trackId,
        sourceId: source.id,
        locatorKey: 'key1',
        size: 100,
        lastSeenGeneration: 1,
      );

      await repo.upsertTrack(track, location);

      var item = await repo.getTrack(trackId);
      expect(item!.isFavorite, false);
      expect(item.playCount, 0);

      await repo.toggleFavorite(trackId);
      item = await repo.getTrack(trackId);
      expect(item!.isFavorite, true);

      await repo.incrementPlayCount(trackId);
      item = await repo.getTrack(trackId);
      expect(item!.playCount, 1);
      expect(item.lastPlayedAt, isNotNull);
    });

    test('Queue persistence preserves order, shuffle seed and current entry', () async {
      final t1 = TrackId('track-1');
      final t2 = TrackId('track-2');

      // Add tracks to satisfy foreign keys
      final s = LibrarySource(id: SourceId('src'), kind: SourceKind.folder, locator: 'loc');
      await repo.saveSource(s);
      await repo.upsertTrack(Track(id: t1, title: 'T1'), TrackLocation(id: '1', trackId: t1, sourceId: s.id, locatorKey: 'k1', size: 1, lastSeenGeneration: 1));
      await repo.upsertTrack(Track(id: t2, title: 'T2'), TrackLocation(id: '2', trackId: t2, sourceId: s.id, locatorKey: 'k2', size: 1, lastSeenGeneration: 1));

      final queue = PlaybackQueue.initial().withTracks([t1, t2, t1], initialTrackId: t2);
      await repo.saveQueue(queue);

      await repo.savePlaybackSession(
        sessionId: 'session-123',
        queueRevision: queue.revision,
        currentEntryId: queue.currentEntryId,
        positionMs: 45000,
        repeatMode: queue.repeatMode,
        isShuffle: queue.isShuffle,
        shuffleSeed: queue.shuffleSeed,
      );

      final restoredQueue = await repo.loadQueue();
      expect(restoredQueue.entries.length, 3);
      expect(restoredQueue.entries[0].trackId, t1);
      expect(restoredQueue.entries[1].trackId, t2);
      expect(restoredQueue.entries[2].trackId, t1);
      expect(restoredQueue.currentEntryId, queue.currentEntryId);

      final session = await repo.loadPlaybackSession();
      expect(session?.positionMs, 45000);
      expect(session?.id, 'session-123');
    });
  });
}
