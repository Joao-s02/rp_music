import 'dart:async';
import 'package:rp_music/core/diagnostics/diagnostics_service.dart';
import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/library/domain/library_repository.dart';
import 'package:rp_music/features/library/domain/source_resolver.dart';
import 'package:rp_music/features/playback/domain/audio_engine.dart';
import 'package:rp_music/features/playback/domain/playback_failure.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';
import 'package:rp_music/features/queue/domain/playback_queue.dart';

class PlaybackCoordinator {
  final AudioEngine _engine;
  final SourceResolver _sourceResolver;
  final LibraryRepository _repository;
  final DiagnosticsService _diagnostics = DiagnosticsService();

  final StreamController<PlaybackSnapshot> _snapshotController = StreamController<PlaybackSnapshot>.broadcast();
  final StreamController<PlaybackQueue> _queueController = StreamController<PlaybackQueue>.broadcast();

  PlaybackSnapshot _currentSnapshot = PlaybackSnapshot.initial();
  PlaybackQueue _queue = PlaybackQueue.initial();
  SourceLease? _currentLease;

  int _generation = 0;
  int _consecutiveFailures = 0;
  Timer? _seekDebounceTimer;
  Duration? _pendingSeekPosition;
  Timer? _sessionPersistDebounceTimer;
  StreamSubscription? _engineSnapshotSub;

  PlaybackCoordinator({
    required this._engine,
    required this._sourceResolver,
    required this._repository,
  }) {
    _init();
  }

  PlaybackSnapshot get currentSnapshot => _currentSnapshot;
  PlaybackQueue get currentQueue => _queue;
  Stream<PlaybackSnapshot> get snapshotStream => _snapshotController.stream;
  Stream<PlaybackQueue> get queueStream => _queueController.stream;

  void _init() {
    _engineSnapshotSub = _engine.snapshots.listen((engineSnap) {
      if (engineSnap.sourceGeneration != _generation && engineSnap.sourceGeneration != 0) {
        // Discard stale generation events
        return;
      }

      // Check for completion to trigger auto-advance
      if (_currentSnapshot.processing != ProcessingState.completed &&
          engineSnap.processing == ProcessingState.completed) {
        _handleTrackCompletion();
      }

      _currentSnapshot = engineSnap.copyWith(
        sourceGeneration: _generation,
        trackId: () => _queue.currentEntry?.trackId,
      );
      _snapshotController.add(_currentSnapshot);

      _scheduleSessionPersistence();
    });
  }

  /// Restores queue and last position from database without autoplaying
  Future<void> restoreSession() async {
    try {
      final restoredQueue = await _repository.loadQueue();
      if (restoredQueue.isNotEmpty) {
        _queue = restoredQueue;
        _queueController.add(_queue);

        final session = await _repository.loadPlaybackSession();
        final startPos = session != null ? Duration(milliseconds: session.positionMs) : Duration.zero;

        final currentTrackId = _queue.currentEntry?.trackId;
        if (currentTrackId != null) {
          _diagnostics.info('PlaybackCoordinator', 'Restoring session for track: ${currentTrackId.value} at pos: $startPos');
          await _prepareTrack(currentTrackId, startPosition: startPos, autoPlay: false);
        }
      }
    } catch (e, stack) {
      _diagnostics.error('PlaybackCoordinator', 'Failed to restore playback session: $e', {'stack': stack.toString()});
    }
  }

  /// Sets active queue and plays the target track (or first)
  Future<void> playQueue(PlaybackQueue newQueue, {TrackId? initialTrackId}) async {
    _queue = newQueue;
    if (initialTrackId != null) {
      final entry = _queue.entries.where((e) => e.trackId == initialTrackId).firstOrNull;
      if (entry != null) {
        _queue = _queue.copyWith(currentEntryId: () => entry.entryId);
      }
    }
    _queueController.add(_queue);
    await _repository.saveQueue(_queue);

    final trackId = _queue.currentEntry?.trackId;
    if (trackId != null) {
      await _prepareTrack(trackId, startPosition: Duration.zero, autoPlay: true);
    }
  }

  /// Play command
  Future<void> play() async {
    _consecutiveFailures = 0;
    if (_currentSnapshot.processing == ProcessingState.idle && _queue.currentEntry != null) {
      await _prepareTrack(_queue.currentEntry!.trackId, startPosition: _currentSnapshot.position, autoPlay: true);
    } else {
      await _engine.play();
    }
  }

  /// Pause command
  Future<void> pause() async {
    await _engine.pause();
    await _persistSessionImmediately();
  }

  /// Toggle play / pause
  Future<void> togglePlayPause() async {
    if (_currentSnapshot.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Seek command coalescing consecutive seeks and preserving the last
  void seek(Duration position) {
    _pendingSeekPosition = position;
    _currentSnapshot = _currentSnapshot.copyWith(position: position);
    _snapshotController.add(_currentSnapshot);

    _seekDebounceTimer?.cancel();
    _seekDebounceTimer = Timer(const Duration(milliseconds: 100), () async {
      final target = _pendingSeekPosition;
      if (target != null) {
        _pendingSeekPosition = null;
        await _engine.seek(target);
      }
    });
  }

  /// Skip to next track in queue
  Future<void> skipNext() async {
    final next = _queue.nextEntry;
    if (next != null) {
      _queue = _queue.copyWith(currentEntryId: () => next.entryId);
      _queueController.add(_queue);
      await _repository.saveQueue(_queue);
      await _prepareTrack(next.trackId, startPosition: Duration.zero, autoPlay: true);
    } else {
      await _engine.stop();
    }
  }

  /// Skip to previous track in queue
  Future<void> skipPrevious() async {
    // If current position is greater than 3 seconds, seek to start of track first
    if (_currentSnapshot.position.inSeconds > 3) {
      seek(Duration.zero);
      return;
    }

    final prev = _queue.previousEntry;
    if (prev != null) {
      _queue = _queue.copyWith(currentEntryId: () => prev.entryId);
      _queueController.add(_queue);
      await _repository.saveQueue(_queue);
      await _prepareTrack(prev.trackId, startPosition: Duration.zero, autoPlay: true);
    } else {
      seek(Duration.zero);
    }
  }

  /// Toggle shuffle
  Future<void> toggleShuffle() async {
    _queue = _queue.toggleShuffle();
    _queueController.add(_queue);
    await _repository.saveQueue(_queue);
    await _persistSessionImmediately();
  }

  /// Cycle repeat mode
  Future<void> cycleRepeatMode() async {
    _queue = _queue.cycleRepeatMode();
    _queueController.add(_queue);
    await _repository.saveQueue(_queue);
    await _persistSessionImmediately();
  }

  void _handleTrackCompletion() {
    unawaited(_repository.incrementPlayCount(_queue.currentEntry!.trackId));
    if (_queue.repeatMode == RepeatMode.one) {
      seek(Duration.zero);
      play();
    } else {
      skipNext();
    }
  }

  /// Prepares and loads track using generation invalidation, lease release and error limits
  Future<void> _prepareTrack(TrackId trackId, {required Duration startPosition, required bool autoPlay}) async {
    final currentGen = ++_generation;

    // Release previous source lease if exists
    final oldLease = _currentLease;
    _currentLease = null;
    if (oldLease != null) {
      unawaited(oldLease.release());
    }

    _currentSnapshot = _currentSnapshot.copyWith(
      sourceGeneration: currentGen,
      trackId: () => trackId,
      processing: ProcessingState.loading,
      playIntent: autoPlay,
      position: startPosition,
      failure: () => null,
    );
    _snapshotController.add(_currentSnapshot);

    try {
      final location = await _repository.getLocationForTrack(trackId);
      if (location == null) {
        throw PlaybackFailure(
          reason: PlaybackFailureReason.sourceMissing,
          message: 'Location for track ${trackId.value} not found in database',
        );
      }

      // Check generation before resolving
      if (_generation != currentGen) return;

      final lease = await _sourceResolver.resolve(location);
      if (_generation != currentGen) {
        await lease.release();
        return;
      }

      _currentLease = lease;

      await _engine.load(lease.source, startPosition);
      if (_generation != currentGen) return;

      _consecutiveFailures = 0; // Reset error counter on successful load

      if (autoPlay) {
        await _engine.play();
      }

      await _persistSessionImmediately();
    } on PlaybackFailure catch (failure) {
      _handlePlaybackFailure(failure, currentGen);
    } catch (e, stack) {
      final failure = PlaybackFailure(
        reason: PlaybackFailureReason.backendFailure,
        message: e.toString(),
        cause: e,
        stackTrace: stack,
      );
      _handlePlaybackFailure(failure, currentGen);
    }
  }

  void _handlePlaybackFailure(PlaybackFailure failure, int failedGeneration) {
    if (_generation != failedGeneration) return;

    _consecutiveFailures++;
    _diagnostics.error('PlaybackCoordinator', 'Playback error (attempt $_consecutiveFailures/3): ${failure.message}');

    _currentSnapshot = _currentSnapshot.copyWith(
      processing: ProcessingState.failed,
      playIntent: false,
      failure: () => failure,
    );
    _snapshotController.add(_currentSnapshot);

    // Stop skipping if 3 consecutive failures occur
    if (_consecutiveFailures >= 3) {
      _diagnostics.warning('PlaybackCoordinator', 'Stopping playback after 3 consecutive failures to prevent infinite loop.');
      _engine.stop();
    } else {
      // Try next track
      Timer(const Duration(milliseconds: 500), () {
        if (_generation == failedGeneration) {
          skipNext();
        }
      });
    }
  }

  void _scheduleSessionPersistence() {
    if (_sessionPersistDebounceTimer?.isActive == true) return;
    _sessionPersistDebounceTimer = Timer(const Duration(seconds: 10), () {
      _persistSessionImmediately();
    });
  }

  Future<void> _persistSessionImmediately() async {
    _sessionPersistDebounceTimer?.cancel();
    try {
      await _repository.savePlaybackSession(
        sessionId: _currentSnapshot.sessionId,
        queueRevision: _queue.revision,
        currentEntryId: _queue.currentEntryId,
        positionMs: _currentSnapshot.position.inMilliseconds,
        repeatMode: _queue.repeatMode,
        isShuffle: _queue.isShuffle,
        shuffleSeed: _queue.shuffleSeed,
      );
    } catch (_) {}
  }

  Future<void> dispose() async {
    _seekDebounceTimer?.cancel();
    _sessionPersistDebounceTimer?.cancel();
    await _engineSnapshotSub?.cancel();
    await _currentLease?.release();
    await _snapshotController.close();
    await _queueController.close();
    await _engine.dispose();
  }
}
