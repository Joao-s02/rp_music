import 'package:rp_music/core/ids/ids.dart';

class QueueEntry {
  final EntryId entryId;
  final TrackId trackId;
  final int position;
  final int shufflePosition;

  const QueueEntry({
    required this.entryId,
    required this.trackId,
    required this.position,
    required this.shufflePosition,
  });

  QueueEntry copyWith({
    EntryId? entryId,
    TrackId? trackId,
    int? position,
    int? shufflePosition,
  }) {
    return QueueEntry(
      entryId: entryId ?? this.entryId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      shufflePosition: shufflePosition ?? this.shufflePosition,
    );
  }
}
