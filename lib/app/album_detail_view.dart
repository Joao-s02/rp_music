import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/track.dart';
import '../playback/music_handler.dart';
import 'library_controller.dart';
import 'music_app.dart' show Artwork;

class AlbumDetailView extends StatefulWidget {
  const AlbumDetailView({
    super.key,
    required this.tracks,
    required this.audio,
    required this.library,
    required this.onBack,
    required this.onSave,
    required this.menu,
  });
  final List<Track> tracks;
  final MusicHandler audio;
  final LibraryController library;
  final VoidCallback onBack, onSave;
  final Widget Function(Track) menu;
  @override
  State<AlbumDetailView> createState() => _AlbumDetailViewState();
}

class _AlbumDetailViewState extends State<AlbumDetailView> {
  bool queue = false;
  String format(Track t) {
    String path = t.id;
    try {
      path = Uri.decodeComponent(path);
    } catch (_) {}
    final name = path.split('.').last.toUpperCase();
    return [
          'FLAC',
          'MP3',
          'M4A',
          'AAC',
          'OPUS',
          'WAV',
          'OGG',
          'MP4',
        ].contains(name)
        ? name
        : '';
  }

  String time(int ms) => ms >= 3600000
      ? '${ms ~/ 3600000}h ${(ms ~/ 60000) % 60}m'
      : '${ms ~/ 60000}:${(ms ~/ 1000 % 60).toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context) {
    final tracks = widget.library.ordered(widget.tracks);
    if (tracks.any((t) => t.trackNumber > 0)) {
      tracks.sort((a, b) {
        final disc = a.discNumber.compareTo(b.discNumber);
        if (disc != 0) return disc;
        return (a.trackNumber == 0 ? 65536 : a.trackNumber).compareTo(
          b.trackNumber == 0 ? 65536 : b.trackNumber,
        );
      });
    }
    if (tracks.isEmpty) {
      return Center(
        child: TextButton(
          onPressed: widget.onBack,
          child: const Text('Volver a álbumes'),
        ),
      );
    }
    final title = tracks.first.album;
    final artists = tracks.map((t) => t.artist).toSet();
    final total = tracks.fold<int>(0, (sum, t) => sum + t.durationMs);
    final formats = tracks.map(format).where((f) => f.isNotEmpty).toSet();
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    Widget chip(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label, style: theme.textTheme.bodySmall),
    );
    return StreamBuilder(
      stream: widget.audio.mediaItem,
      builder: (context, current) {
        final shown = queue ? widget.audio.tracks : tracks;
        return CustomScrollView(
          key: const PageStorageKey('album-detail'),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Álbumes'),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.surfaceContainerHigh,
                      theme.colorScheme.surfaceContainer,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, box) {
                        final size = min(280.0, box.maxWidth);
                        return Center(
                          child: SizedBox(
                            width: size,
                            height: size,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Artwork(
                                    id: tracks.first.id,
                                    library: widget.library,
                                    size: size,
                                  ),
                                ),
                                if (formats.length == 1)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: chip(formats.first),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    Text(
                      '● ÁLBUM LOCAL',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accent,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      artists.length == 1 ? artists.first : 'Varios artistas',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        chip(
                          '${tracks.length} canciones${total > 0 ? ' · ${time(total)}${tracks.any((t) => t.durationMs == 0) ? ' conocidos' : ''}' : ''}',
                        ),
                        if (formats.length > 1) chip(formats.join(' / ')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            widget.audio.shuffle = false;
                            widget.audio.select(tracks, 0);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Reproducir'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            widget.audio.shuffle = true;
                            widget.audio.select(
                              tracks,
                              Random().nextInt(tracks.length),
                            );
                          },
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Aleatorio'),
                        ),
                        IconButton.filledTonal(
                          onPressed: widget.onSave,
                          tooltip: 'Añadir álbum a una lista',
                          icon: const Icon(Icons.playlist_add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    for (final value in [false, true])
                      Expanded(
                        child: Semantics(
                          selected: queue == value,
                          button: true,
                          child: InkWell(
                            key: ValueKey(
                              value ? 'album-queue' : 'album-tracks',
                            ),
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => queue = value),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: queue == value
                                    ? theme.colorScheme.surfaceContainerHighest
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    value
                                        ? Icons.queue_music
                                        : Icons.graphic_eq,
                                    size: 19,
                                    color: queue == value ? accent : null,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      value
                                          ? 'Cola en curso'
                                          : 'Pistas del álbum',
                                      maxLines: 2,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: queue == value
                                                ? accent
                                                : null,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (shown.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'La cola está vacía. Reproduce el álbum para comenzar.',
                  ),
                ),
              ),
            SliverList.builder(
              itemCount: shown.length,
              itemBuilder: (context, index) {
                final track = shown[index];
                final selected = current.data?.id == track.id;
                final favorite = widget.library.favorites.contains(track.id);
                final codec = format(track);
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(
                        color: selected ? accent : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => widget.audio.select(shown, index),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 4, 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 26,
                            child: selected
                                ? Icon(
                                    Icons.graphic_eq,
                                    color: accent,
                                    size: 22,
                                  )
                                : Text(
                                    (index + 1).toString().padLeft(2, '0'),
                                    style: theme.textTheme.bodySmall,
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: selected ? accent : null,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        track.artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                    if (codec.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(left: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accent.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          codec,
                                          style: theme.textTheme.labelSmall,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            track.durationMs > 0 ? time(track.durationMs) : '—',
                            style: theme.textTheme.bodySmall,
                          ),
                          if (track.sourceId == null && (selected || favorite))
                            IconButton(
                              tooltip: 'Favorito',
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                widget.library.toggleFavorite(track.id);
                                setState(() {});
                              },
                              icon: Icon(
                                favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: accent,
                                size: 21,
                              ),
                            ),
                          widget.menu(track),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }
}
