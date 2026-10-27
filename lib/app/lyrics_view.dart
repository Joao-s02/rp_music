import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import '../domain/lyrics.dart';
import '../playback/music_handler.dart';

class LyricsView extends StatefulWidget {
  const LyricsView({
    super.key,
    required this.audio,
    this.fetchLyrics,
    this.directory,
  });
  final MusicHandler audio;
  final Future<String> Function()? fetchLyrics;
  final Future<Directory> Function()? directory;
  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  Lyrics? lyrics;
  String? trackId, error;
  int generation = 0, active = -2;
  final scroll = ScrollController();
  final keys = <GlobalKey>[];
  Future<File> file(String id) async {
    final root =
        await (widget.directory?.call() ?? getApplicationSupportDirectory());
    return File('${root.path}/lyrics/${sha256.convert(utf8.encode(id))}.lrc');
  }

  Future<void> load(String id) async {
    final current = ++generation;
    try {
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
    generation++;
    scroll.dispose();
    super.dispose();
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
        generation++;
        if (trackId != null) load(trackId!);
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Letras'),
          actions: [
            if (widget.fetchLyrics != null)
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
          child: Column(
            children: [
              ListTile(
                title: Text(item?.title ?? 'Sin canción'),
                subtitle: Text(item?.artist ?? ''),
              ),
              if (error != null)
                Padding(padding: const EdgeInsets.all(16), child: Text(error!)),
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
                                'Importa un archivo LRC para seguir la canción en tiempo real. Los archivos TXT se muestran sin sincronización.',
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: item == null ? null : import,
                                icon: const Icon(Icons.file_open_outlined),
                                label: const Text('Importar letra'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : lyrics!.lines.isEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: SelectableText(lyrics!.plain),
                      )
                    : StreamBuilder<Duration>(
                        stream: widget.audio.player.positionStream,
                        initialData: widget.audio.player.position,
                        builder: (context, position) {
                          final selected = lyrics!.activeAt(
                            position.data ?? Duration.zero,
                          );
                          if (selected != active) {
                            active = selected;
                            final expected = generation;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted ||
                                  expected != generation ||
                                  selected < 0 ||
                                  selected >= keys.length) {
                                return;
                              }
                              final target = keys[selected].currentContext;
                              if (target != null) {
                                Scrollable.ensureVisible(
                                  target,
                                  alignment: .35,
                                  duration:
                                      MediaQuery.disableAnimationsOf(context)
                                      ? Duration.zero
                                      : const Duration(milliseconds: 180),
                                );
                              }
                            });
                          }
                          return SingleChildScrollView(
                            controller: scroll,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < lyrics!.lines.length; i++)
                                  ListTile(
                                    key: keys[i],
                                    selected: i == selected,
                                    title: Text(
                                      lyrics!.lines[i].text,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: i == selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: i == selected
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                            : null,
                                      ),
                                    ),
                                    onTap: () => widget.audio.seek(
                                      lyrics!.lines[i].time,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
