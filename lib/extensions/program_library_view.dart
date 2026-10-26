import 'dart:async';

import 'package:flutter/material.dart';

import '../app/library_controller.dart';
import '../domain/track.dart';
import '../playback/music_handler.dart';
import 'program_controller.dart';
import 'program_snapshot.dart';

class ProgramLibraryView extends StatefulWidget {
  const ProgramLibraryView({
    super.key,
    required this.library,
    required this.audio,
    this.query = '',
  });
  final LibraryController library;
  final MusicHandler audio;
  final String query;
  @override
  State<ProgramLibraryView> createState() => _ProgramLibraryViewState();
}

class _ProgramLibraryViewState extends State<ProgramLibraryView> {
  ProgramController get programs => widget.library.programs!;
  final filters = <String, dynamic>{
    'artist': '',
    'album': '',
    'folder': '',
    'maxSeconds': 0,
    'favorites': false,
  };
  List<Track> result = [];
  String title = 'Biblioteca personalizada', subtitle = '';
  bool busy = true, failed = false;
  bool cards = false;
  Timer? debounce;
  int generation = 0;
  Object? trackIdentity;
  String? ownerId;
  String favoriteIdentity = '';
  @override
  void initState() {
    super.initState();
    final owner = programs.owner('library');
    final saved = programs.privateData[owner?.package.id]?['filters'];
    if (owner != null &&
        programs.allowed(owner.package.id, 'storage.private') &&
        saved is Map) {
      for (final key in ['artist', 'album', 'folder']) {
        final value = saved[key];
        if (value is String && value.length < 500) filters[key] = value;
      }
      if ([0, 180, 300, 600].contains(saved['maxSeconds'])) {
        filters['maxSeconds'] = saved['maxSeconds'];
      }
      filters['favorites'] = saved['favorites'] == true;
    }
    schedule();
  }

  @override
  void didUpdateWidget(ProgramLibraryView old) {
    super.didUpdateWidget(old);
    if (trackIdentity != widget.library.tracks ||
        old.query != widget.query ||
        ownerId != programs.owner('library')?.package.id ||
        favoriteIdentity != widget.library.favorites.join('|')) {
      schedule();
    }
  }

  void schedule() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 200), run);
  }

  Future<void> run() async {
    if (!mounted) return;
    if (programs.busy) {
      debounce = Timer(const Duration(milliseconds: 200), run);
      return;
    }
    final owner = programs.owner('library');
    if (owner == null) return;
    final id = ++generation;
    trackIdentity = widget.library.tracks;
    ownerId = owner.package.id;
    favoriteIdentity = widget.library.favorites.join('|');
    setState(() {
      busy = true;
      failed = false;
    });
    final snapshot = ProgramSnapshot(
      widget.library.tracks,
      widget.library.favorites,
    );
    final response = await programs.invoke(owner.package.id, 'library', {
      'tracks': snapshot.rows,
      'filters': {...filters, 'query': widget.query},
    });
    if (!mounted || id != generation) return;
    try {
      if (response == null) {
        throw const FormatException('No se pudo ejecutar la extensión.');
      }
      final tracks = snapshot.resolve(response['ids']);
      final heading = response['title'];
      final description = response['description'];
      if (heading is! String ||
          heading.length > 120 ||
          (description != null &&
              (description is! String || description.length > 500))) {
        throw const FormatException('La extensión devolvió textos inválidos.');
      }
      setState(() {
        result = tracks;
        title = heading;
        subtitle = description as String? ?? '';
        cards = response['layout'] == 'cards';
        busy = false;
      });
    } on FormatException catch (error) {
      if (response != null) {
        await programs.reject(owner.package.id, error.message);
      }
      if (mounted) {
        setState(() {
          busy = false;
          failed = true;
        });
      }
    }
  }

  Future<void> save(bool automatic) async {
    final owner = programs.owner('library');
    if (owner == null ||
        !programs.allowed(owner.package.id, 'playlists.manage')) {
      return;
    }
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _SaveListDialog(),
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      if (!programs.allowed(owner.package.id, 'playlists.manage')) {
        throw const FormatException('Se retiró el permiso de listas.');
      }
      if (automatic) {
        if (!owner.package.slots.contains('lists')) {
          throw const FormatException(
            'Esta extensión no aporta reglas de listas.',
          );
        }
        await widget.library.createSmartPlaylist(name, owner.package.id, {
          ...filters,
          'query': widget.query,
        }, result.map((track) => track.id).toList());
      } else {
        if (widget.library.playlists.containsKey(name.trim())) {
          throw const FormatException('Ya existe una lista con ese nombre.');
        }
        await widget.library.createPlaylistWithTracks(
          name,
          result.map((track) => track.id).toList(),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              automatic
                  ? 'Lista automática creada. Puedes elegir su carátula desde Listas.'
                  : 'Lista guardada. Puedes elegir su carátula desde Listas.',
            ),
          ),
        );
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Widget select(String field, String label, Iterable<String> source) {
    final values = source.toSet().toList()..sort();
    final value = filters[field] as String;
    return DropdownButtonFormField<String>(
      initialValue: values.contains(value) ? value : '',
      key: ValueKey('$field:$value:${values.length}'),
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: '', child: Text('Todos')),
        for (final item in values)
          DropdownMenuItem(
            value: item,
            child: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (value) {
        setState(() {
          filters[field] = value ?? '';
        });
        schedule();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = widget.library;
    final owner = programs.owner('library');
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                Text(
                  '${owner?.package.name ?? ''} · extensión con código Dart',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (subtitle.isNotEmpty) Text(subtitle),
                if (library.root == null)
                  FilledButton.tonalIcon(
                    onPressed: library.choosing ? null : library.chooseRoot,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Elegir carpeta de música'),
                  ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Filtros combinados'),
                  initiallyExpanded: false,
                  tilePadding: EdgeInsets.zero,
                  children: [
                    select(
                      'artist',
                      'Artista',
                      library.tracks.map((track) => track.artist),
                    ),
                    const SizedBox(height: 12),
                    select(
                      'album',
                      'Álbum',
                      library.tracks.map((track) => track.album),
                    ),
                    const SizedBox(height: 12),
                    select(
                      'folder',
                      'Carpeta',
                      library.tracks.map((track) => track.folder),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: filters['maxSeconds'] as int,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Duración máxima',
                      ),
                      items: [
                        for (final seconds in [0, 180, 300, 600])
                          DropdownMenuItem(
                            value: seconds,
                            child: Text(
                              seconds == 0
                                  ? 'Sin límite'
                                  : '${seconds ~/ 60} minutos',
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filters['maxSeconds'] = value ?? 0;
                        });
                        schedule();
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Solo favoritos'),
                      value: filters['favorites'] == true,
                      onChanged: (value) {
                        setState(() {
                          filters['favorites'] = value;
                        });
                        schedule();
                      },
                    ),
                  ],
                ),
                if (busy) const LinearProgressIndicator(),
                if (failed)
                  const Text(
                    'La extensión falló. Puedes reintentar o volver a la base.',
                  ),
                if (failed)
                  OutlinedButton(
                    onPressed: run,
                    child: const Text('Reintentar extensión'),
                  ),
                Text(
                  '${result.length} canciones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed:
                          busy ||
                              failed ||
                              result.isEmpty ||
                              owner == null ||
                              !programs.allowed(
                                owner.package.id,
                                'playback.control',
                              )
                          ? null
                          : () => widget.audio.select(result, 0),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Reproducir resultados'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          busy ||
                              failed ||
                              result.isEmpty ||
                              owner == null ||
                              !programs.allowed(
                                owner.package.id,
                                'playback.control',
                              )
                          ? null
                          : () {
                              widget.audio.shuffle = true;
                              widget.audio.select(result, 0);
                            },
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Mezclar'),
                    ),
                    if (owner != null &&
                        programs.allowed(
                          owner.package.id,
                          'playlists.manage',
                        )) ...[
                      OutlinedButton.icon(
                        onPressed: busy || failed ? null : () => save(false),
                        icon: const Icon(Icons.playlist_add),
                        label: const Text('Guardar lista'),
                      ),
                      if (owner.package.slots.contains('lists'))
                        OutlinedButton.icon(
                          onPressed: busy || failed ? null : () => save(true),
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Crear lista automática'),
                        ),
                    ],
                    TextButton(
                      onPressed: () => programs.choose('library', null),
                      child: const Text('Volver a biblioteca base'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverList.builder(
            itemCount: result.length,
            itemBuilder: (context, index) {
              final track = result[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: cards ? 5 : 0),
                child: ListTile(
                  leading: Icon(
                    library.favorites.contains(track.id)
                        ? Icons.favorite
                        : Icons.music_note,
                  ),
                  title: Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${track.artist} · ${track.album}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap:
                      owner == null ||
                          !programs.allowed(
                            owner.package.id,
                            'playback.control',
                          )
                      ? null
                      : () =>
                            widget.audio.select(result, result.indexOf(track)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    generation++;
    debounce?.cancel();
    super.dispose();
  }
}

class _SaveListDialog extends StatefulWidget {
  const _SaveListDialog();
  @override
  State<_SaveListDialog> createState() => _SaveListDialogState();
}

class _SaveListDialogState extends State<_SaveListDialog> {
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Guardar resultados'),
    content: TextField(
      controller: text,
      maxLength: 80,
      autofocus: true,
      decoration: const InputDecoration(labelText: 'Nombre de la lista'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, text.text.trim()),
        child: const Text('Guardar'),
      ),
    ],
  );
}
