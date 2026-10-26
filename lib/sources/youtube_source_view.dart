import 'dart:io';

import 'package:flutter/material.dart';

import '../app/library_controller.dart';
import '../app/music_app.dart' show PlayerPanel, Artwork;
import '../domain/track.dart';
import '../extensions/program_controller.dart';
import '../playback/music_handler.dart';
import 'youtube_music_api.dart';

class YoutubeSourceView extends StatefulWidget {
  const YoutubeSourceView({
    super.key,
    required this.programs,
    required this.extensionId,
    required this.audio,
    required this.library,
    this.api,
    this.platformSupported,
  });
  final ProgramController programs;
  final String extensionId;
  final MusicHandler audio;
  final LibraryController library;
  final YoutubeMusicApi? api;
  final bool Function()? platformSupported;
  @override
  State<YoutubeSourceView> createState() => _YoutubeSourceViewState();
}

class _YoutubeSourceViewState extends State<YoutubeSourceView> {
  final query = TextEditingController();
  late final api = widget.api ?? YoutubeMusicApi();
  List<Track> results = [];
  bool searching = false;
  String? error;
  int generation = 0;
  bool get allowed =>
      (widget.platformSupported?.call() ?? Platform.isAndroid) &&
      widget.programs.owner('source')?.package.id == widget.extensionId &&
      widget.programs.allowed(widget.extensionId, 'network.youtube') &&
      widget.programs.allowed(widget.extensionId, 'playback.control');
  @override
  void initState() {
    super.initState();
    widget.programs.addListener(changed);
  }

  void changed() {
    if (!mounted) return;
    if (!allowed) {
      generation++;
      results = [];
      searching = false;
    }
    setState(() {});
  }

  @override
  void dispose() {
    generation++;
    widget.programs.removeListener(changed);
    query.dispose();
    super.dispose();
  }

  Future<void> search() async {
    if (!allowed || searching) return;
    final text = query.text.trim();
    if (text.isEmpty || text.length > 200) {
      setState(() => error = 'Escribe entre 1 y 200 caracteres.');
      return;
    }
    final current = ++generation;
    final installed = widget.programs.installed[widget.extensionId];
    setState(() {
      searching = true;
      error = null;
    });
    try {
      final request = await widget.programs.invoke(
        widget.extensionId,
        'source',
        {'query': text},
      );
      if (request == null ||
          request['provider'] != 'youtube-music' ||
          request['query'] is! String) {
        throw const FormatException(
          'La extensión no devolvió una búsqueda compatible.',
        );
      }
      if (!allowed ||
          widget.programs.installed[widget.extensionId] != installed) {
        return;
      }
      final found = await api.search(
        request['query'] as String,
        widget.extensionId,
      );
      if (!mounted ||
          current != generation ||
          !allowed ||
          widget.programs.installed[widget.extensionId] != installed) {
        return;
      }
      setState(() => results = found);
    } catch (e) {
      if (mounted && current == generation) {
        setState(
          () => error = e is FormatException
              ? e.message.toString()
              : 'No se pudo buscar. Revisa la conexión e intenta más tarde.',
        );
      }
    } finally {
      if (mounted && current == generation) setState(() => searching = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('YouTube Music · experimental')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Canciones · sin cuenta. Reproducción en línea; requiere conexión. Algunas canciones pueden no estar disponibles.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: query,
                enabled: allowed,
                maxLength: 200,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => search(),
                decoration: InputDecoration(
                  labelText: 'Buscar canciones',
                  suffixIcon: IconButton(
                    tooltip: 'Buscar',
                    onPressed: allowed && !searching ? search : null,
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
              if (!allowed)
                const Text(
                  'Activa esta extensión y elígela como fuente en Extensiones.',
                ),
              if (searching) const LinearProgressIndicator(),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: Text('Busca una canción o artista para comenzar.'),
                )
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final track = results[index];
                    return ListTile(
                      title: Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        track.artist,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: Artwork(id: track.id, library: widget.library),
                      trailing: const Icon(Icons.play_arrow_rounded),
                      onTap: allowed
                          ? () => widget.audio.select(results, index)
                          : null,
                    );
                  },
                ),
        ),
        PlayerPanel(audio: widget.audio, library: widget.library),
      ],
    ),
  );
}
