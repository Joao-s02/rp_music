import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rp_music/bootstrap/composition_root.dart';
import 'package:rp_music/features/queue/domain/playback_queue.dart';

class TrackListView extends ConsumerStatefulWidget {
  const TrackListView({super.key});

  @override
  ConsumerState<TrackListView> createState() => _TrackListViewState();
}

class _TrackListViewState extends ConsumerState<TrackListView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _searchQuery = query.trim().isEmpty ? null : query.trim();
      });
    });
  }

  Future<void> _pickFiles() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'aac', 'flac', 'wav', 'ogg'],
    );

    if (files.isNotEmpty) {
      final indexer = ref.read(incrementalIndexerProvider);
      final tracks = await indexer.indexPickedFiles(files);

      if (mounted && tracks.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${tracks.length} tracks into library')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksListProvider(_searchQuery));
    final currentTrackId = ref.watch(
      playbackSnapshotProvider.select((s) => s.value?.trackId),
    );
    final isPlaying = ref.watch(
      playbackSnapshotProvider.select((s) => s.value?.isPlaying ?? false),
    );
    final coordinator = ref.watch(playbackCoordinatorProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          FilledButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Import Audio'),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search tracks or artists...',
              leading: const Icon(Icons.search_rounded),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
              ],
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: tracksAsync.when(
        data: (tracks) {
          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_music_rounded, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('No audio tracks in library', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery != null ? 'No results for "$_searchQuery"' : 'Import local audio files to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.file_open_rounded),
                    label: const Text('Select Audio Files'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final isCurrent = currentTrackId == track.id;

              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCurrent ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isCurrent
                        ? (isPlaying ? Icons.equalizer_rounded : Icons.pause_rounded)
                        : Icons.music_note_rounded,
                    color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(
                  track.title,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? theme.colorScheme.primary : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${track.artistName ?? 'Unknown Artist'} • ${track.albumTitle ?? 'Local Audio'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (track.duration != null)
                      Text(
                        _formatDuration(track.duration!),
                        style: theme.textTheme.bodySmall,
                      ),
                    IconButton(
                      icon: Icon(
                        track.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: track.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () {
                        ref.read(libraryRepositoryProvider).toggleFavorite(track.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  final trackIds = tracks.map((t) => t.id).toList();
                  final queue = PlaybackQueue.initial().withTracks(trackIds, initialTrackId: track.id);
                  coordinator.playQueue(queue, initialTrackId: track.id);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading tracks: $err')),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
