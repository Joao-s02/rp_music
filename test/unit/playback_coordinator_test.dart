import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/library/domain/library_repository.dart';
import 'package:rp_music/features/library/domain/source_resolver.dart';
import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/library/domain/track_location.dart';
import 'package:rp_music/features/playback/application/playback_coordinator.dart';
import 'package:rp_music/features/playback/domain/audio_engine.dart';
import 'package:rp_music/features/playback/domain/playable_source.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';
import 'package:rp_music/features/queue/domain/playback_queue.dart';

class FakeAudioEngine implements AudioEngine {
  final StreamController<PlaybackSnapshot> _controller = StreamController<PlaybackSnapshot>.broadcast();
  PlaybackSnapshot _snapshot = PlaybackSnapshot.initial();
  PlayableSource? loadedSource;
  int loadCalls = 0;
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  List<Duration> seekCalls = [];

  @override
  AudioCapabilities get capabilities => const AudioCapabilities();

  @override
  PlaybackSnapshot get currentSnapshot => _snapshot;

  @override
  Stream<PlaybackSnapshot> get snapshots => _controller.stream;

  @override
  Future<void> load(PlayableSource source, Duration position) async {
    loadCalls++;
    loadedSource = source;
    _snapshot = _snapshot.copyWith(processing: ProcessingState.ready, position: position);
    _controller.add(_snapshot);
  }

  @override
  Future<void> play() async {
    playCalls++;
    _snapshot = _snapshot.copyWith(playIntent: true);
    _controller.add(_snapshot);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    _snapshot = _snapshot.copyWith(playIntent: false);
    _controller.add(_snapshot);
  }

  @override
  Future<void> seek(Duration position) async {
    seekCalls.add(position);
    _snapshot = _snapshot.copyWith(position: position);
    _controller.add(_snapshot);
  }

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {
    stopCalls++;
    _snapshot = _snapshot.copyWith(playIntent: false, processing: ProcessingState.idle);
    _controller.add(_snapshot);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

class FakeLease implements SourceLease {
  @override
  final PlayableSource source;
  bool released = false;

  FakeLease(this.source);

  @override
  Future<void> release() async {
    released = true;
  }
}

class FakeSourceResolver implements SourceResolver {
  final Map<String, FakeLease> leases = {};

  @override
  Future<SourceLease> resolve(TrackLocation location) async {
    final lease = FakeLease(NativeFileSource(location.locatorKey));
    leases[location.id] = lease;
    return lease;
  }
}

class InMemoryLibraryRepo implements LibraryRepository {
  final Map<String, Track> tracks = {};
  final Map<String, TrackLocation> locations = {};
  PlaybackQueue storedQueue = PlaybackQueue.initial();

  @override
  Future<void> upsertTrack(Track track, TrackLocation location) async {
    tracks[track.id.value] = track;
    locations[track.id.value] = location;
  }

  @override
  Future<Track?> getTrack(TrackId id) async => tracks[id.value];

  @override
  Future<TrackLocation?> getLocationForTrack(TrackId id) async => locations[id.value];

  @override
  Future<void> saveQueue(PlaybackQueue queue) async {
    storedQueue = queue;
  }

  @override
  Future<PlaybackQueue> loadQueue() async => storedQueue;

  @override
  Future<void> savePlaybackSession({required String sessionId, required int queueRevision, required EntryId? currentEntryId, required int positionMs, required RepeatMode repeatMode, required bool isShuffle, required int? shuffleSeed}) async {}

  @override
  Future<PlaybackSessionData?> loadPlaybackSession() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAudioEngine engine;
  late FakeSourceResolver resolver;
  late InMemoryLibraryRepo repo;
  late PlaybackCoordinator coordinator;

  setUp(() {
    engine = FakeAudioEngine();
    resolver = FakeSourceResolver();
    repo = InMemoryLibraryRepo();
    coordinator = PlaybackCoordinator(
      engine: engine,
      sourceResolver: resolver,
      repository: repo,
    );
  });

  tearDown(() async {
    await coordinator.dispose();
  });

  group('PlaybackCoordinator Tests', () {
    test('Can load and play queue', () async {
      final t1 = TrackId('t1');
      final loc1 = TrackLocation(id: 'loc1', trackId: t1, sourceId: SourceId('src'), locatorKey: 'song1.mp3', size: 100, lastSeenGeneration: 1);
      await repo.upsertTrack(Track(id: t1, title: 'Track 1'), loc1);

      final queue = PlaybackQueue.initial().withTracks([t1]);
      await coordinator.playQueue(queue);

      expect(engine.loadCalls, 1);
      expect(engine.playCalls, 1);
      expect(engine.loadedSource, isA<NativeFileSource>());
      expect((engine.loadedSource as NativeFileSource).path, 'song1.mp3');
      expect(coordinator.currentSnapshot.trackId, t1);
    });

    test('Old lease is released when skipping to next track', () async {
      final t1 = TrackId('t1');
      final t2 = TrackId('t2');
      final loc1 = TrackLocation(id: 'loc1', trackId: t1, sourceId: SourceId('src'), locatorKey: 'song1.mp3', size: 100, lastSeenGeneration: 1);
      final loc2 = TrackLocation(id: 'loc2', trackId: t2, sourceId: SourceId('src'), locatorKey: 'song2.mp3', size: 100, lastSeenGeneration: 1);
      await repo.upsertTrack(Track(id: t1, title: 'Track 1'), loc1);
      await repo.upsertTrack(Track(id: t2, title: 'Track 2'), loc2);

      final queue = PlaybackQueue.initial().withTracks([t1, t2], initialTrackId: t1);
      await coordinator.playQueue(queue);

      final firstLease = resolver.leases['loc1'];
      expect(firstLease?.released, false);

      await coordinator.skipNext();

      expect(firstLease?.released, true, reason: 'Previous lease must be released on track change');
      expect(coordinator.currentSnapshot.trackId, t2);
    });

    test('Consecutive seeks are coalesced to the last requested position', () async {
      coordinator.seek(const Duration(seconds: 10));
      coordinator.seek(const Duration(seconds: 20));
      coordinator.seek(const Duration(seconds: 30));

      expect(engine.seekCalls.isEmpty, true, reason: 'Debounce is active');

      await Future.delayed(const Duration(milliseconds: 150));

      expect(engine.seekCalls.length, 1);
      expect(engine.seekCalls.first, const Duration(seconds: 30));
    });

    test('Restores session without autoplay', () async {
      final t1 = TrackId('t1');
      final loc1 = TrackLocation(id: 'loc1', trackId: t1, sourceId: SourceId('src'), locatorKey: 'song1.mp3', size: 100, lastSeenGeneration: 1);
      await repo.upsertTrack(Track(id: t1, title: 'Track 1'), loc1);

      repo.storedQueue = PlaybackQueue.initial().withTracks([t1], initialTrackId: t1);

      await coordinator.restoreSession();

      expect(coordinator.currentSnapshot.trackId, t1);
      expect(coordinator.currentSnapshot.playIntent, false, reason: 'Must NOT autoplay on session restore');
      expect(engine.playCalls, 0);
      expect(engine.loadCalls, 1);
    });
  });
}
