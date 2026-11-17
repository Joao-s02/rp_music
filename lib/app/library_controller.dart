import 'dart:io';

import '../artists/artist_portraits.dart';

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import '../data/music_files.dart';
import '../domain/track.dart';
import '../domain/track_sort.dart';
import '../themes/theme_library.dart';
import '../lyrics/lyrics_controller.dart';

class LibraryController extends ChangeNotifier {
  LibraryController(this.store, this.files);
  final LocalStore store;
  final MusicFiles files;
  List<Track> tracks = [];
  List<Track>? _stableTracks;
  String? _stableRoot;
  String? root;
  bool loading = true;
  bool scanning = false;
  bool deleting = false;
  int scanProcessed = 0;
  int scanTotal = 0;
  bool choosing = false;
  TrackSort sort = TrackSort.title;
  bool ascending = true;
  List<Track> ordered(Iterable<Track> source) =>
      sortTracks(source, sort, ascending);
  bool dark = true;
  bool playlistGrid = false;
  bool closeToTray = true;
  bool artistPhotosEnabled = false;
  double volume = 1;
  String? message;
  Set<String> favorites = {};
  Map<String, List<String>> playlists = {};
  Map<String, Map<String, dynamic>> playlistMeta = {};
  late final themes = ThemeLibrary(
    LocalStore(store.directory, baseName: 'themes'),
  );
  LyricsController? lyrics;
  ArtistPortraits? _portraits;
  ArtistPortraits get portraits => _portraits ??= ArtistPortraits(
    Directory('${store.directory.path}/artist_portraits'),
  );

  final _artwork = <String, Future<Uint8List?>>{};
  final _artworkValues = <String, Uint8List>{};

  String _artworkKey(String id) {
    final track = tracks.where((track) => track.id == id).firstOrNull;
    return '$id:${track?.modifiedMs}:${track?.size}';
  }

  Uint8List? cachedArtwork(String? id) =>
      id == null ? null : _artworkValues[_artworkKey(id)];

  Future<Uint8List?> artwork(String id) {
    final key = _artworkKey(id);
    return _artwork.putIfAbsent(key, () async {
      try {
        final bytes = await files.artwork(id);
        if (bytes != null && bytes.length <= 8 * 1024 * 1024) {
          _artworkValues[key] = bytes;
        }
        while (_artworkValues.length > 8 ||
            _artworkValues.values.fold<int>(
                  0,
                  (sum, value) => sum + value.length,
                ) >
                16 * 1024 * 1024) {
          final first = _artworkValues.keys.first;
          _artworkValues.remove(first);
          _artwork.remove(first);
        }
        while (_artwork.length > 16) {
          _artwork.remove(_artwork.keys.first);
        }
        return bytes;
      } catch (_) {
        _artwork.remove(key);
        return null;
      }
    });
  }

  final _thumbnails = <(String, int), Future<Uint8List?>>{};
  final _thumbnailSizes = <(String, int), int>{};
  int _thumbnailBytes = 0;

  Future<Uint8List?> thumbnail(String id, int modifiedMs) {
    final key = (id, modifiedMs);
    final existing = _thumbnails.remove(key);
    if (existing != null) {
      _thumbnails[key] = existing;
      return existing;
    }
    final request = _readThumbnail(key);
    _thumbnails[key] = request;
    return request;
  }

  Future<Uint8List?> _readThumbnail((String, int) key) async {
    try {
      final bytes = await files.thumbnail(key.$1);
      final size = bytes?.length ?? 0;
      _thumbnailSizes[key] = size;
      _thumbnailBytes += size;
      while (_thumbnailSizes.length > 192 ||
          _thumbnailBytes > 12 * 1024 * 1024) {
        final oldest = _thumbnails.keys.firstWhere(_thumbnailSizes.containsKey);
        _thumbnails.remove(oldest);
        _thumbnailBytes -= _thumbnailSizes.remove(oldest)!;
      }
      return bytes;
    } catch (_) {
      _thumbnails.remove(key);
      return null;
    }
  }

  bool automaticPlaylist(String name) =>
      playlistMeta[name]?['owner'] is String &&
      playlistMeta[name]?['rule'] is Map;
  Future<void> createPlaylistWithTracks(String name, List<String> ids) async {
    final clean = name.trim();
    if (clean.isEmpty || clean.length > 80 || playlists.containsKey(clean)) {
      throw const FormatException('Elige un nombre nuevo para la lista.');
    }
    final available = tracks.map((track) => track.id).toSet();
    playlists[clean] = ids.where(available.contains).toSet().toList();
    await persist();
    notifyListeners();
  }

  Future<void> setPlaylistCover(String name, String? path) async {
    if (!playlists.containsKey(name)) return;
    final meta = playlistMeta.putIfAbsent(name, () => {});
    if (path == null) {
      meta.remove('cover');
    } else {
      meta['cover'] = path;
    }
    await persist();
    notifyListeners();
  }

  bool _recoveryRequired = false;
  static const _recoveryMessage =
      'No se pudo recuperar la biblioteca guardada. El guardado está bloqueado para conservar los archivos originales.';

  // Parse every field into detached values, including lazy collection casts,
  // before returning the single publication step. No candidate mutates state.
  VoidCallback _prepareSnapshot(Map<String, dynamic> json) {
    if (json['schema'] != 1) {
      throw const FormatException('Unsupported library schema.');
    }
    final nextRoot = json['root'] as String?;
    final nextTracks = (json['tracks'] as List)
        .map((e) => Track.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final nextFavorites = (json['favorites'] as List).cast<String>().toSet();
    final nextPlaylists = (json['playlists'] as Map).map(
      (key, value) => MapEntry(key as String, List<String>.from(value as List)),
    );
    final nextMeta = {
      for (final entry in (json['playlistMeta'] as Map? ?? {}).entries)
        if (entry.key is String && entry.value is Map)
          entry.key as String: (Map<String, dynamic>.from(entry.value as Map)
            ..remove('owner')
            ..remove('rule')),
    };
    final nextSort =
        TrackSort.values
            .where((value) => value.name == json['sort'])
            .firstOrNull ??
        TrackSort.title;
    final nextAscending = json['ascending'] as bool? ?? true;
    final nextPlaylistGrid = json['playlistGrid'] as bool? ?? false;
    final nextDark = json['dark'] as bool? ?? true;
    final nextArtistPhotos = json['artistPhotosEnabled'] == true;
    final nextCloseToTray = json['closeToTray'] as bool? ?? true;
    final nextVolume = ((json['volume'] as num?)?.toDouble() ?? 1).clamp(
      0.0,
      1.0,
    );
    return () {
      root = nextRoot;
      tracks = nextTracks;
      favorites = nextFavorites;
      playlists = nextPlaylists;
      playlistMeta = nextMeta;
      sort = nextSort;
      ascending = nextAscending;
      dark = nextDark;
      playlistGrid = nextPlaylistGrid;
      artistPhotosEnabled = nextArtistPhotos;
      closeToTray = nextCloseToTray;
      volume = nextVolume;
    };
  }

  Future<void> initialize() async {
    try {
      VoidCallback? publish;
      await store.loadValidated((json) => publish = _prepareSnapshot(json));
      publish?.call();
      _recoveryRequired = false;
    } catch (_) {
      _recoveryRequired = true;
      message = _recoveryMessage;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> persist() async {
    if (_recoveryRequired) {
      message = _recoveryMessage;
      notifyListeners();
      return;
    }
    final snapshot = {
      'schema': 1,
      'root': _stableTracks == null ? root : _stableRoot,
      'tracks': (_stableTracks ?? tracks).map((e) => e.toJson()).toList(),
      'favorites': favorites.toList(),
      'playlistMeta': jsonDecode(jsonEncode(playlistMeta)),
      'playlists': playlists.map((k, v) => MapEntry(k, List<String>.of(v))),
      'sort': sort.name,
      'ascending': ascending,
      'dark': dark,
      'playlistGrid': playlistGrid,
      'closeToTray': closeToTray,
      'artistPhotosEnabled': artistPhotosEnabled,
      'volume': volume,
    };
    try {
      await store.save(snapshot);
    } catch (_) {
      message = 'No se pudieron guardar los cambios en el dispositivo.';
      notifyListeners();
    }
  }

  Future<void> chooseRoot() async {
    if (scanning || choosing || deleting) return;
    choosing = true;
    notifyListeners();
    try {
      final selected = await files.chooseRoot();
      if (selected != null) await refresh(selected);
    } catch (_) {
      message = 'No se pudo abrir la carpeta. Comprueba su permiso de acceso.';
    } finally {
      choosing = false;
      notifyListeners();
    }
  }

  Future<void> refresh([String? selectedRoot]) async {
    final candidate = selectedRoot ?? root;
    if (candidate == null || scanning || deleting) return;
    scanning = true;
    message = null;
    scanProcessed = 0;
    scanTotal = 0;
    final previousRoot = root;
    final previousTracks = tracks;
    _stableTracks = previousTracks;
    _stableRoot = previousRoot;
    final staging = <Track>[];
    final positions = <String, int>{};
    notifyListeners();
    try {
      final result = await files.scan(
        candidate,
        cached: candidate == previousRoot ? previousTracks : const [],
        onProgress: (progress) {
          if (progress.discovery) {
            if (!progress.append) {
              staging.clear();
              positions.clear();
            }
            final start = staging.length;
            staging.addAll(progress.batch);
            for (var i = start; i < staging.length; i++) {
              positions[staging[i].id] = i;
            }
          } else {
            for (final track in progress.batch) {
              final index = positions[track.id];
              if (index != null) staging[index] = track;
            }
          }
          root = candidate;
          tracks = List.unmodifiable(staging);
          scanProcessed = progress.processed;
          scanTotal = progress.total;
          notifyListeners();
        },
      );
      // Commit only after a successful scan; cancellation/failure keeps the previous library.
      root = candidate;
      tracks = List.unmodifiable(result.tracks);
      _stableTracks = null;
      _stableRoot = null;
      message = result.skipped > 0
          ? '${result.skipped} archivos o carpetas no pudieron leerse completamente.'
          : null;
      await persist();
    } catch (_) {
      root = previousRoot;
      tracks = previousTracks;
      _stableTracks = null;
      _stableRoot = null;
      message =
          'No se pudo leer la carpeta. Se conserva la biblioteca anterior.';
    } finally {
      scanning = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTrack(
    Track track, {
    Future<void> Function()? beforeDelete,
  }) async {
    if (scanning ||
        choosing ||
        deleting ||
        !tracks.any((t) => t.id == track.id)) {
      return false;
    }
    deleting = true;
    notifyListeners();
    try {
      if (root != null && !await files.ensureWritable(root!)) {
        message = 'No se concedió escritura. No se eliminó ningún archivo.';
        return false;
      }
      await beforeDelete?.call();
      await files.delete(track.id);
      tracks = tracks.where((t) => t.id != track.id).toList();
      favorites.remove(track.id);
      for (final list in playlists.values) {
        list.removeWhere((id) => id == track.id);
      }
      await persist();
      return true;
    } catch (_) {
      message = 'No se pudo eliminar el archivo. Comprueba el permiso de escritura; en Android vuelve a elegir la carpeta desde Ajustes.';
      return false;
    } finally {
      deleting = false;
      notifyListeners();
    }
  }

  Future<void> setSort(TrackSort value) async {
    sort = value;
    notifyListeners();
    await persist();
  }

  Future<void> toggleSortDirection() async {
    ascending = !ascending;
    notifyListeners();
    await persist();
  }

  Future<void> requestWriteAccess() async {
    if (root == null || choosing || scanning || deleting) return;
    choosing = true;
    notifyListeners();
    try {
      final granted = await files.ensureWritable(root!);
      message = granted ? 'Acceso de escritura autorizado para esta carpeta.' : 'No se concedió escritura. Puedes seguir escuchando sin borrar archivos.';
    } catch (_) {
      message = 'El proveedor no permitió autorizar escritura en esta carpeta.';
    } finally {
      choosing = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    if (!favorites.remove(id)) favorites.add(id);
    notifyListeners();
    await persist();
  }

  Future<void> addPlaylist(String name) async {
    final clean = name.trim();
    if (clean.isEmpty || playlists.containsKey(clean)) return;
    playlists[clean] = [];
    notifyListeners();
    await persist();
  }

  Future<void> deletePlaylist(String name) async {
    if (playlists.remove(name) == null) return;
    playlistMeta.remove(name);
    notifyListeners();
    await persist();
  }

  Future<int> addTracksToPlaylist(String name, Iterable<String> ids) async {
    if (!playlists.containsKey(name) || automaticPlaylist(name)) {
      throw const FormatException('Elige una lista manual existente.');
    }
    final available = tracks.map((t) => t.id).toSet();
    final before = playlists[name]!.length;
    playlists[name] = {
      ...playlists[name]!,
      ...ids.where(available.contains),
    }.toList();
    await persist();
    notifyListeners();
    return playlists[name]!.length - before;
  }

  Future<void> addSongToPlaylists(
    String id,
    Set<String> names, {
    String? newName,
  }) async {
    if (!tracks.any((track) => track.id == id)) {
      throw const FormatException('La canción ya no está disponible.');
    }
    if (names.any(
      (name) => !playlists.containsKey(name) || automaticPlaylist(name),
    )) {
      throw const FormatException('Una de las listas ya no está disponible.');
    }
    if (newName != null &&
        (newName.trim().isEmpty ||
            newName.length > 80 ||
            playlists.containsKey(newName))) {
      throw const FormatException('Elige un nombre nuevo para la lista.');
    }
    for (final name in names) {
      final ids = playlists[name]!;
      if (!ids.contains(id)) ids.add(id);
    }
    if (newName != null) playlists[newName] = [id];
    await persist();
    notifyListeners();
  }

  Future<void> addToPlaylist(String name, String id) async {
    if (automaticPlaylist(name)) return;
    final list = playlists[name];
    if (list == null || list.contains(id)) return;
    list.add(id);
    notifyListeners();
    await persist();
  }

  List<Track> playlistTracks(String name) {
    final byId = {for (final track in tracks) track.id: track};
    return [
      for (final id in playlists[name] ?? <String>[])
        if (byId[id] != null) byId[id]!,
    ];
  }

  int missingInPlaylist(String name) =>
      (playlists[name]?.length ?? 0) - playlistTracks(name).length;

  Future<void> removeFromPlaylist(String name, String id) async {
    if (automaticPlaylist(name)) return;
    playlists[name]?.remove(id);
    notifyListeners();
    await persist();
  }

  Future<void> removeMissingFromPlaylist(String name) async {
    final available = tracks.map((t) => t.id).toSet();
    playlists[name]?.removeWhere((id) => !available.contains(id));
    notifyListeners();
    await persist();
  }

  Future<void> setArtistPhotosEnabled(bool value) async {
    artistPhotosEnabled = value;
    if (!value) {
      _portraits?.dispose();
      _portraits = null;
    }
    notifyListeners();
    await persist();
  }

  Future<void> setPlaylistGrid(bool value) async {
    playlistGrid = value;
    notifyListeners();
    await persist();
  }

  Future<void> setDark(bool value) async {
    dark = value;
    notifyListeners();
    await persist();
  }

  Future<void> setCloseToTray(bool value) async {
    closeToTray = value;
    notifyListeners();
    await persist();
  }

  Future<void> setVolume(double value) async {
    volume = value.clamp(0.0, 1.0);
    await persist();
  }

  @override
  void dispose() {
    _portraits?.dispose();
    themes.dispose();
    lyrics?.dispose();
    super.dispose();
  }
}
