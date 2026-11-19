import '../data/replay_gain.dart';
import 'playback_queue.dart';
import '../artists/artist_portraits.dart';
import 'pulse_surface.dart';
import 'scrolling_title.dart';
import 'expanded_player.dart';
import 'album_detail_view.dart';
import 'track_swipe.dart';
import 'collection_header.dart';

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent, ScrollDirection;

import '../domain/track.dart';
import '../domain/track_sort.dart';
import 'playlist_cover.dart';
import '../platform/home_widget.dart';
import '../playback/music_handler.dart';
import 'library_controller.dart';
import 'volume_control.dart';
import 'music_theme.dart';
import '../themes/theme_library.dart';
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
    listenable: Listenable.merge([library, library.themes]),
    builder: (context, _) {
      final theme = library.themes.active;
      return MaterialApp(
        title: 'RP Music',
        debugShowCheckedModeBanner: false,
        theme: musicTheme(Brightness.light, null, appearance: theme),
        darkTheme: musicTheme(Brightness.dark, null, appearance: theme),
        themeMode: library.dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => ThemeBackdrop(child: child!),
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
  bool hideNavigation = false;
  int view = 0;
  bool sortPlaylistsByCount = false;
  bool playlistsAscending = true;
  String query = '';
  bool searchExpanded = false;
  final searchFocus = FocusNode();
  String? group;
  Timer? debounce;
  Timer? _navigationTimer;
  Timer? _libraryCountTimer;
  bool _showLibraryCount = false;
  bool _wasScanning = false;

  void _watchLibraryScan() {
    if (_wasScanning == library.scanning) return;
    _wasScanning = library.scanning;
    _libraryCountTimer?.cancel();
    setState(() => _showLibraryCount = true);
    if (!library.scanning) {
      _libraryCountTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showLibraryCount = false);
      });
    }
  }

  StreamSubscription<String>? errors;
  StreamSubscription? _coverWarmup;

  Future<void> warmCover() async {
    final id = audio.mediaItem.value?.id;
    if (id == null) return;
    final bytes = await library.artwork(id);
    if (!mounted || audio.mediaItem.value?.id != id || bytes == null) return;
    await precacheImage(
      ResizeImage.resizeIfNeeded(600, null, MemoryImage(bytes)),
      context,
      onError: (Object error, StackTrace? stack) {},
    );
  }

  final search = TextEditingController();
  LibraryController get library => widget.library;
  MusicHandler get audio => widget.audio;
  static const labels = [
    'Biblioteca',
    'Favoritos',
    'Listas',
    'Temas',
    'Ajustes',
  ];
  static const iconSlots = [
    'library',
    'favorites',
    'playlists',
    'themes',
    'settings',
  ];
  static const icons = [
    Icons.library_music_outlined,
    Icons.favorite_outline,
    Icons.queue_music,
    Icons.palette_outlined,
    Icons.settings_outlined,
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wasScanning = _showLibraryCount = library.scanning;
    library.addListener(_watchLibraryScan);
    _coverWarmup = audio.mediaItem.listen((_) => unawaited(warmCover()));
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
    library.removeListener(_watchLibraryScan);
    _navigationTimer?.cancel();
    _libraryCountTimer?.cancel();
    _coverWarmup?.cancel();
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
    if (state == AppLifecycleState.resumed) {
      widget.notifications?.refresh();
    }
  }

  void navigate(int value) => setState(() {
    _navigationTimer?.cancel();
    searchFocus.unfocus();
    hideNavigation = false;
    page = value;
    group = null;
  });

  void openPlayingAlbum(Track track) {
    _navigationTimer?.cancel();
    debounce?.cancel();
    search.clear();
    searchFocus.unfocus();
    setState(() {
      page = 0;
      view = 1;
      group = track.albumKey;
      query = '';
      searchExpanded = false;
      hideNavigation = false;
    });
  }

  void selectGroup(String? value) => setState(() {
    _navigationTimer?.cancel();
    group = value;
    hideNavigation = false;
  });

  bool onContentScroll(UserScrollNotification event) {
    if (event.depth == 0 &&
        event.metrics.axis == Axis.vertical &&
        event.direction != ScrollDirection.idle) {
      final hide =
          event.direction == ScrollDirection.reverse &&
          event.metrics.maxScrollExtent > event.metrics.minScrollExtent;
      _navigationTimer?.cancel();
      if (hide != hideNavigation) setState(() => hideNavigation = hide);
      if (!hide &&
          event.metrics.maxScrollExtent > event.metrics.minScrollExtent) {
        _navigationTimer = Timer(const Duration(seconds: 5), () {
          if (mounted && page < 3 && !searchFocus.hasFocus) {
            setState(() => hideNavigation = true);
          }
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final desktop = size.maxWidth >= 850;
      final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
      final scaffold = Scaffold(
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
                        icon: ThemeIcon(iconSlots[i], icons[i]),
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
                    ClipRect(
                      child: AnimatedAlign(
                        key: page == 2
                            ? const ValueKey('playlist-tools')
                            : null,
                        alignment: Alignment.topCenter,
                        heightFactor:
                            page == 2 &&
                                (group != null || (!desktop && hideNavigation))
                            ? 0
                            : 1,
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            desktop ? 24 : 12,
                            desktop ? 20 : 4,
                            desktop ? 16 : 4,
                            4,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Row(
                              children: [
                                if (page == 0) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      desktop ? 10 : 6,
                                    ),
                                    child: ThemeBrand(size: desktop ? 36 : 24),
                                  ),
                                  SizedBox(width: desktop ? 10 : 6),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (page == 0 &&
                                          group == null &&
                                          library.root != null)
                                        libraryViewSelector()
                                      else
                                        Text(
                                          page == 0 &&
                                                  view == 1 &&
                                                  group != null
                                              ? 'Detalle de álbum'
                                              : page == 0
                                              ? 'RP Music'
                                              : labels[page],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: headerTextStyle,
                                        ),
                                      if (page == 0 && _showLibraryCount)
                                        Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          'Biblioteca · ${library.tracks.length} pistas${library.scanning ? ' · Metadatos ${library.scanProcessed}/${library.scanTotal}' : ''}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                                if (page <= 1)
                                  IconButton(
                                    tooltip: searchExpanded
                                        ? 'Cerrar búsqueda'
                                        : 'Buscar',
                                    icon: searchExpanded
                                        ? const Icon(Icons.close)
                                        : const ThemeIcon(
                                            'search',
                                            Icons.search,
                                          ),
                                    onPressed: () {
                                      setState(() {
                                        _navigationTimer?.cancel();
                                        hideNavigation = false;
                                        searchExpanded = !searchExpanded;
                                        if (!searchExpanded) {
                                          debounce?.cancel();
                                          search.clear();
                                          query = '';
                                        }
                                      });
                                      if (searchExpanded) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (mounted) {
                                                searchFocus.requestFocus();
                                              }
                                            });
                                      } else {
                                        searchFocus.unfocus();
                                      }
                                    },
                                  ),
                                if ((page == 0 &&
                                        library.root != null &&
                                        (view == 0 ||
                                            (view != 1 && group != null))) ||
                                    page == 1)
                                  trackOrderingControls(),
                                if (page == 2 && group == null) ...[
                                  playlistOrderingControls(),
                                  IconButton(
                                    tooltip: 'Nueva lista',
                                    onPressed: createPlaylist,
                                    icon: const ThemeIcon('add', Icons.add),
                                  ),
                                ],
                                if (page == 0)
                                  IconButton(
                                    onPressed:
                                        library.scanning || library.root == null
                                        ? null
                                        : () => library.refresh(),
                                    tooltip: 'Actualizar biblioteca',
                                    icon: const ThemeIcon(
                                      'refresh',
                                      Icons.refresh,
                                    ),
                                  ),
                                if (page == 0 && desktop)
                                  FilledButton.tonalIcon(
                                    onPressed:
                                        library.scanning || library.choosing
                                        ? null
                                        : library.chooseRoot,
                                    icon: const ThemeIcon(
                                      'folder',
                                      Icons.folder_open,
                                    ),
                                    label: Text(
                                      desktop ? 'Elegir carpeta' : 'Carpeta',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      alignment: Alignment.topCenter,
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: page <= 1 && searchExpanded
                          ? Padding(
                              key: const ValueKey('library-search'),
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                              child: TextField(
                                key: const ValueKey('library-search-field'),
                                controller: search,
                                focusNode: searchFocus,
                                decoration: const InputDecoration(
                                  prefixIcon: ThemeIcon('search', Icons.search),
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
                                          if (page == 0 && view != 1) {
                                            group = null;
                                          }
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
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
                      child: NotificationListener<UserScrollNotification>(
                        onNotification: desktop || page >= 3
                            ? null
                            : onContentScroll,
                        child: switch (page) {
                          0 => libraryView(),
                          1 => trackList(
                            library.tracks
                                .where(
                                  (t) =>
                                      library.favorites.contains(t.id) &&
                                      matchesSearch(t),
                                )
                                .toList(),
                            empty: 'Tus canciones favoritas aparecerán aquí.',
                          ),
                          2 => playlistView(),
                          3 => ThemeLibraryView(themes: library.themes),
                          _ => settingsView(),
                        },
                      ),
                    ),
                    if (!keyboard)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          desktop ? 20 : 12,
                          8,
                          desktop ? 20 : 12,
                          8,
                        ),
                        child: PlayerPanel(
                          audio: audio,
                          library: library,
                          onOpenAlbum: openPlayingAlbum,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: desktop || keyboard
            ? null
            : ClipRect(
                child: AnimatedAlign(
                  key: const ValueKey('library-bottom-navigation'),
                  alignment: Alignment.topCenter,
                  heightFactor: hideNavigation ? 0 : 1,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 230),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: hideNavigation,
                    child: ExcludeSemantics(
                      excluding: hideNavigation,
                      child: NavigationBar(
                        labelBehavior:
                            NavigationDestinationLabelBehavior.alwaysShow,
                        selectedIndex: page,
                        onDestinationSelected: navigate,
                        destinations: [
                          for (var i = 0; i < labels.length; i++)
                            NavigationDestination(
                              icon: ThemeIcon(iconSlots[i], icons[i]),
                              label: labels[i],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      );
      return PopScope(
        canPop: group == null,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (group != null) selectGroup(null);
        },
        child: SafeArea(top: false, bottom: !desktop, child: scaffold),
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

  static const libraryViews = ['Canciones', 'Álbumes', 'Artistas', 'Carpetas'];

  TextStyle? get headerTextStyle => MediaQuery.sizeOf(context).width >= 850
      ? Theme.of(context).textTheme.headlineMedium
      : Theme.of(context).textTheme.titleLarge;

  static const viewIcons = [
    Icons.music_note_rounded,
    Icons.album_outlined,
    Icons.person_outline_rounded,
    Icons.folder_outlined,
  ];

  Widget libraryViewSelector() => PopupMenuButton<int>(
    tooltip: 'Vista de biblioteca',
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    onSelected: (value) => setState(() {
      _navigationTimer?.cancel();
      hideNavigation = false;
      view = value;
      group = null;
    }),
    itemBuilder: (_) => [
      for (final (index, name) in libraryViews.indexed)
        PopupMenuItem(
          value: index,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _menuOption(name, viewIcons[index], selected: index == view),
        ),
    ],
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              libraryViews[view],
              style: headerTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
        ],
      ),
    ),
  );

  Widget _menuOption(String label, IconData icon, {bool selected = false}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: selected ? colors.primaryContainer : colors.surfaceContainer,
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: selected ? colors.onPrimaryContainer : colors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? colors.onPrimaryContainer : colors.onSurface,
              ),
            ),
          ),
          if (selected)
            Icon(
              Icons.check_rounded,
              size: 18,
              color: colors.onPrimaryContainer,
            ),
        ],
      ),
    );
  }

  Widget orderingControls<T>({
    required List<(T, String, IconData)> options,
    required T selected,
    required ValueChanged<T> onSelected,
    required bool ascending,
    required VoidCallback toggleDirection,
  }) => PopupMenuButton<VoidCallback>(
    tooltip: 'Ordenar',
    icon: const ThemeIcon('filter', Icons.filter_list),
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    constraints: const BoxConstraints(
      minWidth: 196,
      maxWidth: 228,
      maxHeight: 322,
    ),
    onSelected: (action) => action(),
    itemBuilder: (_) => [
      PopupMenuItem(
        value: toggleDirection,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: _menuOption(
          ascending ? 'Descendente' : 'Ascendente',
          ascending ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
        ),
      ),
      const PopupMenuDivider(),
      for (final (value, label, icon) in options)
        PopupMenuItem(
          value: () => onSelected(value),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _menuOption(label, icon, selected: value == selected),
        ),
    ],
  );

  Widget trackOrderingControls() => orderingControls(
    selected: library.sort,
    options: [
      for (final value in TrackSort.values)
        (
          value,
          value.label,
          switch (value) {
            TrackSort.title => Icons.sort_by_alpha,
            TrackSort.artist => Icons.person_outline,
            TrackSort.album => Icons.album_outlined,
            TrackSort.duration => Icons.timer_outlined,
            TrackSort.modified => Icons.calendar_today_outlined,
            TrackSort.size => Icons.data_usage_outlined,
            TrackSort.filename => Icons.insert_drive_file_outlined,
          },
        ),
    ],
    onSelected: library.setSort,
    ascending: library.ascending,
    toggleDirection: library.toggleSortDirection,
  );

  bool matchesSearch(Track track) =>
      '${track.title} ${track.artist} ${track.album} ${track.folder}'
          .toLowerCase()
          .contains(query);

  Widget libraryView() {
    if (library.loading) {
      return empty('Abriendo tu biblioteca…', Icons.library_music_outlined);
    }
    if (library.root == null) {
      return EmptyLibrary(
        onChoose: library.choosing ? null : library.chooseRoot,
        busy: library.choosing,
      );
    }
    final filtered = library.tracks.where(matchesSearch).toList();
    if (view == 1 && group != null) {
      return AlbumDetailView(
        key: ValueKey(group),
        tracks: library.tracks.where((t) => groupKey(t) == group).toList(),
        query: query,
        audio: audio,
        library: library,
        onBack: () => selectGroup(null),
        onTrackContext: (track, _) => openTrackMenu(track, favorite: true),
        onEnqueue: (tracks, next) => enqueueTracks(tracks, next: next),
        onSave: () => addAlbumToPlaylist(
          filtered.where((t) => groupKey(t) == group).toList(),
        ),
      );
    }
    return view == 0 ? trackList(filtered) : groupedTracks(filtered);
  }

  Future<void> addAlbumToPlaylist(List<Track> album) async {
    final ids = album.map((t) => t.id).toList();
    final names =
        library.playlists.keys
            .where((name) => !library.automaticPlaylist(name))
            .toList()
          ..sort();
    (String?, bool)? target;
    if (names.isNotEmpty) {
      target = await showModalBottomSheet<(String?, bool)>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.65,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Añadir álbum a una lista',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final name in names)
                        ListTile(
                          leading: const ThemeIcon(
                            'playlistAdd',
                            Icons.playlist_add,
                          ),
                          title: Text(name),
                          onTap: () => Navigator.pop(context, (name, false)),
                        ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const ThemeIcon('add', Icons.add),
                  title: const Text('Crear nueva lista'),
                  onTap: () => Navigator.pop(context, (null, true)),
                ),
              ],
            ),
          ),
        ),
      );
      if (target == null || !mounted) return;
    } else {
      target = (null, true);
    }
    try {
      if (target.$2) {
        final name = await showDialog<String>(
          context: context,
          builder: (_) => const _PlaylistDialog(),
        );
        if (name == null) return;
        await library.createPlaylistWithTracks(name, ids);
      } else {
        await library.addTracksToPlaylist(target.$1!, ids);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Álbum añadido a la lista')),
        );
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }

  void enqueueTracks(List<Track> tracks, {required bool next}) {
    final undo = audio.enqueue(tracks, next: next);
    if (undo == null) return;
    showQueueUndo(
      context,
      next ? 'Añadido a continuación' : 'Añadido a la cola',
      undo,
    );
  }

  Future<void> openTrackMenu(
    Track track, {
    bool favorite = false,
    String? playlist,
  }) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Row(
          children: [
            Artwork(id: track.id, library: library),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title),
                  Text(
                    track.artist,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in trackOptions(track, favorite, playlist))
              ListTile(
                enabled: option.enabled,
                title: option.child,
                onTap: option.enabled
                    ? () => Navigator.pop(context, option.value)
                    : null,
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'remove-from-playlist' && playlist != null) {
      final undo = library.detachPlaylistTrack(playlist, track.id);
      if (undo != null) showQueueUndo(context, 'Quitada de la lista', undo);
    } else {
      runTrackAction(track, action);
    }
  }

  void runTrackAction(Track track, String value) {
    switch (value) {
      case 'queue-next':
        enqueueTracks([track], next: true);
      case 'queue-end':
        enqueueTracks([track], next: false);
      case 'favorite':
        library.toggleFavorite(track.id);
      case 'playlist':
        addSongToPlaylists(track);
      case 'details':
        showSongDetails(context, track);
      case 'delete':
        deleteTrack(track);
    }
  }

  List<PopupMenuItem<String>> trackOptions(
    Track track,
    bool favorite,
    String? playlist,
  ) => [
    if (playlist != null && !library.automaticPlaylist(playlist))
      const PopupMenuItem(
        value: 'remove-from-playlist',
        child: Text('Quitar de esta lista'),
      ),
    const PopupMenuItem(
      value: 'queue-next',
      child: Text('Reproducir a continuación'),
    ),
    const PopupMenuItem(
      value: 'queue-end',
      child: Text('Añadir al final de la cola'),
    ),

    if (favorite && track.sourceId == null)
      PopupMenuItem(
        value: 'favorite',
        child: Text(
          library.favorites.contains(track.id)
              ? 'Quitar de favoritos'
              : 'Añadir a favoritos',
        ),
      ),
    const PopupMenuItem(value: 'playlist', child: Text('Añadir a una lista')),
    const PopupMenuItem(
      value: 'details',
      child: Text('Detalles de la canción'),
    ),
    if (track.sourceId == null)
      PopupMenuItem(
        value: 'delete',
        enabled: !library.scanning && !library.deleting,
        child: const Text('Eliminar del dispositivo'),
      ),
  ];

  Future<void> addSongToPlaylists(Track track) async {
    final names = library.playlists.keys
        .where((name) => !library.automaticPlaylist(name))
        .toList();
    final selected = <String>{};
    String? newName;
    String? validation;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('Añadir a una lista'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final name in names)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(name),
                  value:
                      selected.contains(name) ||
                      (library.playlists[name]?.contains(track.id) ?? false),
                  onChanged:
                      (library.playlists[name]?.contains(track.id) ?? false)
                      ? null
                      : (checked) => update(() {
                          if (checked == true) {
                            selected.add(name);
                          } else {
                            selected.remove(name);
                          }
                        }),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const ThemeIcon('add', Icons.add),
                title: Text(newName ?? 'Crear lista'),
                onTap: () async {
                  final name = await showDialog<String>(
                    context: context,
                    builder: (_) => const _PlaylistDialog(),
                  );
                  if (!context.mounted || name == null) return;
                  final clean = name.trim();
                  update(() {
                    if (clean.isEmpty ||
                        clean.length > 80 ||
                        library.playlists.containsKey(clean)) {
                      validation = 'Elige un nombre nuevo para la lista.';
                    } else {
                      newName = clean;
                      validation = null;
                    }
                  });
                },
              ),
              if (validation != null) Text(validation!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: selected.isEmpty && newName == null
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Añadir'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await library.addSongToPlaylists(track.id, selected, newName: newName);
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }

  String groupKey(Track t) => switch (view) {
    1 => t.albumKey,
    2 => t.artist,
    _ => t.folder,
  };
  Widget groupedTracks(List<Track> tracks) {
    if (group != null) {
      final grouped = tracks
          .where(
            (track) => view == 2
                ? track.artists.any(
                    (name) => Track.artistKey(name) == Track.artistKey(group!),
                  )
                : groupKey(track) == group,
          )
          .toList();
      return Column(
        children: [
          ListTile(
            leading: const ThemeIcon('back', Icons.arrow_back),
            title: Text(group!.split('\n').first),
            onTap: () => selectGroup(null),
            trailing: PopupMenuButton<bool>(
              tooltip: 'Opciones de cola de la colección',
              enabled: grouped.isNotEmpty,
              onSelected: (next) =>
                  enqueueTracks(library.ordered(grouped), next: next),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: true,
                  child: Text('Reproducir a continuación'),
                ),
                PopupMenuItem(
                  value: false,
                  child: Text('Añadir al final de la cola'),
                ),
              ],
            ),
          ),
          Expanded(child: trackList(grouped)),
        ],
      );
    }
    final groups = <String, List<Track>>{};
    final artistNames = <String, String>{};
    for (final track in tracks) {
      for (final name in view == 2 ? track.artists : [groupKey(track)]) {
        final key = view == 2
            ? artistNames.putIfAbsent(Track.artistKey(name), () => name)
            : name;
        groups.putIfAbsent(key, () => []).add(track);
      }
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
              return PulseSurface(
                index: index,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => setState(() {
                      group = key;
                      hideNavigation = false;
                      debounce?.cancel();
                      search.clear();
                      query = '';
                      searchExpanded = false;
                      searchFocus.unfocus();
                    }),
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
                                    icon: const ThemeIcon(
                                      'play',
                                      Icons.play_arrow,
                                    ),
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
          leading: view == 2 && library.artistPhotosEnabled
              ? ArtistPhoto(
                  artist: key,
                  portraits: library.portraits,
                  trackTitle: items.isEmpty ? null : items.first.title,
                )
              : ThemeIcon(
                  view == 2
                      ? 'artist'
                      : view == 1
                      ? 'album'
                      : 'folder',
                  view == 2
                      ? Icons.person_outline
                      : view == 1
                      ? Icons.album_outlined
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
          onTap: () => selectGroup(key),
        );
      },
    );
  }

  Widget trackList(
    List<Track> tracks, {
    String? playlist,
    Widget? header,
    String empty =
        'No hay canciones. Actualiza la carpeta o cambia tu búsqueda.',
  }) {
    if (tracks.isEmpty) {
      return header == null
          ? this.empty(empty, Icons.music_note_outlined)
          : ListView(
              children: [
                header,
                Padding(padding: const EdgeInsets.all(24), child: Text(empty)),
              ],
            );
    }
    tracks = library.ordered(tracks);
    final list = ListView.builder(
      scrollCacheExtent: const ScrollCacheExtent.pixels(480),
      itemExtent: header == null ? 72 : null,
      itemCount: tracks.length + (header == null ? 0 : 1),
      itemBuilder: (context, index) {
        if (header != null) {
          if (index == 0) return header;
          index--;
        }
        final track = tracks[index];
        final tile = StreamBuilder(
          stream: audio.mediaItem,
          initialData: audio.mediaItem.value,
          builder: (context, current) => ListTile(
            selected: current.data?.id == track.id,
            selectedTileColor: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.06),
            leading: Artwork(
              id: track.id,
              library: library,
              modifiedMs: track.modifiedMs,
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
            onTap: () => audio.select(tracks, index),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Favorito',
                  onPressed: () => library.toggleFavorite(track.id),
                  icon: ThemeFavoriteIcon(
                    selected: library.favorites.contains(track.id),
                  ),
                ),
              ],
            ),
          ),
        );
        return Material(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: TrackContextRegion(
            open: (_) => openTrackMenu(track, playlist: playlist),
            child: tile,
          ),
        );
      },
    );
    return list;
  }

  Widget playlistOrderingControls() => orderingControls(
    selected: sortPlaylistsByCount,
    options: const [
      (false, 'Nombre', Icons.sort_by_alpha),
      (true, 'Cantidad de canciones', Icons.queue_music),
    ],
    onSelected: (value) => setState(() => sortPlaylistsByCount = value),
    ascending: playlistsAscending,
    toggleDirection: () =>
        setState(() => playlistsAscending = !playlistsAscending),
  );

  Widget playlistView() {
    if (group != null && library.playlists.containsKey(group)) {
      final name = group!;
      final missing = library.missingInPlaylist(name);
      final tracks = library.playlistTracks(name);
      final minutes =
          tracks.fold<int>(0, (sum, t) => sum + t.durationMs) ~/ 60000;
      return Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            minLeadingWidth: 24,
            horizontalTitleGap: 8,
            leading: const ThemeIcon('back', Icons.arrow_back),
            title: Text(group!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                trackOrderingControls(),
                PopupMenuButton<String>(
                  tooltip: 'Opciones de la lista',
                  icon: const ThemeIcon('more', Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (action) => runPlaylistAction(name, action),
                  itemBuilder: (_) => [
                    for (final (id, label) in playlistActions)
                      PopupMenuItem(
                        value: id,
                        enabled: !id.startsWith('queue') || tracks.isNotEmpty,
                        child: Text(label),
                      ),
                  ],
                ),
              ],
            ),
            onTap: () => selectGroup(null),
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
              tracks,
              playlist: name,
              header: CollectionHeader(
                title: name,
                label: library.automaticPlaylist(name)
                    ? 'Lista automática guardada'
                    : 'LISTA LOCAL',
                description:
                    '${tracks.length} canciones · $minutes min${missing > 0 ? ' · $missing no disponibles' : ''}',
                artwork: (size) =>
                    PlaylistCover(library: library, name: name, size: size),
                equalActions: true,
                actions: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onPressed: tracks.isEmpty
                        ? null
                        : () {
                            audio.shuffle = false;
                            audio.select(library.ordered(tracks), 0);
                          },
                    icon: const ThemeIcon('play', Icons.play_arrow),
                    label: const Text('Reproducir'),
                  ),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      if (tracks.isEmpty) return;
                      audio.shuffle = true;
                      audio.select(
                        library.ordered(tracks),
                        Random().nextInt(tracks.length),
                      );
                    },
                    icon: const ThemeIcon('shuffle', Icons.shuffle),
                    label: const Text('Aleatorio'),
                  ),
                ],
              ),
              empty: missing > 0
                  ? 'Las canciones de esta lista están fuera de la carpeta actual.'
                  : 'Añade canciones desde el menú de la biblioteca.',
            ),
          ),
        ],
      );
    }
    final names = library.playlists.keys.toList()
      ..sort((a, b) {
        final countOrder = sortPlaylistsByCount
            ? library.playlists[a]!.length.compareTo(
                library.playlists[b]!.length,
              )
            : 0;
        final order = countOrder != 0
            ? countOrder
            : a.toLowerCase().compareTo(b.toLowerCase());
        return playlistsAscending ? order : -order;
      });
    return Column(
      children: [
        Expanded(
          child: names.isEmpty
              ? empty(
                  'Crea una lista para reunir tu música.',
                  Icons.queue_music,
                )
              : library.playlistGrid
              ? GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: names.length,
                  itemBuilder: (_, index) => playlistCard(names[index]),
                )
              : ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (_, index) {
                    final name = names[index];
                    final missing = library.missingInPlaylist(name);
                    return TrackContextRegion(
                      open: (_) => openPlaylistMenu(name),
                      child: ListTile(
                        leading: PlaylistCover(library: library, name: name),
                        title: Text(name),

                        subtitle: Text(
                          '${library.playlistTracks(name).length} disponibles'
                          '${missing > 0 ? ' · $missing no disponibles' : ''}',
                        ),
                        onTap: () => selectGroup(name),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  static const playlistActions = [
    ('queue-end', 'Añadir al final de la cola'),
    ('queue-next', 'Reproducir a continuación'),
    ('cover', 'Cambiar carátula'),
    ('delete', 'Eliminar lista'),
  ];

  Future<void> openPlaylistMenu(String name) async {
    final tracks = library.playlistTracks(name);
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Row(
          children: [
            PlaylistCover(library: library, name: name),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (id, label) in playlistActions)
              ListTile(
                title: Text(label),
                onTap: id.startsWith('queue') && tracks.isEmpty
                    ? null
                    : () => Navigator.pop(context, id),
              ),
          ],
        ),
      ),
    );
    if (mounted && action != null) await runPlaylistAction(name, action);
  }

  Future<void> runPlaylistAction(String name, String action) async {
    switch (action) {
      case 'queue-next':
      case 'queue-end':
        enqueueTracks(
          library.ordered(library.playlistTracks(name)),
          next: action == 'queue-next',
        );
      case 'cover':
        await choosePlaylistCover(context, library, name);
      case 'delete':
        await deletePlaylist(name);
    }
  }

  Widget playlistCard(String name) => TrackContextRegion(
    open: (_) => openPlaylistMenu(name),
    child: Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => selectGroup(name),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (_, bounds) => Center(
                  child: PlaylistCover(
                    library: library,
                    name: name,
                    size: bounds.maxHeight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

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
    selectGroup(null);
    await library.deletePlaylist(name);
  }

  Future<void> createPlaylist() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _PlaylistDialog(),
    );
    if (name != null) await library.addPlaylist(name);
  }

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
          key: const ValueKey('artist-photo-consent'),
          title: const Text('Fotos de artistas'),
          subtitle: const Text(
            'Al activar, se consultan el nombre y una canción en Deezer; Wikimedia sirve de respaldo por nombre. Las fotos se guardan en este dispositivo.',
          ),
          value: library.artistPhotosEnabled,
          onChanged: library.setArtistPhotosEnabled,
        ),
        ListTile(
          title: const Text('Vista de listas'),
          trailing: DropdownButton<bool>(
            value: library.playlistGrid,
            onChanged: (value) {
              if (value != null) library.setPlaylistGrid(value);
            },
            items: const [
              DropdownMenuItem(value: false, child: Text('Lista')),
              DropdownMenuItem(value: true, child: Text('Tarjetas')),
            ],
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Tema oscuro'),

          value: library.dark,
          onChanged: library.setDark,
        ),
      ]),
      settingsSection('Reproducción', Icons.headphones_outlined, [
        SwitchListTile(
          title: const Text('Reproducción sin pausas'),
          subtitle: const Text('Se aplica en transiciones sin fundido.'),
          value: audio.gapless,
          onChanged: (value) =>
              setState(() => unawaited(audio.setGapless(value))),
        ),
        ListTile(
          title: const Text('Normalización de volumen'),
          subtitle: const Text('ReplayGain'),
          trailing: DropdownButton<ReplayGainMode>(
            value: audio.replayGainMode,
            items: const [
              DropdownMenuItem(
                value: ReplayGainMode.off,
                child: Text('Desactivada'),
              ),
              DropdownMenuItem(
                value: ReplayGainMode.track,
                child: Text('Por canción'),
              ),
              DropdownMenuItem(
                value: ReplayGainMode.album,
                child: Text('Por álbum'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => unawaited(audio.setReplayGain(value)));
              }
            },
          ),
        ),
        SwitchListTile(
          title: const Text('Fundido entre canciones'),
          subtitle: const Text(
            'Mezcla las pistas cuando avanzan automáticamente.',
          ),
          value: audio.crossfadeSeconds > 0,
          onChanged: (enabled) {
            setState(() => unawaited(audio.setCrossfade(enabled: enabled)));
          },
        ),
        if (audio.crossfadeSeconds > 0)
          ListTile(
            title: Text('Duración: ${audio.crossfadeLength} s'),
            subtitle: Slider(
              min: 1,
              max: 12,
              divisions: 11,
              value: audio.crossfadeLength.toDouble(),
              label: '${audio.crossfadeLength} s',
              onChanged: (value) {
                setState(
                  () => unawaited(
                    audio.setCrossfade(enabled: true, seconds: value.round()),
                  ),
                );
              },
            ),
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
              builder: (context, _) => LayoutBuilder(
                builder: (context, bounds) {
                  var buttonHeight = 48.0;
                  for (final label in [
                    'Solicitar permiso',
                    'Abrir ajustes de notificaciones',
                    'Revisar restricciones de batería',
                    'Diagnóstico multimedia',
                  ]) {
                    final painter = TextPainter(
                      text: TextSpan(
                        text: label,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      textDirection: Directionality.of(context),
                      textScaler: MediaQuery.textScalerOf(context),
                    )..layout(maxWidth: max(1, bounds.maxWidth - 80));
                    buttonHeight = max(buttonHeight, painter.height + 24);
                    painter.dispose();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        title: const Text('Notificaciones de reproducción'),
                        subtitle: Text(
                          widget.notifications!.enabled == true
                              ? 'Permiso concedido. Los controles dependen también del servicio multimedia.'
                              : 'Android no permite notificaciones. Revisa sus ajustes.',
                        ),
                      ),
                      SizedBox(
                        height: buttonHeight,
                        child: FilledButton.tonalIcon(
                          onPressed: () => widget.notifications!.request(),
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: const Text('Solicitar permiso'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: buttonHeight,
                        child: OutlinedButton.icon(
                          onPressed: widget.notifications!.openSettings,
                          icon: const Icon(Icons.notifications_outlined),
                          label: const Text('Abrir ajustes de notificaciones'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: buttonHeight,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              widget.notifications!.openBatterySettings(),
                          icon: const Icon(Icons.battery_saver_outlined),
                          label: const Text('Revisar restricciones de batería'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: buttonHeight,
                        child: OutlinedButton.icon(
                          onPressed: showPlaybackDiagnostics,
                          icon: const Icon(Icons.monitor_heart_outlined),
                          label: const Text('Diagnóstico multimedia'),
                        ),
                      ),
                    ],
                  );
                },
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
          leading: const ThemeIcon('folder', Icons.folder_open),
          title: const Text('Carpeta de música'),
          subtitle: Text(library.root ?? 'Sin seleccionar'),
        ),
        FilledButton.tonalIcon(
          onPressed: library.scanning || library.choosing || library.deleting
              ? null
              : library.chooseRoot,
          icon: const ThemeIcon('folder', Icons.folder_open),
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
    this.onOpenAlbum,
    this.artworkFirst = true,
  });
  final ValueChanged<Track>? onOpenAlbum;
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
      builder: (context) => ThemeBackdrop(
        opaque: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Ahora suena',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              PlayerOptions(audio: audio, onOpenAlbum: widget.onOpenAlbum),
            ],
            leading: IconButton(
              tooltip: 'Cerrar reproductor',
              onPressed: () => Navigator.pop(context),
              icon: const ThemeIcon('back', Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: PlayerPanel(
                    audio: audio,
                    library: library,
                    expanded: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: audio.mediaItem,
    initialData: audio.mediaItem.value,
    builder: (context, item) {
      final track = item.data;
      if (widget.expanded) {
        return ExpandedPlayer(
          audio: audio,
          library: library,
          artworkFirst: widget.artworkFirst,
        );
      }
      final desktop = MediaQuery.sizeOf(context).width >= 850;
      if (!desktop && !widget.expanded) {
        return TrackSwipe(
          audio: audio,
          onSwipeUp: openPlayer,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder(
                  stream: audio.positionStream,
                  builder: (context, position) => StreamBuilder(
                    stream: audio.durationStream,
                    initialData: audio.player.duration,
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
                        onPressed: track == null
                            ? null
                            : () => library.toggleFavorite(track.id),
                        icon: ThemeFavoriteIcon(
                          selected: library.favorites.contains(track?.id),
                        ),
                      ),
                      StreamBuilder(
                        stream: audio.playerStateStream,
                        initialData: audio.player.playerState,
                        builder: (context, state) => IconButton.filled(
                          tooltip: audio.player.playing
                              ? 'Pausar'
                              : 'Reproducir',
                          onPressed: () => audio.player.playing
                              ? audio.pause()
                              : audio.play(),
                          icon: ThemeIcon(
                            audio.player.playing ? 'pause' : 'play',
                            audio.player.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                    icon: const ThemeIcon('previous', Icons.skip_previous),
                  ),
                  StreamBuilder(
                    stream: audio.playerStateStream,
                    initialData: audio.player.playerState,
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
                        onPressed: () => playing ? audio.pause() : audio.play(),
                        icon: ThemeIcon(
                          playing ? 'pause' : 'play',
                          playing ? Icons.pause : Icons.play_arrow,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Siguiente',
                    onPressed: track == null ? null : audio.skipToNext,
                    icon: const ThemeIcon('next', Icons.skip_next),
                  ),
                  if (widget.expanded)
                    IconButton(
                      tooltip: 'Detener',
                      onPressed: audio.stop,
                      icon: const Icon(Icons.stop_circle_outlined),
                    ),
                  IconButton(
                    tooltip: 'Ver cola',
                    onPressed: () => showPlaybackQueue(context, audio, library),
                    icon: const ThemeIcon('queue', Icons.queue_music),
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
                    icon: const ThemeIcon('shuffle', Icons.shuffle),
                  ),
                  IconButton(
                    tooltip: 'Repetir canción',
                    isSelected: audio.repeat,
                    onPressed: () =>
                        setState(() => audio.repeat = !audio.repeat),
                    icon: const ThemeIcon('repeat', Icons.repeat_one),
                  ),
                ],
              ),
              StreamBuilder(
                stream: audio.positionStream,
                builder: (context, position) => StreamBuilder(
                  stream: audio.durationStream,
                  initialData: audio.player.duration,
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
                                Flexible(
                                  child: Text(
                                    track?.extras?['sourceName'] as String? ??
                                        'Audio local',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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

class Artwork extends StatefulWidget {
  const Artwork({
    super.key,
    required this.id,
    required this.library,
    this.size = 44,
    this.modifiedMs,
  });
  final String? id;
  final int? modifiedMs;
  final double size;
  final LibraryController library;
  @override
  State<Artwork> createState() => _ArtworkState();
}

class _ArtworkState extends State<Artwork> {
  Future<Uint8List?>? image;
  int? loadedStamp;
  bool get useThumbnail => widget.size <= 180;
  int stamp(String id) =>
      widget.modifiedMs ?? widget.library.thumbnailStamp(id);

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(Artwork old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id ||
        (widget.id != null && loadedStamp != stamp(widget.id!)) ||
        old.library != widget.library ||
        (old.size <= 180) != useThumbnail) {
      load();
    }
  }

  void load() {
    final id = widget.id;
    loadedStamp = id == null ? null : stamp(id);
    image = id == null
        ? null
        : useThumbnail
        ? widget.library.thumbnail(id, stamp(id))
        : widget.library.artwork(id);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.size,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: FutureBuilder(
        key: ValueKey((widget.id, loadedStamp, useThumbnail)),
        future: image,
        initialData: widget.id == null
            ? null
            : useThumbnail
            ? widget.library.cachedThumbnail(widget.id!, stamp(widget.id!))
            : widget.library.cachedArtwork(widget.id),
        builder: (context, snapshot) => snapshot.data == null
            ? const ColoredBox(
                color: Color(0xff272a32),
                child: ThemeIcon('album', Icons.album_outlined),
              )
            : Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                cacheWidth: widget.size > 100 ? 600 : 128,
                errorBuilder: (_, error, stack) =>
                    const ThemeIcon('album', Icons.album_outlined),
              ),
      ),
    ),
  );
}
