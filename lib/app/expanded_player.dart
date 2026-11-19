import 'player_equalizer.dart';

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import '../playback/music_handler.dart';
import '../domain/track.dart';
import 'library_controller.dart';
import 'music_app.dart' show Artwork;
import 'scrolling_title.dart';
import 'volume_control.dart';
import 'track_swipe.dart';
import 'lyrics_view.dart';
import 'playback_queue.dart';
import '../themes/theme_library.dart';

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
  final outputRoutes = Platform.isAndroid
      ? const EventChannel('rp_music/audio_output/route')
            .receiveBroadcastStream()
      : null;

  static const _outputChannel = MethodChannel('rp_music/audio_output');

  Future<void> showAudioOutput(String name) async {
    if (await _openOutputAction('show') || !mounted) return;
    final routes = await _availableOutputRoutes();
    if (!mounted) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Salida de audio'),
                subtitle: name.isEmpty ? null : Text(name),
              ),
              for (final route in routes)
                ListTile(
                  leading: const Icon(Icons.speaker_outlined),
                  title: Text(route.$2),
                  onTap: () => Navigator.pop(sheet, 'route:${route.$1}'),
                ),
              ListTile(
                leading: const Icon(Icons.volume_up_outlined),
                title: const Text('Ajustes de sonido'),
                onTap: () => Navigator.pop(sheet, 'soundSettings'),
              ),
              ListTile(
                leading: const Icon(Icons.bluetooth),
                title: const Text('Dispositivos Bluetooth'),
                onTap: () => Navigator.pop(sheet, 'bluetoothSettings'),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == null) return;
    final opened = action.startsWith('route:')
        ? await _openOutputAction('transfer', {'id': action.substring(6)})
        : await _openOutputAction(action);
    if (opened || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo cambiar la salida de audio.')),
    );
  }

  Future<List<(String, String)>> _availableOutputRoutes() async {
    try {
      final routes = await _outputChannel.invokeListMethod<dynamic>('routes');
      return [
        for (final route in routes ?? const [])
          if (route case {'id': final String id, 'name': final String name})
            (id, name),
      ];
    } on PlatformException {
      return [];
    } on MissingPluginException {
      return [];
    }
  }

  Future<bool> _openOutputAction(
    String action, [
    Map<String, String>? args,
  ]) async {
    try {
      return await _outputChannel.invokeMethod<bool>(action, args) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  MusicHandler get audio => widget.audio;
  LibraryController get library => widget.library;
  String time(int ms) =>
      '${ms ~/ 60000}:${(ms ~/ 1000 % 60).toString().padLeft(2, '0')}';
  double _verticalDrag = 0;
  void queue() => showPlaybackQueue(context, audio, library);
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
                      icon: ThemeFavoriteIcon(
                        selected: library.favorites.contains(item?.id),
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
                    child: StreamBuilder<dynamic>(
                      stream: outputRoutes,
                      builder: (context, snapshot) {
                        final route = snapshot.data;
                        if (!Platform.isAndroid) {
                          return badge(
                            local ? Icons.graphic_eq : Icons.cloud_outlined,
                            source,
                          );
                        }
                        final data = route is Map ? route : const {};
                        final name = data['name'] as String? ?? '';
                        final icon = switch (data['icon']) {
                          'phone' => Icons.smartphone,
                          'headphones' => Icons.headphones,
                          'bluetooth' => Icons.bluetooth_audio,
                          'tv' => Icons.tv,
                          _ => Icons.speaker_outlined,
                        };
                        return ActionChip(
                          tooltip: 'Cambiar salida de audio',
                          avatar: Icon(icon, size: 18),
                          label: Text(
                            name.isEmpty ? 'Salida de audio' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () => showAudioOutput(name),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
            final controls = StreamBuilder(
              stream: audio.playerStateStream,
              initialData: audio.player.playerState,
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
                          icon: const ThemeIcon('shuffle', Icons.shuffle),
                          color: audio.shuffle ? colors.primary : null,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: 'Anterior',
                          onPressed: item == null ? null : audio.skipToPrevious,
                          icon: const ThemeIcon(
                            'previous',
                            Icons.skip_previous_rounded,
                          ),
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
                            fixedSize: Size.square(dense ? 56 : 64),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.center,
                            iconSize: dense ? 32 : 36,
                          ),
                          onPressed: () =>
                              playing ? audio.pause() : audio.play(),
                          icon: ThemeIcon(
                            playing ? 'pause' : 'play',
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
                          icon: const ThemeIcon(
                            'next',
                            Icons.skip_next_rounded,
                          ),
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
                          icon: const ThemeIcon(
                            'repeat',
                            Icons.repeat_one_rounded,
                          ),
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
                  avatar: const ThemeIcon(
                    'lyrics',
                    Icons.lyrics_outlined,
                    size: 18,
                  ),
                  label: const Text('Letras'),
                  onPressed: item == null
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LyricsView(
                              audio: audio,
                              controller: library.lyrics,
                              loadCover: library.thumbnailFor,
                            ),
                          ),
                        ),
                ),
                _PlayerAction(
                  dense: dense,
                  avatar: ThemeIcon(
                    'queue',
                    Icons.queue_music,
                    size: 18,
                    color: colors.primary,
                  ),
                  label: const Text('Cola'),
                  onPressed: queue,
                ),
                _PlayerAction(
                  dense: dense,
                  avatar: const ThemeIcon(
                    'volume',
                    Icons.volume_up_outlined,
                    size: 20,
                  ),
                  label: const Text('Volumen'),
                  onPressed: volume,
                ),
              ],
            );
            final timeline = StreamBuilder(
              stream: audio.positionStream,
              initialData: audio.player.position,
              builder: (context, position) => StreamBuilder(
                stream: audio.durationStream,
                initialData:
                    audio.player.duration ?? audio.mediaItem.value?.duration,
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
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (_) => _verticalDrag = 0,
              onVerticalDragUpdate: (event) => _verticalDrag += event.delta.dy,
              onVerticalDragEnd: (event) {
                final speed = event.primaryVelocity ?? 0;
                if (_verticalDrag <= -48 || speed < -500) {
                  queue();
                } else if (_verticalDrag >= 48 || speed > 500) {
                  Navigator.maybePop(context);
                }
              },
              child: SizedBox(height: height, child: panel),
            );
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

class PlayerOptions extends StatelessWidget {
  const PlayerOptions({super.key, required this.audio, this.onOpenAlbum});
  final MusicHandler audio;
  final ValueChanged<Track>? onOpenAlbum;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Opciones del reproductor',
    icon: const ThemeIcon('more', Icons.more_vert),
    onPressed: () async {
      final item = audio.mediaItem.value;
      final track = audio.tracks
          .where((track) => track.id == item?.id)
          .firstOrNull;
      final action = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (id, label, icon, enabled) in [
                  (
                    'album',
                    'Ir al álbum',
                    Icons.album_outlined,
                    track != null && onOpenAlbum != null,
                  ),
                  (
                    'eq',
                    'Ecualizador',
                    Icons.equalizer,
                    audio.supportsEqualizer,
                  ),
                  (
                    'details',
                    'Detalles de la canción',
                    Icons.info_outline,
                    item != null,
                  ),
                  (
                    'sleep',
                    'Temporizador de apagado',
                    Icons.timer_outlined,
                    true,
                  ),
                ])
                  ListTile(
                    leading: Icon(icon),
                    title: Text(label),
                    onTap: enabled ? () => Navigator.pop(sheet, id) : null,
                  ),
              ],
            ),
          ),
        ),
      );
      if (!context.mounted) return;
      switch (action) {
        case 'album':
          onOpenAlbum!(track!);
          Navigator.pop(context);
        case 'eq':
          showPlayerEqualizer(context, audio);
        case 'details':
          await showSongDetails(context, track, item: item);
        case 'sleep':
          await showSleepTimer(context, audio);
      }
    },
  );
}

Future<void> showSleepTimer(BuildContext context, MusicHandler audio) async {
  const durations = [1, 5, 10, 15, 30, 45, 60, 90, 120];
  final selection = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Temporizador de apagado',
              style: Theme.of(sheet).textTheme.titleLarge,
            ),
            if (audio.sleepTimerRemaining case final time?)
              Text('Restan ${(time.inSeconds / 60).ceil()} min'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final minutes in durations)
                  ActionChip(
                    label: Text('$minutes min'),
                    onPressed: () => Navigator.pop(sheet, minutes),
                  ),
                if (audio.sleepTimerRemaining != null)
                  ActionChip(
                    label: const Text('Cancelar temporizador'),
                    onPressed: () => Navigator.pop(sheet, 0),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (selection == null || !context.mounted) return;
  audio.setSleepTimer(selection == 0 ? null : Duration(minutes: selection));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        selection == 0
            ? 'Temporizador cancelado'
            : 'La música se pausará en $selection min',
      ),
    ),
  );
}

Future<void> showSongDetails(
  BuildContext context,
  Track? track, {
  MediaItem? item,
}) async {
  final duration = item?.duration?.inMilliseconds ?? track?.durationMs ?? 0;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .65,
      minChildSize: .32,
      maxChildSize: .9,
      builder: (context, controller) => SafeArea(
        child: SingleChildScrollView(
          controller: controller,
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
                'Título': item?.title ?? track?.title ?? 'Sin canción',
                'Artistas': track?.artists.join(', ') ?? item?.artist ?? '—',
                'Álbum': item?.album ?? track?.album ?? '—',
                'Fuente':
                    item?.extras?['sourceName'] as String? ??
                    track?.sourceName ??
                    'Audio local',
                'Formato': track?.format ?? 'Audio',
                if (duration > 0)
                  'Duración':
                      '${duration ~/ 60000}:${(duration ~/ 1000 % 60).toString().padLeft(2, '0')}',
                if (track != null && track.trackNumber > 0)
                  'Pista': '${track.trackNumber}',
                if (track != null && track.discNumber > 0)
                  'Disco': '${track.discNumber}',
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
    ),
  );
}
