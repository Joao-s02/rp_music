import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../playback/music_handler.dart';
import 'now_playing_bars.dart';

class PlaybackQueue extends StatefulWidget {
  const PlaybackQueue({super.key, required this.audio});
  final MusicHandler audio;
  @override
  State<PlaybackQueue> createState() => _PlaybackQueueState();
}

class _PlaybackQueueState extends State<PlaybackQueue> {
  final scroll = ScrollController();
  (int, double, double)? centered;
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: widget.audio.mediaItem,
    initialData: widget.audio.mediaItem.value,
    builder: (context, _) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Cola en curso',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final extent = math.max(
                76.0,
                36 + MediaQuery.textScalerOf(context).scale(28),
              );
              final index = widget.audio.index;
              final placement = (index, extent, box.maxHeight);
              if (centered != placement) {
                centered = placement;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted || !scroll.hasClients) return;
                  scroll.jumpTo(
                    (index * extent - (box.maxHeight - extent) / 2).clamp(
                      0.0,
                      scroll.position.maxScrollExtent,
                    ),
                  );
                });
              }
              return ListView.builder(
                key: const ValueKey('playback-queue'),
                controller: scroll,
                itemExtent: extent,
                itemCount: widget.audio.tracks.length,
                itemBuilder: (context, i) => ListTile(
                  key: ValueKey('queue-track-$i'),
                  selected: i == index,
                  selectedTileColor: Theme.of(context).colorScheme.primary
                      .withValues(alpha: .08),
                  leading: i == index
                      ? StreamBuilder(
                          stream: widget.audio.player.playerStateStream,
                          builder: (context, state) => NowPlayingBars(
                            playing:
                                state.data?.playing ??
                                widget.audio.player.playing,
                          ),
                        )
                      : SizedBox(
                          width: 26,
                          child: Text('${i + 1}', textAlign: TextAlign.center),
                        ),
                  title: Text(
                    widget.audio.tracks[i].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    widget.audio.tracks[i].artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    widget.audio.skipToQueueItem(i);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
