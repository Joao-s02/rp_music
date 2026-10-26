import 'scrolling_title.dart';

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../domain/track.dart';
import '../sources/youtube_music_api.dart';
import '../domain/track_sort.dart';
import '../extensions/program_library_view.dart';
import '../extensions/program_manager_view.dart';
import 'playlist_cover.dart';
import '../platform/home_widget.dart';
import '../playback/music_handler.dart';
import 'library_controller.dart';
import 'volume_control.dart';
import 'music_theme.dart';
import 'empty_library.dart';
import 'app_version.dart';
import '../platform/playback_diagnostics.dart';
import '../updates/update_controller.dart';
import '../updates/update_widgets.dart';
import '../platform/android_notifications.dart';

import 'dart:io';

class MusicApp extends StatelessWidget {
  const MusicApp({
    super.key,
    required this.library,
    required this.audio,
    this.notifications,
    this.updates,
  });
  final LibraryController library;
  final MusicHandler audio;
  final AndroidNotifications? notifications;
  final UpdateController? updates;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: library,
    builder: (context, _) {
      final accent = library.activeExtension?.accent;
      return MaterialApp(
        title: 'RP Music',
        debugShowCheckedModeBanner: false,
        theme: musicTheme(Brightness.light, accent),
        darkTheme: musicTheme(Brightness.dark, accent),
        themeMode: library.dark ? ThemeMode.dark : ThemeMode.light,
        home: MusicHome(
          library: library,
          audio: audio,
          notifications: notifications,
          updates: updates,
        ),
      );
    },
  );
}

class MusicHome extends StatefulWidget {
  const MusicHome({
    super.key,
    required this.library,
    required this.audio,
    this.notifications,
    this.updates,
  });
  final LibraryController library;
  final MusicHandler audio;
  final AndroidNotifications? notifications;
  final UpdateController? updates;
  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> with WidgetsBindingObserver {
  int page = 0;
  int view = 0;
  String query = '';
  bool searchExpanded = false;
  final searchFocus = FocusNode();
  String? group;
  Timer? debounce;
  StreamSubscription<String>? errors;
  final search = TextEditingController();
  LibraryController get library => widget.library;
  MusicHandler get audio => widget.audio;
  static const labels = [
    'Biblioteca',
    'Favoritos',
    'Listas',
    'Extensiones',
    'Ajustes',
  ];
  static const icons = [
    Icons.library_music_outlined,
    Icons.favorite_outline,
    Icons.queue_music,
    Icons.extension_outlined,
    Icons.settings_outlined,
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    errors = audio.errors.stream.listen((text) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(text)));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    errors?.cancel();
    debounce?.cancel();
    search.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    audio.recordEvent('Ciclo de vida: ${state.name}');
    if (state != AppLifecycleState.resumed) unawaited(audio.saveSession());
    if (state == AppLifecycleState.resumed) widget.notifications?.refresh();
  }

  void navigate(int value) => setState(() {
    searchFocus.unfocus();
    page = value;
    group = null;
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final desktop = size.maxWidth >= 850;
      final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              if (desktop)
                NavigationRail(
                  extended: true,
                  minExtendedWidth: 240,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      'RP Music',
                      style: TextStyle(
                        letterSpacing: -0.5,
                        fontSize: 24,
                        color: Color(0xff47efe0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  destinations: [
                    for (var i = 0; i < labels.length; i++)
                      NavigationRailDestination(
                        icon: Icon(icons[i]),
                        label: Text(labels[i]),
                      ),
                  ],
                  selectedIndex: page,
                  onDestinationSelected: navigate,
                ),
              if (desktop) const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                      child: Row(
                        children: [
                          if (page == 0) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/branding/rp-music-variant-a.png',
                                width: 36,
                                height: 36,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  page == 0 ? 'RP Music' : labels[page],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: desktop
                                      ? Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                      : Theme.of(context).textTheme.titleLarge,
                                ),
                                if (page == 0)
                                  Text(
                                    'Biblioteca · ${library.tracks.length} pistas',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          if (page == 0)
                            IconButton(
                              tooltip: searchExpanded
                                  ? 'Cerrar búsqueda'
                                  : 'Buscar',
                              icon: Icon(
                                searchExpanded ? Icons.close : Icons.search,
                              ),
                              onPressed: () {
                                setState(() {
                                  searchExpanded = !searchExpanded;
                                  if (!searchExpanded) {
                                    debounce?.cancel();
                                    search.clear();
                                    query = '';
                                  }
                                });
                                if (searchExpanded) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) searchFocus.requestFocus();
                                  });
                                } else {
                                  searchFocus.unfocus();
                                }
                              },
                            ),
                          if (page == 0 && desktop)
                            IconButton(
                              onPressed:
                                  library.scanning || library.root == null
                                  ? null
                                  : () => library.refresh(),
                              tooltip: 'Actualizar biblioteca',
                              icon: const Icon(Icons.refresh),
                            ),
                          if (page == 0 && desktop)
                            FilledButton.tonalIcon(
                              onPressed: library.scanning || library.choosing
                                  ? null
                                  : library.chooseRoot,
                              icon: const Icon(Icons.folder_open),
                              label: Text(
                                desktop ? 'Elegir carpeta' : 'Carpeta',
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (page == 0 && searchExpanded)
                      Padding(
                        key: const ValueKey('library-search'),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                        child: TextField(
                          key: const ValueKey('library-search-field'),
                          controller: search,
                          focusNode: searchFocus,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Buscar en tu música',
                          ),
                          onChanged: (value) {
                            debounce?.cancel();
                            debounce = Timer(
                              const Duration(milliseconds: 180),
                              () {
                                if (mounted) {
                                  setState(() {
                                    query = value.toLowerCase().trim();
                                    group = null;
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                    if (widget.updates != null)
                      UpdateNotice(
                        updates: widget.updates!,
                        beforeInstall: audio.saveSession,
                      ),
                    if (library.scanning || library.loading)
                      const LinearProgressIndicator(minHeight: 2),
                    if (library.message != null)
                      MaterialBanner(
                        content: Text(library.message!),
                        actions: [
                          TextButton(
                            onPressed: () {
                              library.message = null;
                              setState(() {});
                            },
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    Expanded(
                      child: switch (page) {
                        0 => libraryView(),
                        1 => trackList(
                          library.tracks
                              .where((t) => library.favorites.contains(t.id))
                              .toList(),
                          empty: 'Tus canciones favoritas aparecerán aquí.',
                        ),
                        2 => playlistView(),
                        3 => extensionView(),
                        _ => settingsView(),
                      },
                    ),
                    if (!keyboard)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          desktop ? 20 : 12,
                          8,
                          desktop ? 20 : 12,
                          8,
                        ),
                        child: PlayerPanel(audio: audio, library: library),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: desktop || keyboard
            ? null
            : NavigationBar(
                selectedIndex: page,
                onDestinationSelected: navigate,
                destinations: [
                  for (var i = 0; i < labels.length; i++)
                    NavigationDestination(
                      icon: Icon(icons[i]),
                      label: labels[i],
                    ),
                ],
              ),
      );
    },
  );

  Widget empty(String text, IconData icon, {Widget? action}) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (library.root == null && page == 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/branding/rp-music-variant-a.png',
                width: 96,
                height: 96,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (action != null)
            Padding(padding: const EdgeInsets.only(top: 20), child: action),
        ],
      ),
    ),
  );

  Widget sortControls() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.sort, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<TrackSort>(
            isExpanded: true,
            value: library.sort,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value != null) library.setSort(value);
            },
            items: [
              for (final value in TrackSort.values)
                DropdownMenuItem(value: value, child: Text(value.label)),
            ],
          ),
        ),
        IconButton(
          tooltip: library.ascending
              ? 'Ascendente · cambiar a descendente'
              : 'Descendente · cambiar a ascendente',
          onPressed: library.toggleSortDirection,
          icon: Icon(
            library.ascending ? Icons.arrow_upward : Icons.arrow_downward,
          ),
        ),
      ],
    ),
  );

  Widget libraryView() {
    if (library.programs?.owner('library') != null) {
      return ProgramLibraryView(library: library, audio: audio, query: query);
    }

    if (library.loading) {
      return empty('Abriendo tu biblioteca…', Icons.library_music_outlined);
    }
    if (library.root == null) {
      return EmptyLibrary(
        onChoose: library.choosing ? null : library.chooseRoot,
        busy: library.choosing,
      );
    }
    final filtered = library.tracks
        .where(
          (t) => '${t.title} ${t.artist} ${t.album} ${t.folder}'
              .toLowerCase()
              .contains(query),
        )
        .toList();
    return Column(
      children: [
        if (MediaQuery.viewInsetsOf(context).bottom == 0)
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Icon(
                Icons.folder_special_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Música local'),
              subtitle: Text(
                '${library.root} · ${library.tracks.length} pistas',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: 'Escanear',
                onPressed: library.scanning ? null : () => library.refresh(),
                icon: const Icon(Icons.sync),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  for (final (i, label) in [
                    'Canciones',
                    'Álbumes',
                    'Artistas',
                    'Carpetas',
                  ].indexed)
                    ChoiceChip(
                      label: Text(label),
                      selected: view == i,
                      onSelected: (_) => setState(() {
                        view = i;
                        group = null;
                      }),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (MediaQuery.viewInsetsOf(context).bottom == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${filtered.length} pistas locales${library.scanning ? ' · Metadatos ${library.scanProcessed}/${library.scanTotal}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (library.activeExtension?.randomAction == true)
                  TextButton.icon(
                    onPressed: filtered.isEmpty
                        ? null
                        : () => audio.select(
                            filtered,
                            Random().nextInt(filtered.length),
                          ),
                    icon: const Icon(Icons.casino_outlined),
                    label: const Text('Sorpréndeme'),
                  ),
              ],
            ),
          ),
        Expanded(
          child: view == 0 ? trackList(filtered) : groupedTracks(filtered),
        ),
      ],
    );
  }

  String groupKey(Track t) => switch (view) {
    1 => '${t.album}\n${t.artist}',
    2 => t.artist,
    _ => t.folder,
  };
  Widget groupedTracks(List<Track> tracks) {
    if (group != null) {
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: Text(group!.split('\n').first),
            onTap: () => setState(() => group = null),
          ),
          Expanded(
            child: trackList(
              tracks.where((t) => groupKey(t) == group).toList(),
            ),
          ),
        ],
      );
    }
    final groups = <String, List<Track>>{};
    for (final track in tracks) {
      groups.putIfAbsent(groupKey(track), () => []).add(track);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    if (keys.isEmpty) return empty('No hay resultados.', Icons.search_off);
    if (view == 1) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = max(2, ((constraints.maxWidth - 40) / 260).ceil());
          final tileWidth =
              (constraints.maxWidth - 40 - (columns - 1) * 12) / columns;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent:
                  tileWidth +
                  60 +
                  (MediaQuery.textScalerOf(context).scale(14) - 14) * 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final items = groups[key]!;
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => group = key),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Artwork(
                                id: items.first.id,
                                library: library,
                                size: double.infinity,
                              ),
                              Positioned(
                                right: 6,
                                bottom: 6,
                                child: IconButton.filled(
                                  tooltip: 'Reproducir álbum',
                                  onPressed: () => audio.select(items, 0),
                                  icon: const Icon(Icons.play_arrow),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          key.split('\n').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          items.first.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${items.length} pistas',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final items = groups[key]!;
        return ListTile(
          leading: Icon(
            view == 1
                ? Icons.album_outlined
                : view == 2
                ? Icons.person_outline
                : Icons.folder_outlined,
          ),
          title: Text(
            key.split('\n').first == '.'
                ? 'Carpeta raíz'
                : key.split('\n').first,
          ),
          subtitle: Text(
            '${items.length} canciones${view == 1 ? ' · ${items.first.artist}' : ''}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => setState(() => group = key),
        );
      },
    );
  }

  Widget trackList(
    List<Track> tracks, {
    String? playlist,
    String empty =
        'No hay canciones. Actualiza la carpeta o cambia tu búsqueda.',
  }) {
    if (tracks.isEmpty) return this.empty(empty, Icons.music_note_outlined);
    tracks = library.ordered(tracks);
    final cards = library.activeExtension?.layout == 'cards';
    final list = ListView.builder(
      itemExtent: cards ? 88 : 72,
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final tile = StreamBuilder(
          stream: audio.mediaItem,
          builder: (context, current) => ListTile(
            selected: current.data?.id == track.id,
            selectedTileColor: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.06),
            leading: Artwork(id: track.id, library: library),
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
            onTap: () => audio.select(tracks, index),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Favorito',
                  onPressed: () => library.toggleFavorite(track.id),
                  icon: Icon(
                    library.favorites.contains(track.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
                if (playlist != null && !library.automaticPlaylist(playlist))
                  IconButton(
                    tooltip: 'Quitar de la lista',
                    icon: const Icon(Icons.playlist_remove),
                    onPressed: () =>
                        library.removeFromPlaylist(playlist, track.id),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Opciones de canción',
                  onSelected: (value) {
                    if (value == 'delete') {
                      deleteTrack(track);
                    } else {
                      library.addToPlaylist(value.substring(5), track.id);
                    }
                  },
                  itemBuilder: (_) => [
                    for (final name in library.playlists.keys.where(
                      (name) => !library.automaticPlaylist(name),
                    ))
                      PopupMenuItem(
                        value: 'list:$name',
                        child: Text('Añadir a $name'),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      enabled: !library.scanning && !library.deleting,
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline),
                        title: Text('Eliminar del dispositivo'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        return cards
            ? Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: tile,
              )
            : tile;
      },
    );
    return Column(
      children: [
        sortControls(),
        Expanded(child: list),
      ],
    );
  }

  Widget playlistView() {
    if (group != null && library.playlists.containsKey(group)) {
      final name = group!;
      final missing = library.missingInPlaylist(name);
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: Text(group!),
            trailing: IconButton(
              tooltip: 'Eliminar lista',
              onPressed: () => deletePlaylist(name),
              icon: const Icon(Icons.delete_outline),
            ),
            onTap: () => setState(() => group = null),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                PlaylistCover(library: library, name: name, size: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (library.automaticPlaylist(name))
                        Text(
                          library.programs?.allowed(
                                    library.playlistMeta[name]!['owner']
                                        as String,
                                    'playlists.manage',
                                  ) ==
                                  true
                              ? 'Lista automática · activa'
                              : 'Lista automática · guardada e inactiva',
                        ),
                      TextButton.icon(
                        onPressed: () =>
                            choosePlaylistCover(context, library, name),
                        icon: const Icon(Icons.photo_outlined),
                        label: const Text('Cambiar carátula'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (missing > 0)
            ListTile(
              title: Text('$missing canciones no disponibles en esta carpeta'),
              subtitle: const Text(
                'Se conservan por si vuelves a la carpeta anterior.',
              ),
              trailing: TextButton(
                onPressed: library.scanning
                    ? null
                    : () => library.removeMissingFromPlaylist(name),
                child: const Text('Quitar'),
              ),
            ),
          Expanded(
            child: trackList(
              library.playlistTracks(name),
              playlist: name,
              empty: missing > 0
                  ? 'Las canciones de esta lista están fuera de la carpeta actual.'
                  : 'Añade canciones desde el menú de la biblioteca.',
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FilledButton.tonalIcon(
              onPressed: createPlaylist,
              icon: const Icon(Icons.add),
              label: const Text('Crear lista'),
            ),
          ),
        ),
        Expanded(
          child: library.playlists.isEmpty
              ? empty(
                  'Crea una lista para reunir tu música.',
                  Icons.queue_music,
                )
              : ListView(
                  children: [
                    for (final entry in library.playlists.entries)
                      ListTile(
                        leading: PlaylistCover(
                          library: library,
                          name: entry.key,
                        ),
                        title: Text(entry.key),
                        trailing: IconButton(
                          tooltip: 'Eliminar lista',
                          onPressed: () => deletePlaylist(entry.key),
                          icon: const Icon(Icons.delete_outline),
                        ),
                        subtitle: Text(
                          '${library.playlistTracks(entry.key).length} disponibles${library.missingInPlaylist(entry.key) > 0 ? ' · ${library.missingInPlaylist(entry.key)} no disponibles' : ''}',
                        ),
                        onTap: () => setState(() => group = entry.key),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> deletePlaylist(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lista'),
        content: Text(
          '¿Eliminar «$name»? Las canciones seguirán en tu dispositivo y en tu biblioteca.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => group = null);
    await library.deletePlaylist(name);
  }

  Future<void> createPlaylist() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _PlaylistDialog(),
    );
    if (name != null) await library.addPlaylist(name);
  }

  Widget extensionView() => ProgramManagerView(library: library, audio: audio);

  Future<void> deleteTrack(Track track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar del dispositivo?'),
        content: Text(
          'Se borrará el archivo de «${track.title}» y se quitará de favoritos y listas. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar archivo'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await library.deleteTrack(
      track,
      beforeDelete: () async {
        if (audio.mediaItem.value?.id == track.id) await audio.stop();
      },
    );
    if (success) await audio.removeTrack(track.id);
  }

  Future<void> showPlaybackDiagnostics() =>
      showDiagnostics(context, audio, widget.notifications);

  Widget settingsSection(String title, IconData icon, List<Widget> children) =>
      Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );

  Widget settingsView() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('A tu manera', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text('Tu biblioteca, tu sonido, tu espacio.'),
      const SizedBox(height: 24),
      settingsSection('Apariencia', Icons.palette_outlined, [
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Tema oscuro'),
          subtitle: const Text('Personalización básica, sin extensiones.'),
          value: library.dark,
          onChanged: library.setDark,
        ),
      ]),
      if (Platform.isWindows)
        SwitchListTile(
          title: const Text('Seguir reproduciendo al cerrar la ventana'),
          subtitle: const Text(
            'Se mantiene en la bandeja. Usa Salir en el icono para cerrar completamente.',
          ),
          value: library.closeToTray,
          onChanged: library.setCloseToTray,
        ),
      if (widget.notifications != null)
        settingsSection(
          'Reproducción en segundo plano',
          Icons.headphones_outlined,
          [
            ListenableBuilder(
              listenable: widget.notifications!,
              builder: (context, _) => Column(
                children: [
                  ListTile(
                    title: const Text('Notificaciones de reproducción'),
                    subtitle: Text(
                      widget.notifications!.enabled == true
                          ? 'Permiso concedido. Los controles dependen también del servicio multimedia.'
                          : 'Android no permite notificaciones. Revisa sus ajustes.',
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => widget.notifications!.request(),
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('Solicitar permiso'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.notifications!.openSettings,
                    icon: const Icon(Icons.notifications_outlined),
                    label: const Text('Abrir ajustes de notificaciones'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        widget.notifications!.openBatterySettings(),
                    icon: const Icon(Icons.battery_saver_outlined),
                    label: const Text('Revisar restricciones de batería'),
                  ),
                  OutlinedButton.icon(
                    onPressed: showPlaybackDiagnostics,
                    icon: const Icon(Icons.monitor_heart_outlined),
                    label: const Text('Diagnóstico multimedia'),
                  ),
                ],
              ),
            ),
          ],
        ),
      if (Platform.isAndroid)
        settingsSection('Pantalla de inicio', Icons.widgets_outlined, [
          const Text(
            'Carátula, anterior, reproducir/pausar y siguiente sin abrir la app.',
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () async {
              var offered = false;
              try {
                offered = await HomeWidget.pin();
              } catch (_) {}
              if (!mounted) return;
              if (!offered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Mantén pulsada la pantalla de inicio → Widgets → RP Music.',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.add_to_home_screen),
            label: const Text('Añadir widget'),
          ),
        ]),
      settingsSection('Biblioteca', Icons.library_music_outlined, [
        ListTile(
          leading: const Icon(Icons.folder_open),
          title: const Text('Carpeta de música'),
          subtitle: Text(library.root ?? 'Sin seleccionar'),
        ),
        FilledButton.tonalIcon(
          onPressed: library.scanning || library.choosing || library.deleting
              ? null
              : library.chooseRoot,
          icon: const Icon(Icons.folder_open),
          label: const Text('Cambiar carpeta'),
        ),
        if (Platform.isAndroid)
          OutlinedButton.icon(
            onPressed:
                library.root == null ||
                    library.choosing ||
                    library.scanning ||
                    library.deleting
                ? null
                : library.requestWriteAccess,
            icon: const Icon(Icons.folder_shared_outlined),
            label: const Text('Permitir eliminar archivos'),
          ),
        const ListTile(
          leading: Icon(Icons.offline_bolt_outlined),
          title: Text('Local y sin cuenta'),
          subtitle: Text('Tu biblioteca permanece en este dispositivo.'),
        ),
      ]),
      if (widget.updates != null)
        UpdateSettings(
          updates: widget.updates!,
          beforeInstall: audio.saveSession,
        ),
      const ListTile(
        title: Text('RP Music · $appVersion'),
        subtitle: Text('Base en reconstrucción · Android y Windows'),
      ),
    ],
  );
}

class _PlaylistDialog extends StatefulWidget {
  const _PlaylistDialog();
  @override
  State<_PlaylistDialog> createState() => _PlaylistDialogState();
}

class _PlaylistDialogState extends State<_PlaylistDialog> {
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nueva lista'),
    content: TextField(
      controller: text,
      autofocus: true,
      maxLength: 80,
      decoration: const InputDecoration(labelText: 'Nombre'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, text.text),
        child: const Text('Crear'),
      ),
    ],
  );
}

class PlayerPanel extends StatefulWidget {
  const PlayerPanel({
    super.key,
    required this.audio,
    required this.library,
    this.expanded = false,
    this.artworkFirst = true,
  });
  final bool expanded;
  final bool artworkFirst;
  final MusicHandler audio;
  final LibraryController library;
  @override
  State<PlayerPanel> createState() => _PlayerPanelState();
}

class _PlayerPanelState extends State<PlayerPanel> {
  MusicHandler get audio => widget.audio;
  LibraryController get library => widget.library;
  void openPlayer() => Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Ahora suena'),
          leading: IconButton(
            tooltip: 'Cerrar reproductor',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: library.programs?.owner('player') != null
                  ? ProgramPlayerView(audio: audio, library: library)
                  : PlayerPanel(audio: audio, library: library, expanded: true),
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: audio.mediaItem,
    builder: (context, item) {
      final track = item.data;
      final desktop = MediaQuery.sizeOf(context).width >= 850;
      if (!desktop && !widget.expanded) {
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder(
                stream: audio.player.positionStream,
                builder: (context, position) => StreamBuilder(
                  stream: audio.player.durationStream,
                  builder: (context, duration) {
                    final total = duration.data?.inMilliseconds ?? 0;
                    return LinearProgressIndicator(
                      minHeight: 3,
                      value: total > 0
                          ? ((position.data?.inMilliseconds ?? 0) / total)
                                .clamp(0.0, 1.0)
                          : 0,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: openPlayer,
                        child: Row(
                          children: [
                            Artwork(id: track?.id, library: library),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track?.title ?? 'Elige una canción',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    track?.artist ?? 'Tu biblioteca local',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Favorito',
                      onPressed:
                          track == null ||
                              track.id.startsWith('rpmusic-youtube:')
                          ? null
                          : () => library.toggleFavorite(track.id),
                      icon: Icon(
                        library.favorites.contains(track?.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                    ),
                    StreamBuilder(
                      stream: audio.player.playerStateStream,
                      builder: (context, state) => IconButton.filled(
                        tooltip: audio.player.playing ? 'Pausar' : 'Reproducir',
                        onPressed: track == null
                            ? null
                            : () => audio.player.playing
                                  ? audio.pause()
                                  : audio.play(),
                        icon: Icon(
                          audio.player.playing ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.expanded) ...[
                if (widget.artworkFirst)
                  AspectRatio(
                    aspectRatio: 1,
                    child: Artwork(
                      id: track?.id,
                      library: library,
                      size: double.infinity,
                    ),
                  ),
                const SizedBox(height: 24),
                ScrollingTitle(
                  text: track?.title ?? 'Elige una canción',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${track?.artist ?? ''} · ${track?.album ?? ''}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!widget.expanded)
                    Artwork(id: track?.id, library: library),
                  if (!widget.expanded) const SizedBox(width: 12),
                  if (!widget.expanded)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track?.title ?? 'Elige una canción',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            track?.artist ?? 'Tu música permanece contigo',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  if (!widget.expanded)
                    IconButton(
                      tooltip: 'Abrir reproductor',
                      onPressed: openPlayer,
                      icon: const Icon(Icons.open_in_full),
                    ),
                  IconButton(
                    tooltip: 'Anterior',
                    onPressed: track == null ? null : audio.skipToPrevious,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  StreamBuilder(
                    stream: audio.player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return IconButton.filled(
                        style: widget.expanded
                            ? IconButton.styleFrom(
                                minimumSize: const Size(72, 72),
                                iconSize: 36,
                              )
                            : null,
                        tooltip: playing ? 'Pausar' : 'Reproducir',
                        onPressed: track == null
                            ? null
                            : () => playing ? audio.pause() : audio.play(),
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Siguiente',
                    onPressed: track == null ? null : audio.skipToNext,
                    icon: const Icon(Icons.skip_next),
                  ),
                  if (widget.expanded)
                    IconButton(
                      tooltip: 'Detener',
                      onPressed: audio.stop,
                      icon: const Icon(Icons.stop_circle_outlined),
                    ),
                  IconButton(
                    tooltip: 'Ver cola',
                    onPressed: track == null
                        ? null
                        : () => showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => ListView.builder(
                              itemCount: audio.tracks.length,
                              itemBuilder: (context, i) => ListTile(
                                selected: i == audio.index,
                                title: Text(audio.tracks[i].title),
                                subtitle: Text(audio.tracks[i].artist),
                                onTap: () {
                                  audio.select(audio.tracks, i);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                    icon: const Icon(Icons.queue_music),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: VolumeControl(audio: audio, library: library),
                  ),
                  IconButton(
                    tooltip: 'Aleatorio',
                    isSelected: audio.shuffle,
                    onPressed: () =>
                        setState(() => audio.shuffle = !audio.shuffle),
                    icon: const Icon(Icons.shuffle),
                  ),
                  IconButton(
                    tooltip: 'Repetir canción',
                    isSelected: audio.repeat,
                    onPressed: () =>
                        setState(() => audio.repeat = !audio.repeat),
                    icon: const Icon(Icons.repeat_one),
                  ),
                ],
              ),
              StreamBuilder(
                stream: audio.player.positionStream,
                builder: (context, position) => StreamBuilder(
                  stream: audio.player.durationStream,
                  builder: (context, duration) {
                    final total = duration.data?.inMilliseconds ?? 0;
                    final current = (position.data?.inMilliseconds ?? 0).clamp(
                      0,
                      total,
                    );
                    String time(int ms) =>
                        '${ms ~/ 60000}:${(ms ~/ 1000 % 60).toString().padLeft(2, '0')}';
                    final slider = Slider(
                      value: current.toDouble(),
                      max: total > 0 ? total.toDouble() : 1,
                      onChanged: total <= 0
                          ? null
                          : (value) => audio.seek(
                              Duration(milliseconds: value.round()),
                            ),
                    );
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 28, child: slider),
                        if (widget.expanded)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(time(current)),
                                const Text('Audio local'),
                                Text(time(total)),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (widget.expanded && !widget.artworkFirst) ...[
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1,
                  child: Artwork(
                    id: track?.id,
                    library: library,
                    size: double.infinity,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class ProgramPlayerView extends StatefulWidget {
  const ProgramPlayerView({
    super.key,
    required this.audio,
    required this.library,
  });
  final MusicHandler audio;
  final LibraryController library;
  @override
  State<ProgramPlayerView> createState() => _ProgramPlayerViewState();
}

class _ProgramPlayerViewState extends State<ProgramPlayerView> {
  Future<Map<String, dynamic>?>? view;
  StreamSubscription? subscription;
  String? trackId;
  @override
  void initState() {
    super.initState();
    view = load();
    subscription = widget.audio.mediaItem.listen((item) {
      if (trackId == item?.id || !mounted) return;
      trackId = item?.id;
      setState(() {
        view = load();
      });
    });
  }

  Future<Map<String, dynamic>?> load() async {
    final manager = widget.library.programs!;
    for (var i = 0; i < 20 && manager.busy; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    final owner = manager.owner('player');
    if (owner == null) return null;
    final track = widget.audio.mediaItem.value;
    final result = await manager.invoke(owner.package.id, 'player', {
      'title': track?.title ?? '',
      'artist': track?.artist ?? '',
      'album': track?.album ?? '',
      'playing': widget.audio.player.playing,
    });
    if (result == null) return null;
    if (result['title'] is! String ||
        (result['title'] as String).length > 120 ||
        !['artworkFirst', 'controlsFirst'].contains(result['layout'])) {
      await manager.reject(owner.package.id, 'Diseño de reproductor inválido.');
      return null;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.library.programs!,
    builder: (context, _) => FutureBuilder<Map<String, dynamic>?>(
      future: view,
      builder: (context, snapshot) {
        final data = widget.library.programs!.owner('player') == null
            ? null
            : snapshot.data;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (snapshot.connectionState != ConnectionState.done)
              const LinearProgressIndicator(),
            if (data != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  data['title'] as String,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            PlayerPanel(
              audio: widget.audio,
              library: widget.library,
              expanded: true,
              artworkFirst: data?['layout'] != 'controlsFirst',
            ),
            TextButton(
              onPressed: () => widget.library.programs!.choose('player', null),
              child: const Text('Volver al reproductor base'),
            ),
          ],
        );
      },
    ),
  );
  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}

class Artwork extends StatefulWidget {
  const Artwork({
    super.key,
    required this.id,
    required this.library,
    this.size = 44,
  });
  final String? id;
  final double size;
  final LibraryController library;
  @override
  State<Artwork> createState() => _ArtworkState();
}

class _ArtworkState extends State<Artwork> {
  Future<Uint8List?>? image;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(Artwork old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) load();
  }

  void load() {
    image = widget.id == null || YoutubeMusicApi.identity(widget.id!) != null
        ? null
        : widget.library.files.artwork(widget.id!);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.size,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child:
          YoutubeMusicApi.identity(widget.id ?? '') != null &&
              widget.library.programs?.allowed(
                    YoutubeMusicApi.identity(widget.id!)![1],
                    'network.youtube',
                  ) ==
                  true
          ? Image.network(
              YoutubeMusicApi.artwork(YoutubeMusicApi.identity(widget.id!)![2])
                  .toString(),
              fit: BoxFit.cover,
              cacheWidth: widget.size > 100 ? 600 : 128,
              errorBuilder: (_, error, stack) =>
                  const Icon(Icons.album_outlined),
            )
          : FutureBuilder(
              future: image,
              builder: (context, snapshot) => snapshot.data == null
                  ? const ColoredBox(
                      color: Color(0xff272a32),
                      child: Icon(Icons.album_outlined),
                    )
                  : Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      cacheWidth: widget.size > 100 ? 600 : 128,
                      errorBuilder: (_, error, stack) =>
                          const Icon(Icons.album_outlined),
                    ),
            ),
    ),
  );
}
