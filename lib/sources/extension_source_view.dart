import 'package:flutter/material.dart';

import '../app/library_controller.dart';
import '../app/music_app.dart' show PlayerPanel, Artwork;
import '../domain/track.dart';
import '../extensions/program_controller.dart';
import '../playback/music_handler.dart';
import 'extension_source_service.dart';
import 'source_download.dart';

class ExtensionSourceView extends StatefulWidget {
  const ExtensionSourceView({
    super.key,
    required this.programs,
    required this.extensionId,
    required this.audio,
    required this.library,
    this.service,
    this.embedded = false,
  });
  final ProgramController programs;
  final String extensionId;
  final MusicHandler audio;
  final LibraryController library;
  final ExtensionSourceService? service;
  final bool embedded;
  @override
  State<ExtensionSourceView> createState() => _ExtensionSourceViewState();
}

class _ExtensionSourceViewState extends State<ExtensionSourceView> {
  final query = TextEditingController();
  late final service =
      widget.service ?? ExtensionSourceService(widget.programs);
  List<Track> results = [];
  bool searching = false;
  String? downloading;
  String? error;
  int generation = 0;
  bool get allowed => service.available(widget.extensionId);
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
      final found = await service.search(text, widget.extensionId);
      if (!mounted ||
          current != generation ||
          !allowed ||
          widget.programs.installed[widget.extensionId] != installed) {
        return;
      }
      widget.library.rememberRemoteTracks(found);
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

  Future<void> download(Track track) async {
    if (downloading != null) return;
    setState(() => downloading = track.id);
    try {
      final saved = await SourceDownload.save(track, service);
      if (mounted && saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Canción guardada. Actualiza la biblioteca si elegiste su carpeta.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is FormatException
                  ? e.message.toString()
                  : 'No se pudo guardar la canción.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => downloading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        widget
            .programs
            .installed[widget.extensionId]
            ?.package
            .sourceSpec
            ?.name ??
        'Fuente en línea';
    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.embedded)
                Row(
                  children: [
                    Icon(
                      Icons.library_music_outlined,
                      color: Color(
                        widget
                                .programs
                                .installed[widget.extensionId]
                                ?.package
                                .sourceSpec
                                ?.color ??
                            0xff47efe0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              if (MediaQuery.viewInsetsOf(context).bottom == 0)
                Text(
                  widget
                          .programs
                          .installed[widget.extensionId]
                          ?.package
                          .sourceSpec
                          ?.description ??
                      '',
                ),
              const SizedBox(height: 12),
              TextField(
                controller: query,
                enabled: allowed,
                maxLength: 200,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => search(),
                decoration: InputDecoration(
                  labelText:
                      widget
                          .programs
                          .installed[widget.extensionId]
                          ?.package
                          .sourceSpec
                          ?.searchLabel ??
                      'Buscar canciones',
                  suffixIcon: IconButton(
                    tooltip: 'Buscar',
                    onPressed: allowed && !searching ? search : null,
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
              if (!allowed)
                FilledButton(
                  onPressed:
                      widget.programs.allowed(
                        widget.extensionId,
                        'network.http',
                      )
                      ? () =>
                            widget.programs.choose('source', widget.extensionId)
                      : null,
                  child: const Text('Usar esta fuente'),
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
                      trailing:
                          widget.programs.allowed(
                            widget.extensionId,
                            'storage.download',
                          )
                          ? IconButton(
                              tooltip: downloading == track.id
                                  ? 'Descargando…'
                                  : 'Descargar canción',
                              onPressed: downloading != null || !allowed
                                  ? null
                                  : () => download(track),
                              icon: downloading == track.id
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.download_outlined),
                            )
                          : const Icon(Icons.play_arrow_rounded),
                      onTap: allowed
                          ? () => widget.audio.select(results, index)
                          : null,
                    );
                  },
                ),
        ),
        if (!widget.embedded && MediaQuery.viewInsetsOf(context).bottom == 0)
          PlayerPanel(audio: widget.audio, library: widget.library),
      ],
    );
    return widget.embedded
        ? content
        : Scaffold(
            appBar: AppBar(title: Text(name)),
            body: SafeArea(child: content),
          );
  }
}
