import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../domain/track.dart';

class ProgramSnapshot {
  ProgramSnapshot(List<Track> tracks, Set<String> favorites) {
    for (final track in tracks) {
      final id = sha256.convert(utf8.encode(track.id)).toString();
      byId[id] = track;
      rows.add({
        'id': id,
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'folder': track.folder,
        'durationMs': track.durationMs,
        'size': track.size,
        'modifiedMs': track.modifiedMs,
        'favorite': favorites.contains(track.id),
      });
    }
  }
  final byId = <String, Track>{};
  final rows = <Map<String, dynamic>>[];
  String? idFor(String path) {
    for (final entry in byId.entries) {
      if (entry.value.id == path) return entry.key;
    }
    return null;
  }

  List<Track> resolve(Object? ids) {
    if (ids is! List ||
        ids.length > byId.length ||
        ids.any((id) => id is! String || !byId.containsKey(id)) ||
        ids.toSet().length != ids.length) {
      throw const FormatException(
        'La extensión devolvió canciones inválidas o duplicadas.',
      );
    }
    return ids.map((id) => byId[id]!).toList();
  }
}
