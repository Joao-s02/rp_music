import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/playback/domain/playback_failure.dart';

enum ProcessingState {
  idle,
  loading,
  ready,
  buffering,
  completed,
  failed,
}

class PlaybackSnapshot {
  final String sessionId;
  final int sourceGeneration;
  final TrackId? trackId;
  final ProcessingState processing;
  final bool playIntent;
  final Duration position;
  final Duration? duration;
  final double volume;
  final PlaybackFailure? failure;

  const PlaybackSnapshot({
    required this.sessionId,
    required this.sourceGeneration,
    this.trackId,
    required this.processing,
    required this.playIntent,
    required this.position,
    this.duration,
    required this.volume,
    this.failure,
  });

  factory PlaybackSnapshot.initial() {
    return PlaybackSnapshot(
      sessionId: newId(),
      sourceGeneration: 0,
      trackId: null,
      processing: ProcessingState.idle,
      playIntent: false,
      position: Duration.zero,
      duration: null,
      volume: 1.0,
      failure: null,
    );
  }

  bool get isPlaying => playIntent && (processing == ProcessingState.ready || processing == ProcessingState.buffering);

  PlaybackSnapshot copyWith({
    String? sessionId,
    int? sourceGeneration,
    TrackId? Function()? trackId,
    ProcessingState? processing,
    bool? playIntent,
    Duration? position,
    Duration? Function()? duration,
    double? volume,
    PlaybackFailure? Function()? failure,
  }) {
    return PlaybackSnapshot(
      sessionId: sessionId ?? this.sessionId,
      sourceGeneration: sourceGeneration ?? this.sourceGeneration,
      trackId: trackId != null ? trackId() : this.trackId,
      processing: processing ?? this.processing,
      playIntent: playIntent ?? this.playIntent,
      position: position ?? this.position,
      duration: duration != null ? duration() : this.duration,
      volume: volume ?? this.volume,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  String toString() {
    return 'PlaybackSnapshot(gen: $sourceGeneration, track: ${trackId?.value}, proc: ${processing.name}, intent: $playIntent, pos: $position, dur: $duration)';
  }
}
