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
  List<SourceEntity> entities = [];
  String kind = 'song';
  SourceEntity? collection;
  String? cursor;
  String pageTitle = '';
  final Set<String> consumedCursors = {};
  bool get explorer =>
      widget
          .programs
          .installed[widget.extensionId]
          ?.package
          .sourceSpec
          ?.browse ==
      true;
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
      entities = [];
      cursor = null;
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

  Future<void> search({SourceEntity? open, bool more = false}) async {
    if (!allowed || searching) return;
    final text = query.text.trim();
    if (!more && open == null && (text.isEmpty || text.length > 200)) {
      setState(() => error = 'Escribe entre 1 y 200 caracteres.');
      return;
    }
    if (more && (cursor == null || consumedCursors.contains(cursor))) return;
    final requestedCursor = more ? cursor : null;
    final target = more ? collection : open;
    final current = ++generation;
    final installed = widget.programs.installed[widget.extensionId];
    setState(() {
      searching = true;
      error = null;
    });
    try {
      final page = explorer
          ? await service.explore(
              widget.extensionId,
              query: text,
              kind: target?.kind ?? kind,
              entity: target?.id,
              cursor: requestedCursor,
            )
          : null;
      final found =
          page?.tracks ?? await service.search(text, widget.extensionId);
      if (!mounted ||
          current != generation ||
          !allowed ||
          widget.programs.installed[widget.extensionId] != installed) {
        return;
      }
      if (more &&
          page?.cursor != null &&
          (page!.cursor == requestedCursor ||
              consumedCursors.contains(page.cursor))) {
        throw const FormatException(
          'La fuente repitió una página. Reintenta la búsqueda antes de importar.',
        );
      }
      widget.library.rememberRemoteTracks(found);
      setState(() {
        if (!more) consumedCursors.clear();
        if (requestedCursor != null) consumedCursors.add(requestedCursor);
        results = more ? [...results, ...found] : found;
        entities = more
            ? [...entities, ...?page?.entities]
            : page?.entities ?? [];
        collection = page?.collection ?? target;
        cursor = page?.cursor;
        if (cursor != null && consumedCursors.contains(cursor)) cursor = null;
        if (!more) pageTitle = page?.title ?? target?.title ?? '';
      });
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

  Future<void> importCollection() async {
    if (searching ||
        results.isEmpty ||
        cursor != null ||
        collection == null ||
        collection!.kind == 'artist') {
      return;
    }
    var draftName = pageTitle.isEmpty ? collection!.title : pageTitle;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar copia local'),
        content: TextFormField(
          initialValue: draftName,
          onChanged: (value) => draftName = value,
          maxLength: 80,
          decoration: const InputDecoration(labelText: 'Nombre de la lista'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftName),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
    if (name == null || !mounted || !allowed) return;
    try {
      await widget.library.importSourcePlaylist(name, results);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Copia local guardada. No modifica YouTube ni descarga audio.',
            ),
          ),
        );
      }
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message.toString());
    }
  }

  Future<void> download(Track track) async {
    if (downloading != null) return;
    setState(() => downloading = track.id);
    try {
      final saved = await SourceDownload.save(track, service);
      if (mounted && saved.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saved.notice ?? 'Canción guardada con etiquetas. Actualiza la biblioteca si elegiste su carpeta.',
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
                    onPressed: allowed && !searching ? () => search() : null,
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
              if (explorer)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final entry in const {
                        'song': 'Canciones',
                        'artist': 'Artistas',
                        'album': 'Álbumes',
                        'playlist': 'Listas',
                      }.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(entry.value),
                            selected: kind == entry.key,
                            onSelected: searching
                                ? null
                                : (_) {
                                    setState(() => kind = entry.key);
                                    search();
                                  },
                          ),
                        ),
                    ],
                  ),
                ),
              if (collection != null) ...[
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Volver a resultados',
                      onPressed: searching ? null : () => search(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(
                        pageTitle.isEmpty ? collection!.title : pageTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: results.isEmpty || !allowed
                          ? null
                          : () => widget.audio.select(results, 0),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Reproducir'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          searching ||
                              cursor != null ||
                              results.isEmpty ||
                              collection?.kind == 'artist' ||
                              !allowed
                          ? null
                          : importCollection,
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Importar copia'),
                    ),
                  ],
                ),
                if (cursor != null)
                  const Text(
                    'Carga todas las páginas antes de importar la colección.',
                  ),
              ],
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
          child: results.isEmpty && entities.isEmpty && cursor == null
              ? const Center(
                  child: Text('Busca una canción o artista para comenzar.'),
                )
              : ListView.builder(
                  itemCount:
                      entities.length +
                      results.length +
                      (cursor == null ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index < entities.length) {
                      final entity = entities[index];
                      return ListTile(
                        leading: Icon(
                          entity.kind == 'artist'
                              ? Icons.person_outline
                              : entity.kind == 'album'
                              ? Icons.album_outlined
                              : Icons.playlist_play,
                        ),
                        title: Text(entity.title),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: !allowed || searching
                            ? null
                            : () => search(open: entity),
                      );
                    }
                    final trackIndex = index - entities.length;
                    if (trackIndex == results.length) {
                      return TextButton(
                        onPressed: searching || !allowed
                            ? null
                            : () => search(more: true),
                        child: const Text('Cargar más'),
                      );
                    }
                    final track = results[trackIndex];
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
                          ? () => widget.audio.select(results, trackIndex)
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
