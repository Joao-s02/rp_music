import '../app/pulse_surface.dart';
import '../extensions/extension_emblem.dart';

import 'package:flutter/material.dart';

import '../app/library_controller.dart';
import '../app/music_app.dart' show PlayerPanel, Artwork;
import '../domain/track.dart';
import '../extensions/program_controller.dart';
import '../playback/music_handler.dart';
import 'extension_source_service.dart';
import 'source_download.dart';
import 'album_download.dart';
import 'download_context.dart';
import '../app/collection_header.dart';

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

class _SourceViewSnapshot {
  _SourceViewSnapshot(
    this.query,
    this.kind,
    this.results,
    this.entities,
    this.collection,
    this.cursor,
    this.pageTitle,
    this.consumed,
    this.offset,
  );
  final String query, kind, pageTitle;
  final List<Track> results;
  final List<SourceEntity> entities;
  final SourceEntity? collection;
  final String? cursor;
  final Set<String> consumed;
  final double offset;
}

class _SourceSession {
  _SourceSession(this.current, this.history);
  final _SourceViewSnapshot current;
  final List<_SourceViewSnapshot> history;
}

class _ExtensionSourceViewState extends State<ExtensionSourceView> {
  final query = TextEditingController();
  late final ScrollController scroll;
  double scrollOffset = 0;
  final history = <_SourceViewSnapshot>[];
  late Object? cacheOwner;
  late int cacheRevision;

  _SourceViewSnapshot snapshot() => _SourceViewSnapshot(
    query.text,
    kind,
    List.of(results),
    List.of(entities),
    collection,
    cursor,
    pageTitle,
    Set.of(consumedCursors),
    scrollOffset,
  );

  void restore(_SourceViewSnapshot saved) {
    query.text = saved.query;
    kind = saved.kind;
    results = List.of(saved.results);
    entities = List.of(saved.entities);
    collection = saved.collection;
    cursor = saved.cursor;
    pageTitle = saved.pageTitle;
    consumedCursors
      ..clear()
      ..addAll(saved.consumed);
  }

  void back() {
    if (history.isEmpty) return;
    generation++;
    final previous = history.removeLast();
    setState(() {
      searching = false;
      error = null;
      restore(previous);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scroll.hasClients) {
        scroll.jumpTo(
          previous.offset.clamp(0, scroll.position.maxScrollExtent),
        );
      }
    });
  }

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
  bool preparingAlbum = false;
  String? error;
  int generation = 0;
  bool get allowed => service.available(widget.extensionId);
  @override
  void initState() {
    super.initState();
    cacheOwner = widget.programs.installed[widget.extensionId];
    cacheRevision = widget.programs.authorizationRevision;
    final cached = widget.programs.viewCache.read<_SourceSession>(
      widget.extensionId,
      cacheOwner,
      cacheRevision,
    );
    if (cached != null && allowed) {
      restore(cached.current);
      history.addAll(cached.history);
    }
    scrollOffset = cached?.current.offset ?? 0;
    scroll = ScrollController(initialScrollOffset: scrollOffset)
      ..addListener(() => scrollOffset = scroll.offset);
    widget.programs.addListener(changed);
  }

  void changed() {
    if (!mounted) return;
    if (!allowed ||
        cacheRevision != widget.programs.authorizationRevision ||
        !identical(cacheOwner, widget.programs.installed[widget.extensionId])) {
      cacheOwner = widget.programs.installed[widget.extensionId];
      cacheRevision = widget.programs.authorizationRevision;
      query.clear();
      history.clear();
      collection = null;
      pageTitle = '';
      consumedCursors.clear();
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
    if (allowed &&
        results.length + entities.length <= 1000 &&
        cacheRevision == widget.programs.authorizationRevision &&
        identical(cacheOwner, widget.programs.installed[widget.extensionId])) {
      widget.programs.viewCache.save(
        widget.extensionId,
        cacheOwner,
        cacheRevision,
        _SourceSession(snapshot(), List.of(history)),
      );
    }
    generation++;
    scroll.dispose();
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
    final before = snapshot();
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
        if (!more) {
          if (open != null) {
            history.add(before);
            while (history.length > 12 ||
                history.fold<int>(
                      0,
                      (n, page) =>
                          n + page.results.length + page.entities.length,
                    ) >
                    1000) {
              history.removeAt(0);
            }
          } else {
            history.clear();
          }
          consumedCursors.clear();
        }
        if (requestedCursor != null) consumedCursors.add(requestedCursor);
        results = more ? [...results, ...found] : found;
        entities = more
            ? [...entities, ...?page?.entities]
            : page?.entities ?? [];
        if (!more) {
          final incoming = page?.collection ?? target;
          collection = incoming == null
              ? null
              : SourceEntity(
                  incoming.id,
                  incoming.kind,
                  incoming.title == 'Colección'
                      ? (target?.title ?? incoming.title)
                      : incoming.title,
                  artwork: incoming.artwork ?? target?.artwork,
                  artist: incoming.artist?.isNotEmpty == true
                      ? incoming.artist
                      : target?.artist,
                );
        }
        cursor = page?.cursor;
        if (cursor != null && consumedCursors.contains(cursor)) cursor = null;
        if (!more) pageTitle = page?.title ?? target?.title ?? '';
      });
      if (!more && scroll.hasClients) scroll.jumpTo(0);
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
      final saved = await SourceDownload.save(
        track,
        service,
        albumContext: albumContext(track),
      );
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

  DownloadContext? albumContext([Track? track]) {
    if (collection?.kind != 'album') return null;
    final number = track == null ? null : results.indexOf(track) + 1;
    return DownloadContext(
      album: pageTitle.isEmpty ? collection!.title : pageTitle,
      albumArtist: collection!.artist?.isNotEmpty == true
          ? collection!.artist!
          : (results.map((t) => t.artist).toSet().length == 1
                ? results.first.artist
                : 'Varios artistas'),
      artwork: collection!.artwork,
      trackNumber: number,
      trackTotal: cursor == null ? results.length : null,
    );
  }

  Future<void> downloadAlbum() async {
    if (preparingAlbum ||
        downloading != null ||
        searching ||
        !allowed ||
        collection?.kind != 'album') {
      return;
    }
    setState(() => preparingAlbum = true);
    final original = collection!.id;
    try {
      var pages = 0;
      while (cursor != null) {
        if (!mounted || !allowed || collection?.id != original) return;
        final previous = cursor;
        await search(more: true);
        if (error != null ||
            cursor == previous ||
            ++pages > 20 ||
            results.length > 1000) {
          throw const FormatException(
            'No se pudo reunir el álbum completo. Reintenta antes de descargar.',
          );
        }
      }
      if (!mounted ||
          !allowed ||
          results.isEmpty ||
          collection?.id != original) {
        return;
      }
      await showAlbumDownload(
        context,
        AlbumDownload(List.unmodifiable(results), albumContext()!, service),
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is FormatException
              ? e.message.toString()
              : 'No se pudo preparar el álbum.',
        );
      }
    } finally {
      if (mounted) setState(() => preparingAlbum = false);
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
    final header = PulseSurface(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.embedded)
              Row(
                children: [
                  ExtensionEmblem(id: widget.extensionId),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget
                              .programs
                              .installed[widget.extensionId]
                              ?.package
                              .sourceSpec
                              ?.description ??
                          '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Información de la fuente',
                    icon: const Icon(Icons.info_outline_rounded),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(name),
                        content: Text(
                          widget
                                  .programs
                                  .installed[widget.extensionId]
                                  ?.package
                                  .sourceSpec
                                  ?.description ??
                              '',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            TextField(
              controller: query,
              enabled: allowed,
              maxLength: 200,
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                filled: true,
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
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
                          avatar: Icon(switch (entry.key) {
                            'artist' => Icons.person_rounded,
                            'album' => Icons.album_rounded,
                            'playlist' => Icons.queue_music_rounded,
                            _ => Icons.music_note_rounded,
                          }, size: 18),
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
                    onPressed: history.isEmpty ? null : back,
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
                    widget.programs.allowed(widget.extensionId, 'network.http')
                    ? () => widget.programs.choose('source', widget.extensionId)
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
    );
    final content = Column(
      children: [
        Expanded(
          child: ListView.builder(
            key: const ValueKey('source-scroll'),
            controller: scroll,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 20),
            itemCount:
                1 +
                (results.isEmpty && entities.isEmpty && cursor == null
                    ? 1
                    : 0) +
                (collection?.kind == 'album' ? 1 : 0) +
                entities.length +
                results.length +
                (cursor == null ? 0 : 1),
            itemBuilder: (context, index) {
              if (index == 0) return header;
              index--;
              if (results.isEmpty && entities.isEmpty && cursor == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Busca una canción o artista para comenzar.'),
                );
              }
              if (collection?.kind == 'album') {
                if (index == 0) {
                  return CollectionHeader(
                    title: pageTitle.isEmpty ? collection!.title : pageTitle,
                    label: 'ÁLBUM EN LÍNEA',
                    description:
                        '${collection!.artist ?? (results.isEmpty ? '' : results.first.artist)} · ${results.length} canciones${cursor != null ? ' · faltan páginas' : ''}',
                    artwork: (size) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: collection!.artwork != null
                          ? Image.network(
                              collection!.artwork!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stack) =>
                                  Icon(Icons.album, size: size / 2),
                            )
                          : results.isEmpty
                          ? Icon(Icons.album, size: size / 2)
                          : Artwork(
                              id: results.first.id,
                              library: widget.library,
                              size: size,
                            ),
                    ),
                    actions: [
                      FilledButton.icon(
                        onPressed: results.isEmpty || !allowed
                            ? null
                            : () => widget.audio.select(results, 0),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Reproducir'),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            !allowed ||
                                searching ||
                                preparingAlbum ||
                                downloading != null ||
                                !widget.programs.allowed(
                                  widget.extensionId,
                                  'storage.download',
                                )
                            ? null
                            : downloadAlbum,
                        icon: const Icon(Icons.download),
                        label: Text(
                          preparingAlbum ? 'Preparando…' : 'Descargar álbum',
                        ),
                      ),
                    ],
                  );
                }
                index--;
              }
              if (index < entities.length) {
                final entity = entities[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  child: Card(
                    child: ListTile(
                      minVerticalPadding: 14,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          entity.kind == 'artist' ? 30 : 10,
                        ),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: entity.artwork == null
                              ? Icon(
                                  entity.kind == 'artist'
                                      ? Icons.person_outline
                                      : Icons.album_outlined,
                                )
                              : Image.network(
                                  entity.artwork!,
                                  fit: BoxFit.cover,
                                  cacheWidth: 224,
                                  errorBuilder: (_, error, stack) => Icon(
                                    entity.kind == 'artist'
                                        ? Icons.person_outline
                                        : Icons.album_outlined,
                                  ),
                                ),
                        ),
                      ),
                      title: Text(entity.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: !allowed || searching
                          ? null
                          : () => search(open: entity),
                    ),
                  ),
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
              return PulseSurface(
                index: trackIndex,
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                  ),
                ),
              );
            },
          ),
        ),
        if (!widget.embedded && MediaQuery.viewInsetsOf(context).bottom == 0)
          PlayerPanel(audio: widget.audio, library: widget.library),
      ],
    );
    final navigable = PopScope(
      canPop: history.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) back();
      },
      child: content,
    );
    return widget.embedded
        ? navigable
        : Scaffold(
            appBar: AppBar(title: Text(name)),
            body: SafeArea(child: navigable),
          );
  }
}
