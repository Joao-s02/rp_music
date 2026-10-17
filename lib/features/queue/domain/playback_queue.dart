import 'dart:math';
import 'package:rp_music/core/ids/ids.dart';
import 'package:rp_music/features/queue/domain/queue_entry.dart';

enum RepeatMode {
  off,
  all,
  one,
}

class PlaybackQueue {
  final List<QueueEntry> entries;
  final EntryId? currentEntryId;
  final bool isShuffle;
  final int shuffleSeed;
  final RepeatMode repeatMode;
  final int revision;

  const PlaybackQueue({
    this.entries = const [],
    this.currentEntryId,
    this.isShuffle = false,
    this.shuffleSeed = 0,
    this.repeatMode = RepeatMode.off,
    this.revision = 0,
  });

  factory PlaybackQueue.initial() => const PlaybackQueue();

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  QueueEntry? get currentEntry {
    if (currentEntryId == null || entries.isEmpty) return null;
    return entries.where((e) => e.entryId == currentEntryId).firstOrNull;
  }

  List<QueueEntry> get orderedEntries {
    final list = List<QueueEntry>.from(entries);
    if (isShuffle) {
      list.sort((a, b) => a.shufflePosition.compareTo(b.shufflePosition));
    } else {
      list.sort((a, b) => a.position.compareTo(b.position));
    }
    return list;
  }

  int get currentIndex {
    final ordered = orderedEntries;
    final curr = currentEntry;
    if (curr == null) return -1;
    return ordered.indexWhere((e) => e.entryId == curr.entryId);
  }

  QueueEntry? get nextEntry {
    if (entries.isEmpty) return null;
    if (repeatMode == RepeatMode.one) return currentEntry;

    final ordered = orderedEntries;
    final idx = currentIndex;
    if (idx == -1) {
      return ordered.firstOrNull;
    }
    if (idx + 1 < ordered.length) {
      return ordered[idx + 1];
    } else if (repeatMode == RepeatMode.all) {
      return ordered.first;
    }
    return null;
  }

  QueueEntry? get previousEntry {
    if (entries.isEmpty) return null;
    if (repeatMode == RepeatMode.one) return currentEntry;

    final ordered = orderedEntries;
    final idx = currentIndex;
    if (idx > 0) {
      return ordered[idx - 1];
    } else if (repeatMode == RepeatMode.all) {
      return ordered.last;
    }
    return null;
  }

  PlaybackQueue withTracks(List<TrackId> trackIds, {TrackId? initialTrackId}) {
    final seed = DateTime.now().millisecondsSinceEpoch;
    final random = Random(seed);

    final positions = List<int>.generate(trackIds.length, (i) => i);
    final shufflePositions = List<int>.from(positions)..shuffle(random);

    EntryId? activeEntryId;
    final newEntries = <QueueEntry>[];
    for (var i = 0; i < trackIds.length; i++) {
      final tid = trackIds[i];
      final entryId = EntryId.generate();
      newEntries.add(QueueEntry(
        entryId: entryId,
        trackId: tid,
        position: i,
        shufflePosition: shufflePositions[i],
      ));
      if (initialTrackId != null && tid == initialTrackId && activeEntryId == null) {
        activeEntryId = entryId;
      }
    }

    if (activeEntryId == null && newEntries.isNotEmpty) {
      activeEntryId = newEntries.first.entryId;
    }

    return PlaybackQueue(
      entries: newEntries,
      currentEntryId: activeEntryId,
      isShuffle: isShuffle,
      shuffleSeed: seed,
      repeatMode: repeatMode,
      revision: revision + 1,
    );
  }

  PlaybackQueue toggleShuffle() {
    final newShuffle = !isShuffle;
    final seed = DateTime.now().millisecondsSinceEpoch;
    final random = Random(seed);

    final shufflePositions = List<int>.generate(entries.length, (i) => i)..shuffle(random);
    final updatedEntries = <QueueEntry>[];
    for (var i = 0; i < entries.length; i++) {
      updatedEntries.add(entries[i].copyWith(shufflePosition: shufflePositions[i]));
    }

    return copyWith(
      entries: updatedEntries,
      isShuffle: newShuffle,
      shuffleSeed: seed,
      revision: revision + 1,
    );
  }

  PlaybackQueue cycleRepeatMode() {
    final nextMode = switch (repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    return copyWith(repeatMode: nextMode, revision: revision + 1);
  }

  PlaybackQueue copyWith({
    List<QueueEntry>? entries,
    EntryId? Function()? currentEntryId,
    bool? isShuffle,
    int? shuffleSeed,
    RepeatMode? repeatMode,
    int? revision,
  }) {
    return PlaybackQueue(
      entries: entries ?? this.entries,
      currentEntryId: currentEntryId != null ? currentEntryId() : this.currentEntryId,
      isShuffle: isShuffle ?? this.isShuffle,
      shuffleSeed: shuffleSeed ?? this.shuffleSeed,
      repeatMode: repeatMode ?? this.repeatMode,
      revision: revision ?? this.revision,
    );
  }
}
