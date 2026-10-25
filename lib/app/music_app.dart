import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../domain/track.dart';
import '../playback/music_handler.dart';
import 'library_controller.dart';
import 'volume_control.dart';
import '../platform/android_notifications.dart';

import 'dart:io';

class MusicApp extends StatelessWidget {
  const MusicApp({
    super.key,
    required this.library,
    required this.audio,
    this.notifications,
  });
  final LibraryController library;
  final MusicHandler audio;
  final AndroidNotifications? notifications;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: library,
    builder: (context, _) {
      final seed = Color(library.activeExtension?.accent ?? 0xffb7d995);
      return MaterialApp(
        title: 'RP Music',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seed),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: library.dark ? ThemeMode.dark : ThemeMode.light,
        home: MusicHome(
          library: library,
          audio: audio,
          notifications: notifications,
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
  });
  final LibraryController library;
  final MusicHandler audio;
  final AndroidNotifications? notifications;
  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> with WidgetsBindingObserver {
  int page = 0;
  int view = 0;
  String query = '';
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(audio.saveSession());
    if (state == AppLifecycleState.resumed) widget.notifications?.refresh();
  }

  void navigate(int value) => setState(() {
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
                  minExtendedWidth: 210,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      'RP MUSIC',
                      style: TextStyle(
                        letterSpacing: 4,
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
                          Expanded(
                            child: Text(
                              labels[page],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          if (page == 0)
                            IconButton(
                              onPressed:
                                  library.scanning || library.root == null
                                  ? null
                                  : () => library.refresh(),
                              tooltip: 'Actualizar biblioteca',
                              icon: const Icon(Icons.refresh),
                            ),
                          if (page == 0)
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
                    if (!keyboard) PlayerPanel(audio: audio, library: library),
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
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56),
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

  Widget libraryView() {
    if (library.loading) {
      return empty('Abriendo tu biblioteca…', Icons.library_music_outlined);
    }
    if (library.root == null) {
      return empty(
        'Tu música, a tu manera.\nElige una carpeta; incluiremos sus subcarpetas.',
        Icons.folder_open,
        action: FilledButton(
          onPressed: library.choosing ? null : library.chooseRoot,
          child: const Text('Seleccionar mi música'),
        ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: TextField(
            controller: search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar en tu música',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 180), () {
                if (mounted) {
                  setState(() {
                    query = value.toLowerCase().trim();
                    group = null;
                  });
                }
              });
            },
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
                    '${filtered.length} canciones${library.scanning ? ' · Metadatos ${library.scanProcessed}/${library.scanTotal}' : ''}',
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
    final cards = library.activeExtension?.layout == 'cards';
    return ListView.builder(
      itemExtent: cards ? 88 : 72,
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final tile = ListTile(
          leading: const CircleAvatar(child: Icon(Icons.music_note)),
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
              if (playlist != null)
                IconButton(
                  tooltip: 'Quitar de la lista',
                  icon: const Icon(Icons.playlist_remove),
                  onPressed: () =>
                      library.removeFromPlaylist(playlist, track.id),
                ),
              if (playlist == null)
                PopupMenuButton<String>(
                  tooltip: 'Añadir a una lista',
                  onSelected: (name) => library.addToPlaylist(name, track.id),
                  itemBuilder: (_) => [
                    for (final name in library.playlists.keys)
                      PopupMenuItem(value: name, child: Text('Añadir a $name')),
                  ],
                ),
            ],
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
            onTap: () => setState(() => group = null),
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
                        leading: const Icon(Icons.queue_music),
                        title: Text(entry.key),
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

  Future<void> createPlaylist() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _PlaylistDialog(),
    );
    if (name != null) await library.addPlaylist(name);
  }

  Widget extensionView() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Un reproductor que puedes transformar',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      const Text(
        'Prueba inicial: instala un manifiesto JSON para cambiar la biblioteca y añadir una acción. Las extensiones con código y conexiones a servicios están en desarrollo.',
      ),
      const SizedBox(height: 20),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.tonalIcon(
          onPressed: library.importExtension,
          icon: const Icon(Icons.file_open_outlined),
          label: const Text('Importar extensión'),
        ),
      ),
      const SizedBox(height: 16),
      ListTile(
        title: const Text('Interfaz base'),
        leading: const Icon(Icons.music_note_outlined),
        trailing: library.activeExtension == null
            ? const Icon(Icons.check)
            : null,
        onTap: () => library.activateExtension(null),
      ),
      for (final extension in library.extensions)
        Card(
          child: ListTile(
            title: Text(extension.name),
            subtitle: Text(
              '${extension.description}\nSin permisos adicionales',
            ),
            isThreeLine: true,
            leading: Icon(
              library.activeExtensionId == extension.id
                  ? Icons.check_circle
                  : Icons.extension_outlined,
            ),
            onTap: () => library.activateExtension(extension.id),
            trailing: IconButton(
              tooltip: 'Desinstalar',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => library.removeExtension(extension.id),
            ),
          ),
        ),
    ],
  );

  Widget settingsView() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      SwitchListTile(
        title: const Text('Tema oscuro'),
        subtitle: const Text('Personalización básica, sin extensiones.'),
        value: library.dark,
        onChanged: library.setDark,
      ),
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
        ListenableBuilder(
          listenable: widget.notifications!,
          builder: (context, _) => Column(
            children: [
              ListTile(
                title: const Text('Notificaciones de reproducción'),
                subtitle: Text(
                  widget.notifications!.enabled == true
                      ? 'Permitidas por Android'
                      : 'Permite las notificaciones para ver los controles.',
                ),
                trailing: TextButton(
                  onPressed: () => widget.notifications!.request(),
                  child: const Text('Solicitar'),
                ),
              ),
              TextButton(
                onPressed: widget.notifications!.openSettings,
                child: const Text('Abrir ajustes de notificaciones'),
              ),
            ],
          ),
        ),
      ListTile(
        leading: const Icon(Icons.folder_open),
        title: const Text('Carpeta de música'),
        subtitle: Text(library.root ?? 'Sin seleccionar'),
        onTap: library.scanning || library.choosing ? null : library.chooseRoot,
      ),
      const ListTile(
        leading: Icon(Icons.offline_bolt_outlined),
        title: Text('Local y sin cuenta'),
        subtitle: Text('Tu biblioteca permanece en este dispositivo.'),
      ),
      const ListTile(
        title: Text('RP Music · 0.2.2'),
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
  const PlayerPanel({super.key, required this.audio, required this.library});
  final MusicHandler audio;
  final LibraryController library;
  @override
  State<PlayerPanel> createState() => _PlayerPanelState();
}

class _PlayerPanelState extends State<PlayerPanel> {
  MusicHandler get audio => widget.audio;
  LibraryController get library => widget.library;
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: audio.mediaItem,
    builder: (context, item) {
      final track = item.data;
      return Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                    return SizedBox(
                      height: 28,
                      child: Slider(
                        value: current.toDouble(),
                        max: total > 0 ? total.toDouble() : 1,
                        onChanged: total <= 0
                            ? null
                            : (value) => audio.seek(
                                Duration(milliseconds: value.round()),
                              ),
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

class Artwork extends StatefulWidget {
  const Artwork({super.key, required this.id, required this.library});
  final String? id;
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
    image = widget.id == null ? null : widget.library.files.artwork(widget.id!);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 44,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: FutureBuilder(
        future: image,
        builder: (context, snapshot) => snapshot.data == null
            ? const ColoredBox(
                color: Color(0xff334039),
                child: Icon(Icons.album_outlined),
              )
            : Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                cacheWidth: 128,
                errorBuilder: (_, error, stack) =>
                    const Icon(Icons.album_outlined),
              ),
      ),
    ),
  );
}
