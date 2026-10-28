import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import '../playback/music_handler.dart';
import 'library_controller.dart';
import 'music_app.dart' show Artwork;
import 'scrolling_title.dart';
import 'volume_control.dart';
import 'track_swipe.dart';
import 'lyrics_view.dart';
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
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Cola en curso',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: audio.tracks.length,
                itemBuilder: (context, index) => ListTile(
                  selected: index == audio.index,
                  leading: Icon(
                    index == audio.index
                        ? Icons.graphic_eq
                        : Icons.music_note_outlined,
                  ),
                  title: Text(
                    audio.tracks[index].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    audio.tracks[index].artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    audio.skipToQueueItem(index);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
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
        final available =
            MediaQuery.sizeOf(context).height -
            MediaQuery.paddingOf(context).vertical -
            kToolbarHeight -
            32;
        final compact = available < 780;
        final artwork = TrackSwipe(
          audio: audio,
          child: Center(
            child: SizedBox(
              width: (available - 440).clamp(64.0, 360.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: .18),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Artwork(
                    id: item?.id,
                    library: library,
                    size: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        );
        final controls = StreamBuilder(
          stream: audio.player.playerStateStream,
          builder: (context, state) {
            final playing = state.data?.playing ?? audio.player.playing;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 8 : 16),
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
                        minimumSize: Size.square(compact ? 64 : 92),
                        iconSize: compact ? 36 : 46,
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
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
            ),
            SizedBox(height: compact ? 8 : 20),
            if (widget.artworkFirst) artwork,
            SizedBox(height: compact ? 8 : 24),
            Row(
              children: [
                Expanded(
                  child: ScrollingTitle(
                    textAlign: TextAlign.left,
                    text: item?.title ?? 'Elige una canción',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
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
            const SizedBox(height: 6),
            Text(
              [
                item?.artist,
                item?.album,
              ].whereType<String>().where((t) => t.isNotEmpty).join(' · '),
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colors.primary,
                  ),
                  label: const Text('Detalles'),
                  onPressed: () => details(item),
                ),
                ActionChip(
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
                ActionChip(
                  avatar: Icon(
                    Icons.queue_music,
                    size: 18,
                    color: colors.primary,
                  ),
                  label: const Text('Cola'),
                  onPressed: item == null ? null : queue,
                ),
              ],
            ),
            SizedBox(height: compact ? 8 : 20),
            StreamBuilder(
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
                          Flexible(
                            child: Text(
                              local ? 'Archivo local' : 'Audio en línea',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(time(total), style: theme.textTheme.labelMedium),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            VolumeControl(audio: audio, library: library, showPercentage: true),

            if (!widget.artworkFirst) ...[artwork, const SizedBox(height: 24)],
            if (!compact)
              Material(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            local
                                ? Icons.headphones_outlined
                                : Icons.cloud_outlined,
                            color: colors.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(source, style: theme.textTheme.titleSmall),
                                const SizedBox(height: 3),
                                Text(
                                  local
                                      ? 'Tu música en el dispositivo'
                                      : 'Fuente musical de extensión',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Detener',
                            onPressed: item == null ? null : audio.stop,
                            icon: const Icon(Icons.stop_circle_outlined),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.queue_music, color: colors.primary),
                        title: const Text('Cola en curso'),
                        subtitle: Text(
                          '${audio.tracks.length} canciones${audio.shuffle ? ' · Aleatorio activo' : ''}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: item == null ? null : queue,
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: compact ? 8 : 20),
          ],
        );
        return LayoutBuilder(
          builder: (context, constraints) {
            if (!constraints.hasBoundedHeight) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [content, controls],
              );
            }
            return Column(
              children: [
                Expanded(child: SingleChildScrollView(child: content)),
                controls,
              ],
            );
          },
        );
      },
    ),
  );
}
