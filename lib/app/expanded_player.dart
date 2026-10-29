import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import '../playback/music_handler.dart';
import 'library_controller.dart';
import 'music_app.dart' show Artwork;
import 'scrolling_title.dart';
import 'volume_control.dart';
import 'track_swipe.dart';
import 'lyrics_view.dart';
import 'playback_queue.dart';
import '../sources/extension_source_service.dart';

class ExpandedPlayer extends StatefulWidget {
  const ExpandedPlayer({
    super.key,
    required this.audio,
    required this.library,
    this.artworkFirst = true,
  });
  final MusicHandler audio;
  final LibraryController library;
  final bool artworkFirst;
  @override
  State<ExpandedPlayer> createState() => _ExpandedPlayerState();
}

class _ExpandedPlayerState extends State<ExpandedPlayer> {
  MusicHandler get audio => widget.audio;
  LibraryController get library => widget.library;
  String time(int ms) =>
      '${ms ~/ 60000}:${(ms ~/ 1000 % 60).toString().padLeft(2, '0')}';
  void queue() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: PlaybackQueue(audio: audio),
      ),
    ),
  );
  void volume() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Volumen', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            VolumeControl(audio: audio, library: library, showPercentage: true),
          ],
        ),
      ),
    ),
  );
  void details(MediaItem? item) {
    final track = audio.tracks.where((t) => t.id == item?.id).firstOrNull;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Detalles de la canción',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (final entry in <String, String>{
                'Título': item?.title ?? 'Sin canción',
                'Artistas': track?.artists.join(', ') ?? item?.artist ?? '—',
                'Álbum': item?.album ?? '—',
                'Fuente':
                    item?.extras?['sourceName'] as String? ?? 'Audio local',
                'Formato': track?.format ?? 'Audio',
                if (item?.duration != null)
                  'Duración': time(item!.duration!.inMilliseconds),
                if (track != null && track.size > 0)
                  'Tamaño': '${(track.size / 1048576).toStringAsFixed(1)} MB',
                if (track != null && track.sourceId == null)
                  'Ubicación': track.id,
              }.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(entry.value),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: library,
    builder: (context, _) => StreamBuilder<MediaItem?>(
      stream: audio.mediaItem,
      initialData: audio.mediaItem.value,
      builder: (context, snapshot) {
        final item = snapshot.data;
        final track = audio.tracks.where((t) => t.id == item?.id).firstOrNull;
        final source = item?.extras?['sourceName'] as String? ?? 'Audio local';
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final local = track?.sourceId == null;
        Widget badge(IconData icon, String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
        );
        return LayoutBuilder(
          builder: (context, box) {
            final height = box.hasBoundedHeight
                ? box.maxHeight
                : MediaQuery.sizeOf(context).height - 160;
            final landscape = box.maxWidth >= 560 && height < 520;
            final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
            final dense = height < 440 || height < 560 && textScale > 1.3;
            final metadata = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ScrollingTitle(
                        textAlign: TextAlign.left,
                        text: item?.title ?? 'Elige una canción',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: dense ? 20 : 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Favorito',
                      onPressed: item == null || !local
                          ? null
                          : () => library.toggleFavorite(item.id),
                      icon: Icon(
                        library.favorites.contains(item?.id)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      color: colors.primary,
                    ),
                  ],
                ),
                if (!dense)
                  Text(
                    [item?.artist, item?.album]
                        .whereType<String>()
                        .where((t) => t.isNotEmpty)
                        .join(' · '),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            );
            final artwork = TrackSwipe(
              audio: audio,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: Artwork(
                      id: item?.id,
                      library: library,
                      size: double.infinity,
                    ),
                  ),
                ),
              ),
            );
            final origin = Row(
              children: [
                badge(Icons.album_outlined, track?.format ?? 'Audio'),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: badge(
                      local ? Icons.graphic_eq : Icons.cloud_outlined,
                      source,
                    ),
                  ),
                ),
              ],
            );
            final controls = StreamBuilder(
              stream: audio.player.playerStateStream,
              builder: (context, state) {
                final playing = state.data?.playing ?? audio.player.playing;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: dense ? 0 : 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: IconButton(
                          tooltip: 'Aleatorio',
                          isSelected: audio.shuffle,
                          onPressed: () {
                            setState(() => audio.shuffle = !audio.shuffle);
                            audio.saveSession();
                          },
                          icon: const Icon(Icons.shuffle),
                          color: audio.shuffle ? colors.primary : null,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: 'Anterior',
                          onPressed: item == null ? null : audio.skipToPrevious,
                          icon: const Icon(Icons.skip_previous_rounded),
                          iconSize: 32,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: .14),
                              blurRadius: 28,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: IconButton.filled(
                          tooltip: playing ? 'Pausar' : 'Reproducir',
                          style: IconButton.styleFrom(
                            minimumSize: Size.square(dense ? 56 : 64),
                            iconSize: dense ? 32 : 36,
                          ),
                          onPressed: item == null
                              ? null
                              : () => playing ? audio.pause() : audio.play(),
                          icon: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: 'Siguiente',
                          onPressed: item == null ? null : audio.skipToNext,
                          icon: const Icon(Icons.skip_next_rounded),
                          iconSize: 32,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: 'Repetir canción',
                          isSelected: audio.repeat,
                          onPressed: () {
                            setState(() => audio.repeat = !audio.repeat);
                            audio.saveSession();
                          },
                          icon: const Icon(Icons.repeat_one_rounded),
                          color: audio.repeat ? colors.primary : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );

            final actions = Row(
              children: [
                _PlayerAction(
                  dense: dense,
                  avatar: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colors.primary,
                  ),
                  label: const Text('Detalles'),
                  onPressed: () => details(item),
                ),
                _PlayerAction(
                  dense: dense,
                  avatar: const Icon(Icons.lyrics_outlined, size: 18),
                  label: const Text('Letras'),
                  onPressed: item == null
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LyricsView(
                              audio: audio,
                              controller: library.lyrics,
                              fetchLyrics:
                                  track?.sourceId != null &&
                                      library.programs != null
                                  ? () async {
                                      final selected = audio.tracks
                                          .where(
                                            (t) =>
                                                t.id ==
                                                audio.mediaItem.value?.id,
                                          )
                                          .firstOrNull;
                                      if (selected?.sourceId == null) {
                                        throw const FormatException(
                                          'Esta canción no dispone de proveedor de letras en línea.',
                                        );
                                      }
                                      final result =
                                          await ExtensionSourceService(
                                            library.programs!,
                                          ).invoke(
                                            selected!.sourceId!,
                                            'lyrics',
                                            {
                                              'title': selected.title,
                                              'artist': selected.artist,
                                              'album': selected.album,
                                              'durationMs':
                                                  audio
                                                      .mediaItem
                                                      .value
                                                      ?.duration
                                                      ?.inMilliseconds ??
                                                  selected.durationMs,
                                            },
                                          );
                                      final synced = result['syncedLyrics'];
                                      final text =
                                          synced is String &&
                                              synced.trim().isNotEmpty
                                          ? synced
                                          : result['plainLyrics'] ?? '';
                                      if (text is! String ||
                                          text.length > 262144) {
                                        throw const FormatException(
                                          'Respuesta de letras incompatible.',
                                        );
                                      }
                                      return text;
                                    }
                                  : null,
                            ),
                          ),
                        ),
                ),
                _PlayerAction(
                  dense: dense,
                  avatar: Icon(
                    Icons.queue_music,
                    size: 18,
                    color: colors.primary,
                  ),
                  label: const Text('Cola'),
                  onPressed: item == null ? null : queue,
                ),
                _PlayerAction(
                  dense: dense,
                  avatar: const Icon(Icons.volume_up_outlined, size: 20),
                  label: const Text('Volumen'),
                  onPressed: volume,
                ),
              ],
            );
            final timeline = StreamBuilder(
              stream: audio.player.positionStream,
              builder: (context, position) => StreamBuilder(
                stream: audio.player.durationStream,
                builder: (context, duration) {
                  final total =
                      duration.data?.inMilliseconds ??
                      item?.duration?.inMilliseconds ??
                      0;
                  final current = (position.data?.inMilliseconds ?? 0).clamp(
                    0,
                    total,
                  );
                  return Column(
                    children: [
                      Slider(
                        padding: EdgeInsets.zero,
                        value: current.toDouble(),
                        max: total > 0 ? total.toDouble() : 1,
                        semanticFormatterCallback: (value) =>
                            time(value.round()),
                        onChanged: total <= 0
                            ? null
                            : (value) => audio.seek(
                                Duration(milliseconds: value.round()),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            time(current),
                            style: theme.textTheme.labelMedium,
                          ),
                          Text(time(total), style: theme.textTheme.labelMedium),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );

            final panel = landscape
                ? Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            origin,
                            const SizedBox(height: 8),
                            Expanded(child: artwork),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [metadata, actions, timeline, controls],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      origin,
                      const SizedBox(height: 8),
                      if (widget.artworkFirst) Expanded(child: artwork),
                      const SizedBox(height: 8),
                      metadata,
                      const SizedBox(height: 4),
                      actions,
                      timeline,
                      if (!widget.artworkFirst) Expanded(child: artwork),
                      controls,
                    ],
                  );
            return SizedBox(height: height, child: panel);
          },
        );
      },
    ),
  );
}

class _PlayerAction extends StatelessWidget {
  const _PlayerAction({
    required this.avatar,
    required this.label,
    required this.onPressed,
    required this.dense,
  });
  final Widget avatar, label;
  final VoidCallback? onPressed;
  final bool dense;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Tooltip(
      message: (label as Text).data ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 32, child: Center(child: avatar)),
              if (!dense)
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.labelSmall!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: label,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
