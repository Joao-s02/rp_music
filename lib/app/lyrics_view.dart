import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import '../domain/lyrics.dart';
import '../playback/music_handler.dart';
import '../lyrics/lyrics_controller.dart';
import 'lyric_stage.dart';
import '../platform/media_tools.dart';
import 'media_tools_sheet.dart';

class LyricsView extends StatefulWidget {
  const LyricsView({
    super.key,
    required this.audio,
    this.fetchLyrics,
    this.directory,
    this.controller,
  });
  final MusicHandler audio;
  final Future<String> Function()? fetchLyrics;
  final Future<Directory> Function()? directory;
  final LyricsController? controller;
  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(refresh);
  }

  void refresh() {
    if (!mounted || trackId == null) return;
    final controller = widget.controller!;
    final value = controller.values[trackId];
    setState(() {
      error = controller.errors[trackId];
      fetching = controller.pending.containsKey(trackId);
    });
    if (!identical(value, lyrics)) setLyrics(value);
  }

  bool scene = false, chrome = true, following = true;
  Lyrics? lyrics;
  String? trackId, error;
  int generation = 0, active = -2;
  final scroll = ScrollController();
  final keys = <GlobalKey>[];
  final synchronizationAttempts = <String>{};
  Future<File> file(String id) async {
    final root =
        await (widget.directory?.call() ?? getApplicationSupportDirectory());
    return File('${root.path}/lyrics/${sha256.convert(utf8.encode(id))}.lrc');
  }

  Future<void> load(String id) async {
    final current = ++generation;
    try {
      final controller = widget.controller;
      if (controller != null) {
        final track = widget.audio.tracks.where((t) => t.id == id).firstOrNull;
        if (track != null) await controller.ensure(track);
        if (mounted && current == generation) refresh();
        if (track != null &&
            mounted &&
            current == generation &&
            controller.values[id]?.lines.isEmpty == true &&
            controller.canFetch(track) &&
            synchronizationAttempts.add(id)) {
          await controller.ensure(track, forceNetwork: true);
          if (mounted && current == generation) refresh();
        }
        return;
      }
      final target = await file(id);
      final text = await target.exists() ? await target.readAsString() : '';
      if (!mounted || current != generation) return;
      setLyrics(text.isEmpty ? null : Lyrics.parse(text));
    } catch (_) {
      if (mounted && current == generation) {
        setState(() => error = 'No se pudo leer la letra guardada.');
      }
    }
  }

  void setLyrics(Lyrics? value) {
    setState(() {
      lyrics = value;
      active = -2;
      keys.clear();
      keys.addAll(List.generate(value?.lines.length ?? 0, (_) => GlobalKey()));
    });
  }

  Future<void> import() async {
    setState(() => fetching = false);
    final id = trackId;
    if (id == null) return;
    final current = ++generation;
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['lrc', 'txt'],
      );
      if (picked == null || !mounted || current != generation) return;
      final length = await picked.length();
      if (length == null || length > 262144) {
        throw const FormatException(
          'El archivo supera 256 KB o no se pudo leer.',
        );
      }
      final bytes = await picked.readAsBytes();
      if (bytes.length > 262144) {
        throw const FormatException('El archivo supera 256 KB.');
      }
      final text = utf8.decode(bytes).replaceFirst('\ufeff', '');
      final value = Lyrics.parse(text);
      if (text.trim().isEmpty) {
        throw const FormatException('El archivo está vacío.');
      }
      if (!mounted || current != generation) return;
      if (widget.controller != null) {
        await widget.controller!.save(id, text);
        if (mounted && current == generation) setLyrics(value);
        return;
      }
      final target = await file(id);
      await target.parent.create(recursive: true);
      await target.writeAsString(text, flush: true);
      if (!mounted || current != generation) return;
      setState(() => error = null);
      setLyrics(value);
    } catch (e) {
      if (mounted && current == generation) {
        setState(
          () => error = e is FormatException
              ? e.message.toString()
              : 'No se pudo importar la letra.',
        );
      }
    }
  }

  bool fetching = false;
  Future<void> fetch() async {
    final controller = widget.controller;
    if (controller != null) {
      final track = widget.audio.tracks
          .where((t) => t.id == trackId)
          .firstOrNull;
      if (track != null) await controller.ensure(track, forceNetwork: true);
      return;
    }
    final callback = widget.fetchLyrics;
    final id = trackId;
    if (callback == null || id == null || fetching) return;
    final current = ++generation;
    setState(() {
      fetching = true;
      error = null;
    });
    try {
      final text = await callback();
      if (!mounted || current != generation) return;
      if (text.trim().isEmpty) {
        throw const FormatException(
          'No hay letra disponible para esta canción.',
        );
      }
      final value = Lyrics.parse(text);
      if (lyrics?.lines.isNotEmpty == true && value.lines.isEmpty) {
        throw const FormatException(
          'Se conserva la letra sincronizada; el proveedor solo devolvió texto.',
        );
      }
      final target = await file(id);
      await target.parent.create(recursive: true);
      await target.writeAsString(text, flush: true);
      if (mounted && current == generation) setLyrics(value);
    } catch (e) {
      if (mounted && current == generation) {
        setState(
          () => error = e is FormatException
              ? e.message.toString()
              : 'No se pudo consultar la letra.',
        );
      }
    } finally {
      if (mounted && current == generation) setState(() => fetching = false);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(refresh);
    generation++;
    scroll.dispose();
    super.dispose();
  }

  bool get canSearch =>
      widget.fetchLyrics != null ||
      widget.controller != null &&
          widget.audio.tracks.any(
            (t) => t.id == trackId && widget.controller!.canFetch(t),
          );

  Widget synchronized(Duration position) {
    final selected = lyrics!.activeAt(position);
    if (selected != active) {
      active = selected;
      final expected = generation;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            !following ||
            expected != generation ||
            selected < 0 ||
            selected >= keys.length) {
          return;
        }
        final target = keys[selected].currentContext;
        if (target != null) {
          Scrollable.ensureVisible(
            target,
            alignment: .42,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
    return Stack(
      children: [
        NotificationListener<UserScrollNotification>(
          onNotification: (event) {
            if (event.direction != ScrollDirection.idle && following) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => following = false);
              });
            }
            return false;
          },
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: [0, .08, .90, 1],
            ).createShader(rect),
            child: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < lyrics!.lines.length; i++)
                    RepaintBoundary(
                      child: AnimatedContainer(
                        key: keys[i],
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 420),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: i == selected
                              ? Theme.of(context).colorScheme.primary
                                    .withValues(alpha: .055)
                              : Colors.transparent,
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            selected: i == selected,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            title: LyricPhrase(
                              line: lyrics!.lines[i],
                              position: i == selected
                                  ? position
                                  : Duration.zero,
                              active: i == selected,
                            ),
                            onTap: () =>
                                widget.audio.seek(lyrics!.lines[i].time),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!following)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton.tonalIcon(
                onPressed: () => setState(() {
                  following = true;
                  active = -2;
                }),
                icon: const Icon(Icons.my_location),
                label: const Text('Seguir canción'),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: widget.audio.mediaItem,
    initialData: widget.audio.mediaItem.value,
    builder: (context, snapshot) {
      final item = snapshot.data;
      if (trackId != item?.id) {
        trackId = item?.id;
        lyrics = null;
        fetching = false;
        error = null;
        active = -2;
        following = true;
        generation++;
        keys.clear();
        final expectedId = trackId;
        if (expectedId != null) {
          Future.microtask(() {
            if (mounted && trackId == expectedId) load(expectedId);
          });
        }
      }
      final timed = lyrics?.lines.isNotEmpty == true;
      return Scaffold(
        appBar: scene && timed
            ? null
            : AppBar(
                title: const Text('Letras'),
                actions: [
                  IconButton(
                    tooltip: 'Crear un edit',
                    onPressed: item == null
                        ? null
                        : () async {
                            final track = widget.audio.tracks
                                .where((track) => track.id == item.id)
                                .firstOrNull;
                            if (track == null) return;
                            await showMediaTools(
                              context,
                              MediaToolRequest(track, lyrics?.plain ?? ''),
                              beforeOpen: widget.audio.pause,
                            );
                          },
                    icon: const Icon(Icons.movie_creation_outlined),
                  ),
                  if (timed)
                    IconButton(
                      tooltip: 'Abrir escena',
                      onPressed: () => setState(() {
                        scene = true;
                        chrome = true;
                      }),
                      icon: const Icon(Icons.fullscreen_rounded),
                    ),
                  if (canSearch)
                    IconButton(
                      tooltip: 'Buscar letra en línea',
                      onPressed: fetching ? null : fetch,
                      icon: const Icon(Icons.cloud_download_outlined),
                    ),
                  IconButton(
                    tooltip: 'Importar LRC o TXT',
                    onPressed: item == null ? null : import,
                    icon: const Icon(Icons.file_open_outlined),
                  ),
                ],
              ),
        body: SafeArea(
          child: StreamBuilder<Duration>(
            stream: widget.audio.player.positionStream,
            initialData: widget.audio.player.position,
            builder: (context, position) => LyricBackdrop(
              position: position.data ?? Duration.zero,
              child: scene && timed
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => chrome = !chrome),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: LyricScene(
                              lyrics: lyrics!,
                              position: position.data ?? Duration.zero,
                              title: item?.title ?? '',
                              artist: item?.artist ?? '',
                            ),
                          ),
                          if (chrome)
                            Positioned(
                              top: 8,
                              left: 12,
                              right: 12,
                              child: Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Salir de escena',
                                    onPressed: () =>
                                        setState(() => scene = false),
                                    icon: const Icon(
                                      Icons.fullscreen_exit_rounded,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Flexible(
                                    child: Text(
                                      'Toca el fondo para ocultar controles',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (chrome)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: 'Anterior',
                                    onPressed: widget.audio.skipToPrevious,
                                    icon: const Icon(Icons.skip_previous),
                                  ),
                                  StreamBuilder(
                                    stream:
                                        widget.audio.player.playerStateStream,
                                    builder: (context, _) => IconButton.filled(
                                      tooltip: widget.audio.player.playing
                                          ? 'Pausar'
                                          : 'Reproducir',
                                      onPressed: () =>
                                          widget.audio.player.playing
                                          ? widget.audio.pause()
                                          : widget.audio.play(),
                                      icon: Icon(
                                        widget.audio.player.playing
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Siguiente',
                                    onPressed: widget.audio.skipToNext,
                                    icon: const Icon(Icons.skip_next),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item?.title ?? 'Sin canción',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                item?.artist ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                timed
                                    ? 'SINCRONIZADA · SIGUE LA MÚSICA'
                                    : 'LETRAS',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(error!),
                          ),
                        if (fetching) const LinearProgressIndicator(),
                        Expanded(
                          child: lyrics == null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Se muestran letras incrustadas o guardadas. Importa un LRC sincronizado o busca con tu extensión de letras.',
                                        ),
                                        const SizedBox(height: 16),
                                        FilledButton.icon(
                                          onPressed: item == null
                                              ? null
                                              : import,
                                          icon: const Icon(
                                            Icons.file_open_outlined,
                                          ),
                                          label: const Text('Importar letra'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : timed
                              ? synchronized(position.data ?? Duration.zero)
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Esta copia no incluye tiempos de sincronización.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      if (canSearch)
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextButton.icon(
                                            onPressed: fetching ? null : fetch,
                                            icon: const Icon(
                                              Icons.auto_awesome,
                                            ),
                                            label: const Text(
                                              'Buscar sincronizada',
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 20),
                                      SelectableText(
                                        lyrics!.plain,
                                        style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 25,
                                          height: 1.6,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    },
  );
}
