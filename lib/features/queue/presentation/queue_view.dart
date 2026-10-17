import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rp_music/bootstrap/composition_root.dart';
import 'package:rp_music/features/library/domain/track.dart';

class QueueView extends ConsumerWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(playbackCoordinatorProvider);
    final queue = coordinator.currentQueue;
    final currentEntryId = ref.watch(
      playbackQueueProvider.select((q) => q.value?.currentEntryId ?? coordinator.currentQueue.currentEntryId),
    );
    final repo = ref.watch(libraryRepositoryProvider);
    final theme = Theme.of(context);

    final entries = queue.orderedEntries;

    return Scaffold(
      appBar: AppBar(
        title: Text('Queue (${entries.length})'),
        actions: [
          TextButton.icon(
            onPressed: entries.isEmpty ? null : () => coordinator.toggleShuffle(),
            icon: Icon(
              Icons.shuffle_rounded,
              color: queue.isShuffle ? theme.colorScheme.primary : null,
            ),
            label: Text(queue.isShuffle ? 'Shuffled' : 'Shuffle'),
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Text(
                'Playback queue is empty',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isCurrent = entry.entryId == currentEntryId;

                return FutureBuilder<Track?>(
                  future: repo.getTrack(entry.trackId),
                  builder: (context, snapshot) {
                    final track = snapshot.data;
                    final title = track?.title ?? 'Track #${entry.position + 1}';
                    final artist = track?.artistName ?? 'Unknown Artist';

                    return ListTile(
                      leading: Icon(
                        isCurrent ? Icons.play_arrow_rounded : Icons.queue_music_rounded,
                        color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? theme.colorScheme.primary : null,
                        ),
                      ),
                      subtitle: Text(artist),
                      trailing: isCurrent
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Playing',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        final updated = queue.copyWith(currentEntryId: () => entry.entryId);
                        coordinator.playQueue(updated);
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
