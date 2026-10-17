import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';

void main() {
  group('PlaybackSnapshot Tests', () {
    test('Initial snapshot is idle with no play intent', () {
      final snap = PlaybackSnapshot.initial();
      expect(snap.processing, ProcessingState.idle);
      expect(snap.playIntent, false);
      expect(snap.isPlaying, false);
      expect(snap.position, Duration.zero);
      expect(snap.duration, isNull);
    });

    test('PlayIntent without ready/buffering is not playing (e.g. while loading)', () {
      final snap = PlaybackSnapshot.initial().copyWith(
        trackId: () => const TrackId('track-1'),
        playIntent: true,
        processing: ProcessingState.loading,
      );

      expect(snap.playIntent, true);
      expect(snap.processing, ProcessingState.loading);
      expect(snap.isPlaying, false, reason: 'Must not report isPlaying while still loading');
    });

    test('PlayIntent with ready reports isPlaying', () {
      final snap = PlaybackSnapshot.initial().copyWith(
        trackId: () => const TrackId('track-1'),
        playIntent: true,
        processing: ProcessingState.ready,
      );

      expect(snap.isPlaying, true);
    });

    test('Buffering with playIntent reports isPlaying', () {
      final snap = PlaybackSnapshot.initial().copyWith(
        trackId: () => const TrackId('track-1'),
        playIntent: true,
        processing: ProcessingState.buffering,
      );

      expect(snap.isPlaying, true);
    });

    test('Completed or paused does not report isPlaying', () {
      final snapCompleted = PlaybackSnapshot.initial().copyWith(
        playIntent: true,
        processing: ProcessingState.completed,
      );
      expect(snapCompleted.isPlaying, false);

      final snapPaused = PlaybackSnapshot.initial().copyWith(
        playIntent: false,
        processing: ProcessingState.ready,
      );
      expect(snapPaused.isPlaying, false);
    });
  });
}
