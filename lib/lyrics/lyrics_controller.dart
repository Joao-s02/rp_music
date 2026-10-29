import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../data/music_files.dart';
import '../domain/lyrics.dart';
import '../domain/track.dart';
import '../extensions/program_controller.dart';
import '../playback/music_handler.dart';
import '../sources/extension_source_service.dart';

/// Local music is read only; every imported or fetched lyric lives in app data.
class LyricsController extends ChangeNotifier {
  LyricsController(
    this.root,
    this.files,
    this.programs, {
    ExtensionSourceService? service,
  }) : service = service ?? ExtensionSourceService(programs);
  final Directory root;
  final MusicFiles files;
  final ProgramController programs;
  final ExtensionSourceService service;
  final values = <String, Lyrics>{};
  final errors = <String, String>{};
  final pending = <String, Future<Lyrics?>>{};
  final _checked = <String, String>{};
  final _retryAfter = <String, DateTime>{};
  final _revisions = <String, int>{};
  StreamSubscription<dynamic>? _subscription;
  bool _closed = false;
  MusicHandler? _audio;

  void follow(MusicHandler audio) {
    _audio = audio;
    _subscription = audio.mediaItem.listen((_) => _current());
    programs.addListener(_current);
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

  String? provider(Track track) =>
      track.sourceId ?? programs.owner('lyrics')?.package.id;
  bool canFetch(Track track) {
    final id = provider(track);
    return id != null &&
        service.available(id, localLyrics: track.sourceId == null);
  }

  String signature(Track track) {
    final id = provider(track);
    final p = programs.installed[id];
    return '${track.modifiedMs}:${track.size}:$id:${p?.package.version}:${p?.enabled}:${p?.authorized}:${canFetch(track)}';
  }

  File file(String id) =>
      File('${root.path}/lyrics/${sha256.convert(utf8.encode(id))}.lrc');
  File _missFile(String id) => File('${file(id).path}.miss.json');

  Future<Lyrics?> ensure(Track track, {bool forceNetwork = false}) {
    final existing = pending[track.id];
    if (existing != null) return existing;
    final key = signature(track);
    if (!forceNetwork && _checked[track.id] == key) {
      final retry = _retryAfter[track.id];
      if (retry == null || DateTime.now().isBefore(retry)) {
        return Future.value(values[track.id]);
      }
    }
    if (_checked[track.id] != key) values.remove(track.id);
    final task = _load(track, key, forceNetwork);
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
        _retryAfter.remove(first);
      }
      _notify();
    });
  }

  Future<Lyrics?> _load(Track track, String key, bool force) async {
    final revision = _revisions[track.id] ?? 0;
    Lyrics? embeddedPlain;
    // Yield so pending is registered before the program registry can notify.
    await Future<void>.delayed(Duration.zero);
    errors.remove(track.id);
    _checked[track.id] = key;
    _retryAfter.remove(track.id);
    try {
      if (!force) {
        if (track.sourceId == null) {
          try {
            final embedded = await files.embeddedLyrics(track.id);
            if ((_revisions[track.id] ?? 0) != revision) {
              return values[track.id];
            }
            if (embedded != null && embedded.trim().isNotEmpty) {
              final value = Lyrics.parse(embedded);
              if (value.lines.isNotEmpty) {
                values[track.id] = value;
                return value;
              }
              embeddedPlain = value;
            }
          } catch (_) {
            // Import and network fallback remain usable if a tag format fails.
            errors[track.id] =
                'No se pudieron leer las letras incrustadas de este archivo.';
          }
        }
        final cached = file(track.id);
        var validCache = true;
        final origin = File('${cached.path}.origin.json');
        if (await origin.exists()) {
          try {
            final data = jsonDecode(await origin.readAsString()) as Map;
            validCache =
                data['modifiedMs'] == track.modifiedMs &&
                data['size'] == track.size;
          } catch (_) {
            validCache = false;
          }
        }
        if (validCache &&
            await cached.exists() &&
            await cached.length() <= 262144) {
          final text = await cached.readAsString();
          if ((_revisions[track.id] ?? 0) != revision) return values[track.id];
          if (text.trim().isNotEmpty) {
            final value = Lyrics.parse(text);
            values[track.id] = value.lines.isNotEmpty
                ? value
                : embeddedPlain ?? value;
            return values[track.id];
          }
        }
      }
      if (embeddedPlain != null) {
        values[track.id] = embeddedPlain;
        return embeddedPlain;
      }
      if (!canFetch(track)) return values[track.id];
      final miss = _missFile(track.id);
      if (!force && await miss.exists()) {
        try {
          final data = jsonDecode(await miss.readAsString()) as Map;
          final until = DateTime.tryParse(data['until'] as String? ?? '');
          if (data['signature'] == key &&
              until != null &&
              DateTime.now().isBefore(until)) {
            _retryAfter[track.id] = until;
            return null;
          }
        } catch (_) {
          /* A corrupt miss cache does not block a search. */
        }
      }
      final id = provider(track)!;
      final package = programs.installed[id]!.package;
      final result = await service.invoke(id, 'lyrics', {
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'durationMs': track.durationMs,
      }, localLyrics: track.sourceId == null);
      // Revocation or a changed owner invalidates results before private writes.
      if (_closed ||
          signature(track) != key ||
          programs.installed[id]?.package != package ||
          !canFetch(track)) {
        return null;
      }
      final text = textFrom(result);
      if (text.isEmpty) {
        final until = DateTime.now().add(const Duration(days: 1));
        _retryAfter[track.id] = until;
        await miss.parent.create(recursive: true);
        await miss.writeAsString(
          jsonEncode({'signature': key, 'until': until.toIso8601String()}),
        );
        errors[track.id] = result['instrumental'] == true
            ? 'El proveedor identifica esta canción como instrumental.'
            : 'No se encontró una letra que coincida con esta canción.';
        return null;
      }
      if ((_revisions[track.id] ?? 0) != revision) return values[track.id];
      if (values[track.id]?.lines.isNotEmpty == true &&
          Lyrics.parse(text).lines.isEmpty) {
        errors[track.id] = 'Se conserva la letra sincronizada guardada; el proveedor solo devolvió texto.';
        return values[track.id];
      }
      await save(track.id, text, track: track);
      return values[track.id];
    } catch (_) {
      _retryAfter[track.id] = DateTime.now().add(const Duration(minutes: 5));
      errors[track.id] =
          'No se pudo buscar la letra. Puedes reintentar desde Letras.';
      return values[track.id];
    } finally {
      _notify();
    }
  }

  static String textFrom(Map<String, dynamic> result) {
    final sync = result['syncedLyrics'];
    final value =
        sync is String &&
            sync.trim().isNotEmpty &&
            Lyrics.parse(sync).lines.isNotEmpty
        ? sync
        : result['plainLyrics'] ?? '';
    if (value is! String || utf8.encode(value).length > 262144) {
      throw const FormatException('Respuesta de letras incompatible.');
    }
    return value.trim();
  }

  Future<void> save(String id, String text, {Track? track}) async {
    final value = Lyrics.parse(text);
    if (text.trim().isEmpty) {
      throw const FormatException('La letra está vacía.');
    }
    _revisions[id] = (_revisions[id] ?? 0) + 1;
    final target = file(id);
    await target.parent.create(recursive: true);
    // Concurrent tracks have distinct filenames; each track has one pending lookup.
    await target.writeAsString(text, flush: true);
    final origin = File('${target.path}.origin.json');
    if (track == null) {
      if (await origin.exists()) await origin.delete();
    } else {
      await origin.writeAsString(
        jsonEncode({'modifiedMs': track.modifiedMs, 'size': track.size}),
      );
    }
    values[id] = value;
    errors.remove(id);
    _retryAfter.remove(id);
    final miss = _missFile(id);
    if (await miss.exists()) await miss.delete();
    _notify();
  }

  @override
  void dispose() {
    _closed = true;
    _subscription?.cancel();
    programs.removeListener(_current);
    super.dispose();
  }
}
