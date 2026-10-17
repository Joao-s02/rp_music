import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rp_music/bootstrap/composition_root.dart';
import 'package:rp_music/features/playback/domain/playback_failure.dart';
import 'package:rp_music/features/playback/domain/playback_snapshot.dart';
import 'package:rp_music/features/queue/domain/playback_queue.dart';

class PlaybackBar extends ConsumerWidget {
  final VoidCallback? onExpand;

  const PlaybackBar({super.key, this.onExpand});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final coordinator = ref.watch(playbackCoordinatorProvider);

    // Watch failure selectively
    final failure = ref.watch(
      playbackSnapshotProvider.select((s) => s.value?.failure),
    );

    return Material(
      elevation: 6,
      color: theme.colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (failure != null) _buildFailureBanner(context, coordinator, failure),
            const _ProgressBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(child: _TrackInfo(onTap: onExpand)),
                  const _PlaybackControls(),
                  const SizedBox(width: 8),
                  const _SecondaryControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureBanner(BuildContext context, dynamic coordinator, PlaybackFailure failure) {
    final theme = Theme.of(context);
    final reasonText = switch (failure.reason) {
      PlaybackFailureReason.sourceMissing => 'File not found on device',
      PlaybackFailureReason.sourceDisconnected => 'File disconnected or permission revoked',
      PlaybackFailureReason.permissionDenied => 'Permission denied to read audio file',
      PlaybackFailureReason.unsupportedFormat => 'Unsupported audio format or corrupt media',
      PlaybackFailureReason.corruptMedia => 'Corrupt audio file',
      PlaybackFailureReason.userActivationRequired => 'Tap to resume audio playback',
      _ => 'Playback error occurred',
    };

    return Container(
      color: theme.colorScheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$reasonText: ${failure.message}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onErrorContainer),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => coordinator.skipNext(),
            child: Text('Skip', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final coordinator = ref.watch(playbackCoordinatorProvider);

    final position = ref.watch(
      playbackSnapshotProvider.select((s) => s.value?.position ?? Duration.zero),
    );
    final duration = ref.watch(
      playbackSnapshotProvider.select((s) => s.value?.duration ?? Duration.zero),
    );

    final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
    final currentMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 3,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: currentMs,
            min: 0.0,
            max: maxMs,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.surfaceContainerHighest,
            onChanged: (val) {
              coordinator.seek(Duration(milliseconds: val.round()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position), style: theme.textTheme.bodySmall),
              Text(_formatDuration(duration), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _TrackInfo extends ConsumerWidget {
  final VoidCallback? onTap;

  const _TrackInfo({this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(currentTrackProvider);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.music_note_rounded, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: trackAsync.when(
                data: (track) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track?.title ?? 'No Track Playing',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      track?.artistName ?? (track != null ? 'Local Audio' : 'Select a track to play'),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                loading: () => const Text('Loading track...'),
                error: (_, _) => const Text('Error loading track'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaybackControls extends ConsumerWidget {
  const _PlaybackControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(playbackCoordinatorProvider);
    final isPlaying = ref.watch(
      playbackSnapshotProvider.select((s) => s.value?.isPlaying ?? false),
    );
    final processing = ref.watch(
      playbackSnapshotProvider.select((s) => s.value?.processing ?? ProcessingState.idle),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          tooltip: 'Previous track',
          onPressed: () => coordinator.skipPrevious(),
        ),
        const SizedBox(width: 4),
        IconButton.filled(
          iconSize: 32,
          icon: processing == ProcessingState.loading || processing == ProcessingState.buffering
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
          tooltip: isPlaying ? 'Pause' : 'Play',
          onPressed: () => coordinator.togglePlayPause(),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          tooltip: 'Next track',
          onPressed: () => coordinator.skipNext(),
        ),
      ],
    );
  }
}

class _SecondaryControls extends ConsumerWidget {
  const _SecondaryControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(playbackCoordinatorProvider);
    final theme = Theme.of(context);

    final isShuffle = ref.watch(
      playbackQueueProvider.select((q) => q.value?.isShuffle ?? false),
    );
    final repeatMode = ref.watch(
      playbackQueueProvider.select((q) => q.value?.repeatMode ?? RepeatMode.off),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle_rounded,
            color: isShuffle ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
          tooltip: isShuffle ? 'Shuffle enabled' : 'Shuffle disabled',
          onPressed: () => coordinator.toggleShuffle(),
        ),
        IconButton(
          icon: Icon(
            repeatMode == RepeatMode.one
                ? Icons.repeat_one_rounded
                : repeatMode == RepeatMode.all
                    ? Icons.repeat_on_rounded
                    : Icons.repeat_rounded,
            color: repeatMode != RepeatMode.off ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Repeat: ${repeatMode.name}',
          onPressed: () => coordinator.cycleRepeatMode(),
        ),
      ],
    );
  }
}
