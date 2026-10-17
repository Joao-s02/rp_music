import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/queue/domain/playback_queue.dart';

void main() {
  group('PlaybackQueue Tests', () {
    test('Queue creation and ordering', () {
      final t1 = TrackId('track-1');
      final t2 = TrackId('track-2');
      final t3 = TrackId('track-3');

      final queue = PlaybackQueue.initial().withTracks([t1, t2, t3], initialTrackId: t2);

      expect(queue.entries.length, 3);
      expect(queue.currentEntry?.trackId, t2);
      expect(queue.currentIndex, 1);
      expect(queue.isShuffle, false);
      expect(queue.repeatMode, RepeatMode.off);
    });

    test('Queue navigation: next and previous in normal mode', () {
      final t1 = TrackId('track-1');
      final t2 = TrackId('track-2');
      final t3 = TrackId('track-3');

      final queue = PlaybackQueue.initial().withTracks([t1, t2, t3], initialTrackId: t1);

      final next = queue.nextEntry;
      expect(next?.trackId, t2);

      final queueAt2 = queue.copyWith(currentEntryId: () => next?.entryId);
      expect(queueAt2.nextEntry?.trackId, t3);
      expect(queueAt2.previousEntry?.trackId, t1);

      final queueAt3 = queue.copyWith(currentEntryId: () => queueAt2.nextEntry?.entryId);
      expect(queueAt3.nextEntry, isNull, reason: 'RepeatMode.off should stop at the end');
    });

    test('Queue navigation: RepeatMode.all cycles continuously', () {
      final t1 = TrackId('track-1');
      final t2 = TrackId('track-2');

      var queue = PlaybackQueue.initial().withTracks([t1, t2], initialTrackId: t2);
      queue = queue.copyWith(repeatMode: RepeatMode.all);

      expect(queue.nextEntry?.trackId, t1, reason: 'RepeatMode.all wraps from last to first');

      final queueAt1 = queue.copyWith(currentEntryId: () => queue.nextEntry?.entryId);
      expect(queueAt1.previousEntry?.trackId, t2, reason: 'RepeatMode.all wraps backwards');
    });

    test('Queue navigation: RepeatMode.one repeats same entry', () {
      final t1 = TrackId('track-1');
      final t2 = TrackId('track-2');

      final queue = PlaybackQueue.initial().withTracks([t1, t2], initialTrackId: t1).copyWith(repeatMode: RepeatMode.one);

      expect(queue.nextEntry?.trackId, t1);
      expect(queue.previousEntry?.trackId, t1);
    });

    test('Shuffle toggling maintains same entries but changes playback order', () {
      final trackIds = List.generate(20, (i) => TrackId('track-$i'));
      final queue = PlaybackQueue.initial().withTracks(trackIds);

      final shuffled = queue.toggleShuffle();
      expect(shuffled.isShuffle, true);
      expect(shuffled.entries.length, 20);

      // Verify all track IDs are still present
      final originalIds = queue.entries.map((e) => e.trackId.value).toSet();
      final shuffledIds = shuffled.entries.map((e) => e.trackId.value).toSet();
      expect(shuffledIds, originalIds);
    });

    test('Queue allows duplicate tracks with distinct entryIds', () {
      final t1 = TrackId('track-1');
      final queue = PlaybackQueue.initial().withTracks([t1, t1, t1]);

      expect(queue.entries.length, 3);
      expect(queue.entries[0].entryId, isNot(queue.entries[1].entryId));
      expect(queue.entries[1].entryId, isNot(queue.entries[2].entryId));
    });
  });
}
