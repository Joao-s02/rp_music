import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../data/music_files.dart';
import '../domain/lyrics.dart';
import '../domain/track.dart';
import '../playback/music_handler.dart';

/// Local music is read only; every imported lyric lives in app data.
class LyricsController extends ChangeNotifier {
  LyricsController(this.root, this.files);
  final Directory root;
  final MusicFiles files;
  final values = <String, Lyrics>{};
  final errors = <String, String>{};
  final pending = <String, Future<Lyrics?>>{};
  final _checked = <String, String>{};
  final _revisions = <String, int>{};
  StreamSubscription<dynamic>? _subscription;
  bool _closed = false;
  MusicHandler? _audio;

  void follow(MusicHandler audio) {
    _audio = audio;
    _subscription = audio.mediaItem.listen((_) => _current());
    _current();
  }

  void _current() {
    final audio = _audio;
    final track = audio?.tracks
        .where((t) => t.id == audio.mediaItem.value?.id)
        .firstOrNull;
    if (track != null) unawaited(ensure(track));
  }

  void _notify() {
    if (!_closed) notifyListeners();
  }

  File file(String id) =>
      File('${root.path}/lyrics/${sha256.convert(utf8.encode(id))}.lrc');

  /// Results from providers have an origin sidecar. Imports are unmarked.
  Future<void> purgeOnlineCache() async {
    final directory = Directory('${root.path}/lyrics');
    try {
      if (!await directory.exists()) return;
      await for (final entry in directory.list(followLinks: false)) {
        if (entry is! File) continue;
        final name = entry.uri.pathSegments.last;
        if (RegExp(r'^[a-f0-9]{64}\.lrc\.origin\.json$').hasMatch(name)) {
          final lyric = File(entry.path.substring(0, entry.path.length - 12));
          if (await lyric.exists()) await lyric.delete();
          await entry.delete();
        } else if (RegExp(r'^[a-f0-9]{64}\.lrc\.miss\.json$').hasMatch(name)) {
          await entry.delete();
        }
      }
    } on FileSystemException {
      // Origin markers still prevent reading stale online results. Retry at launch.
    }
  }

  Future<Lyrics?> ensure(Track track) {
    final existing = pending[track.id];
    if (existing != null) return existing;
    final key = '${track.modifiedMs}:${track.size}';
    if (_checked[track.id] == key) return Future.value(values[track.id]);
    values.remove(track.id);
    final task = _load(track, key);
    pending[track.id] = task;
    _notify();
    return task.whenComplete(() {
      pending.remove(track.id);
      while (values.length > 64) {
        final first = values.keys.first;
        values.remove(first);
        _checked.remove(first);
      }
      while (_checked.length > 256) {
        final first = _checked.keys.first;
        _checked.remove(first);
      }
      _notify();
    });
  }

  Future<Lyrics?> _load(Track track, String key) async {
    final id = track.id;
    final revision = _revisions[id] ?? 0;
    Lyrics? embedded;
    Lyrics? imported;
    errors.remove(id);
    try {
      final text = await files.embeddedLyrics(id);
      if (text != null && text.trim().isNotEmpty) embedded = Lyrics.parse(text);
    } catch (_) {
      errors[id] = 'No se pudieron leer las letras incrustadas.';
    }
    if (embedded?.lines.isNotEmpty != true) {
      try {
        final target = file(id);
        if (!await File('${target.path}.origin.json').exists() &&
            await target.exists() &&
            await target.length() <= 262144) {
          final text = await target.readAsString();
          if (text.trim().isNotEmpty) imported = Lyrics.parse(text);
        }
      } catch (_) {
        errors[id] = 'No se pudo leer la letra guardada.';
      }
    }
    if ((_revisions[id] ?? 0) != revision) return values[id];
    _checked[id] = key;
    final value = embedded?.lines.isNotEmpty == true
        ? embedded
        : imported?.lines.isNotEmpty == true
        ? imported
        : embedded ?? imported;
    if (value != null) values[id] = value;
    return value;
  }

  Future<void> save(String id, String text) async {
    final value = Lyrics.parse(text);
    if (text.trim().isEmpty) {
      throw const FormatException('La letra está vacía.');
    }
    _revisions[id] = (_revisions[id] ?? 0) + 1;
    final target = file(id);
    await target.parent.create(recursive: true);
    await target.writeAsString(text, flush: true);
    final origin = File('${target.path}.origin.json');
    if (await origin.exists()) await origin.delete();
    values[id] = value;
    errors.remove(id);
    _notify();
  }

  @override
  void dispose() {
    _closed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
