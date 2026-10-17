import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/library/domain/library_source.dart';
import 'package:rp_music/features/library/domain/track.dart';
import 'package:rp_music/features/library/domain/track_location.dart';
import 'package:rp_music/features/queue/domain/playback_queue.dart';

class PlaybackSessionData {
  final String id;
  final int queueRevision;
  final EntryId? currentEntryId;
  final int positionMs;
  final RepeatMode repeatMode;
  final bool isShuffle;
  final int? shuffleSeed;

  const PlaybackSessionData({
    required this.id,
    required this.queueRevision,
    this.currentEntryId,
    required this.positionMs,
    required this.repeatMode,
    required this.isShuffle,
    this.shuffleSeed,
  });
}

abstract interface class LibraryRepository {
  Future<void> saveSource(LibrarySource source);
  Future<List<LibrarySource>> getAllSources();
  Future<LibrarySource?> getSource(SourceId id);
  Future<void> deleteSource(SourceId id);

  Future<void> upsertTrack(Track track, TrackLocation location);
  Future<Track?> getTrack(TrackId id);
  Future<TrackLocation?> getLocationForTrack(TrackId id);
  Future<TrackLocation?> getLocationByLocator(SourceId sourceId, String locatorKey);
  Future<List<Track>> getTracks({int limit = 100, int offset = 0, String? searchQuery});
  Stream<List<Track>> watchTracks({String? searchQuery});
  Future<void> toggleFavorite(TrackId id);
  Future<void> incrementPlayCount(TrackId id);
  Future<void> updateLocationAvailability(String locationId, LocationAvailability availability);

  // Queue & Session persistence
  Future<void> saveQueue(PlaybackQueue queue);
  Future<PlaybackQueue> loadQueue();
  Future<void> savePlaybackSession({
    required String sessionId,
    required int queueRevision,
    required EntryId? currentEntryId,
    required int positionMs,
    required RepeatMode repeatMode,
    required bool isShuffle,
    required int? shuffleSeed,
  });
  Future<PlaybackSessionData?> loadPlaybackSession();
}
