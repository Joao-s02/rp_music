import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import '../data/music_files.dart';
import '../domain/extension_manifest.dart';
import '../domain/track.dart';

class LibraryController extends ChangeNotifier {
  LibraryController(this.store, this.files);
  final LocalStore store;
  final MusicFiles files;
  List<Track> tracks = [];
  String? root;
  bool loading = true;
  bool scanning = false;
  bool choosing = false;
  bool dark = true;
  String? message;
  Set<String> favorites = {};
  Map<String, List<String>> playlists = {};
  List<ExtensionManifest> extensions = [];
  String? activeExtensionId;
  ExtensionManifest? get activeExtension =>
      extensions.where((e) => e.id == activeExtensionId).firstOrNull;

  Future<void> initialize() async {
    try {
      final json = await store.load();
      if (json['schema'] == 1) {
        root = json['root'] as String?;
        tracks = (json['tracks'] as List)
            .map((e) => Track.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        favorites = (json['favorites'] as List).cast<String>().toSet();
        playlists = (json['playlists'] as Map).map(
          (key, value) =>
              MapEntry(key as String, (value as List).cast<String>()),
        );
        extensions = (json['extensions'] as List)
            .map(
              (e) =>
                  ExtensionManifest.parse(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        activeExtensionId = json['activeExtension'] as String?;
        dark = json['dark'] as bool? ?? true;
      }
    } catch (_) {
      message = 'No se pudo recuperar la biblioteca guardada. Selecciona tu carpeta para reconstruirla.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> persist() async {
    final snapshot = {
      'schema': 1,
      'root': root,
      'tracks': tracks.map((e) => e.toJson()).toList(),
      'favorites': favorites.toList(),
      'playlists': playlists.map((k, v) => MapEntry(k, List<String>.of(v))),
      'extensions': extensions.map((e) => e.toJson()).toList(),
      'activeExtension': activeExtensionId,
      'dark': dark,
    };
    try {
      await store.save(snapshot);
    } catch (_) {
      message = 'No se pudieron guardar los cambios en el dispositivo.';
      notifyListeners();
    }
  }

  Future<void> chooseRoot() async {
    if (scanning || choosing) return;
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
    if (candidate == null || scanning) return;
    scanning = true;
    message = null;
    notifyListeners();
    try {
      final result = await files.scan(candidate);
      // Commit only after a successful scan; cancellation/failure keeps the previous library.
      root = candidate;
      tracks = List.unmodifiable(result.tracks);
      message = result.skipped > 0
          ? '${result.skipped} archivos o carpetas no pudieron leerse completamente.'
          : null;
      await persist();
    } catch (_) {
      message =
          'No se pudo leer la carpeta. Se conserva la biblioteca anterior.';
    } finally {
      scanning = false;
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

  Future<void> addToPlaylist(String name, String id) async {
    final list = playlists[name];
    if (list == null || list.contains(id)) return;
    list.add(id);
    notifyListeners();
    await persist();
  }

  Future<void> setDark(bool value) async {
    dark = value;
    notifyListeners();
    await persist();
  }

  Future<void> activateExtension(String? id) async {
    activeExtensionId = id;
    notifyListeners();
    await persist();
  }

  Future<void> removeExtension(String id) async {
    extensions.removeWhere((e) => e.id == id);
    if (activeExtensionId == id) activeExtensionId = null;
    notifyListeners();
    await persist();
  }

  Future<void> importExtension() async {
    try {
      final file = await FilePicker.pickFile();
      if (file?.path == null) return;
      final source = File(file!.path!);
      if (await source.length() > 65536) {
        throw const FormatException('El archivo supera 64 KB.');
      }
      final extension = ExtensionManifest.parse(
        jsonDecode(await source.readAsString()) as Map<String, dynamic>,
      );
      // Explicit import is also explicit acceptance of a replacement/update.
      extensions.removeWhere((e) => e.id == extension.id);
      extensions.add(extension);
      notifyListeners();
      await persist();
    } on FormatException catch (e) {
      message = e.message;
      notifyListeners();
    } catch (_) {
      message = 'No se pudo importar la extensión. Usa un manifiesto JSON compatible.';
      notifyListeners();
    }
  }
}
