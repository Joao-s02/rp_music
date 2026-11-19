import 'package:flutter/material.dart';

import '../playback/music_handler.dart';
import 'library_controller.dart';
import 'music_app.dart' show Artwork;
import 'now_playing_bars.dart';

Future<void> showPlaybackQueue(
  BuildContext context,
  MusicHandler audio,
  LibraryController library,
) async {
  if (MediaQuery.sizeOf(context).width >= 850) {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar cola',
      pageBuilder: (context, _, _) => Align(
        alignment: Alignment.centerRight,
        child: SafeArea(
          child: SizedBox(
            width: 420,
            child: ScaffoldMessenger(
              child: Scaffold(
                body: PlaybackQueue(
                  audio: audio,
                  library: library,
                  onClose: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: ScaffoldMessenger(
          child: Scaffold(
            body: PlaybackQueue(audio: audio, library: library),
          ),
        ),
      ),
    ),
  );
}

enum _QueueAction { next, up, down, remove }

Future<T?> showTrackContextMenu<T>(
  BuildContext context,
  Offset position,
  List<PopupMenuEntry<T>> items,
) {
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final point = overlay.globalToLocal(position);
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromSize(point & Size.zero, overlay.size),
    items: items,
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
  );
}

class TrackContextRegion extends StatelessWidget {
  const TrackContextRegion({
    super.key,
    required this.open,
    required this.child,
  });
  final ValueChanged<Offset> open;
  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onLongPressStart: (details) => open(details.globalPosition),
    onSecondaryTapUp: (details) => open(details.globalPosition),
    child: child,
  );
}

class PlaybackQueue extends StatefulWidget {
  const PlaybackQueue({
    super.key,
    required this.audio,
    this.library,
    this.onClose,
  });
  final MusicHandler audio;
  final LibraryController? library;
  final VoidCallback? onClose;

  @override
  State<PlaybackQueue> createState() => _PlaybackQueueState();
}

class _PlaybackQueueState extends State<PlaybackQueue> {
  MusicHandler get audio => widget.audio;
  LibraryController? get library => widget.library;
  VoidCallback? get onClose => widget.onClose;
  List<int>? dragOrder;

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: audio.queue,
    builder: (context, _) => StreamBuilder(
      stream: audio.mediaItem,
      builder: (context, _) {
        final start = audio.index + 1;
        final entries = [
          for (var i = start; i < audio.tracks.length; i++)
            audio.queueEntryAt(i),
        ];
        final history = audio.playbackHistory.take(20).toList();
        final historySection = ExpansionTile(
          title: const Text('Escuchadas recientemente'),
          children: [
            for (final track in history)
              ListTile(
                title: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
        final current = audio.index >= 0 ? audio.tracks[audio.index] : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: const Text('Cola en curso'),
              subtitle: audio.shuffle ? const Text('Aleatorio activado') : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<bool>(
                    tooltip: 'Opciones de la cola',
                    enabled: entries.isNotEmpty,
                    onSelected: (_) => audio.clearPending(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: true,
                        child: Text('Vaciar pendientes'),
                      ),
                    ],
                  ),
                  if (onClose != null)
                    IconButton(
                      tooltip: 'Cerrar cola',
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
            ),
            if (current != null)
              ListTile(
                key: ValueKey('queue-track-${audio.index}'),
                selected: true,
                trailing: StreamBuilder(
                  stream: audio.playerStateStream,
                  initialData: audio.player.playerState,
                  builder: (_, state) => NowPlayingBars(
                    playing: state.data?.playing ?? audio.player.playing,
                  ),
                ),
                leading: library == null
                    ? const Icon(Icons.graphic_eq)
                    : Artwork(id: current.id, library: library!),
                title: Text(
                  current.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Sonando ahora · ${current.artist}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('A continuación'),
            ),
            Expanded(
              child: entries.isEmpty
                  ? ListView(
                      children: [
                        const ListTile(
                          title: Text('No hay canciones pendientes'),
                        ),
                        if (history.isNotEmpty) historySection,
                      ],
                    )
                  : ReorderableListView.builder(
                      key: const ValueKey('playback-queue'),
                      buildDefaultDragHandles: false,
                      footer: history.isEmpty ? null : historySection,
                      itemCount: entries.length,
                      onReorderStart: (_) => dragOrder = entries,
                      onReorderItem: (from, to) {
                        final order = dragOrder ?? entries;
                        dragOrder = null;
                        if (from < order.length && to < order.length) {
                          audio.movePendingRelative(
                            order[from],
                            order[to],
                            after: from < to,
                          );
                        }
                      },
                      itemBuilder: (context, i) {
                        final entry = entries[i];
                        final track = audio.tracks[start + i];
                        final options = [
                          const PopupMenuItem(
                            value: _QueueAction.next,
                            child: Text('Mover a continuación'),
                          ),
                          PopupMenuItem(
                            value: _QueueAction.up,
                            enabled: i > 0,
                            child: const Text('Subir'),
                          ),
                          PopupMenuItem(
                            value: _QueueAction.down,
                            enabled: i + 1 < entries.length,
                            child: const Text('Bajar'),
                          ),
                          const PopupMenuItem(
                            value: _QueueAction.remove,
                            child: Text('Quitar de la cola'),
                          ),
                        ];
                        void choose(_QueueAction action) {
                          switch (action) {
                            case _QueueAction.next:
                              audio.movePendingNext(entry);
                            case _QueueAction.up:
                              audio.movePendingRelative(entry, entries[i - 1]);
                            case _QueueAction.down:
                              audio.movePendingRelative(
                                entry,
                                entries[i + 1],
                                after: true,
                              );
                            case _QueueAction.remove:
                              final undo = audio.removePending(entry);
                              if (undo == null) return;
                              showQueueUndo(context, 'Canción quitada', undo);
                          }
                        }

                        return TrackContextRegion(
                          key: ValueKey('queue-entry-$entry'),
                          open: (position) async {
                            final action = await showTrackContextMenu(
                              context,
                              position,
                              options,
                            );
                            if (context.mounted && action != null) {
                              choose(action);
                            }
                          },
                          child: ListTile(
                            key: ValueKey('queue-track-${start + i}'),
                            leading: library == null
                                ? null
                                : Artwork(id: track.id, library: library!),
                            title: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => audio.playQueueEntry(entry),
                            trailing: ReorderableDragStartListener(
                              index: i,
                              child: const Tooltip(
                                message: 'Arrastra para reordenar',
                                child: SizedBox(
                                  width: 44,
                                  height: 48,
                                  child: Icon(Icons.drag_handle),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    ),
  );
}

void showQueueUndo(BuildContext context, String text, VoidCallback undo) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.removeCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      padding: const EdgeInsets.only(left: 12, right: 4),
      content: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.inversePrimary,
              minimumSize: const Size(0, 36),
            ),
            onPressed: () {
              messenger.hideCurrentSnackBar();
              undo();
            },
            child: const Text('Deshacer'),
          ),
        ],
      ),
    ),
  );
}
