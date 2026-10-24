import 'dart:io';
import 'dart:isolate';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../domain/track.dart';

const audioExtensions = {'.mp3', '.flac', '.m4a', '.mp4', '.wav', '.opus'};
const _channel = MethodChannel('rp_music/library');

class ScanResult {
  const ScanResult(this.tracks, this.skipped);
  final List<Track> tracks;
  final int skipped;
}

class MusicFiles {
  Future<String?> chooseRoot() => Platform.isAndroid
      ? _channel.invokeMethod<String>('chooseRoot')
      : FilePicker.getDirectoryPath(
          dialogTitle: 'Seleccionar carpeta de música',
        );
  Future<ScanResult> scan(String root) async {
    if (Platform.isAndroid) {
      final result = await _channel.invokeMapMethod<String, dynamic>('scan', {
        'root': root,
      });
      return ScanResult(
        (result!['tracks'] as List)
            .map((t) => Track.fromJson(Map<String, dynamic>.from(t as Map)))
            .toList(),
        result['skipped'] as int? ?? 0,
      );
    }
    return Isolate.run(() => scanDirectory(root));
  }

  Future<Uint8List?> artwork(String id) async {
    if (Platform.isAndroid) {
      return _channel.invokeMethod<Uint8List>('artwork', {'id': id});
    }
    return Isolate.run(() {
      try {
        return readMetadata(
          File(id),
          getImage: true,
        ).pictures.firstOrNull?.bytes;
      } catch (_) {
        return null;
      }
    });
  }
}

/// Runs outside the UI isolate; never follows symlinks outside the root.
ScanResult scanDirectory(String root) {
  final directory = Directory(root);
  if (!directory.existsSync()) {
    throw const FileSystemException('La carpeta no está disponible.');
  }
  final tracks = <Track>[];
  var skipped = 0;
  final pending = [directory];
  while (pending.isNotEmpty) {
    final current = pending.removeLast();
    List<FileSystemEntity> entries;
    try {
      entries = current.listSync(followLinks: false);
    } on FileSystemException {
      if (current.path == directory.path) rethrow;
      skipped++;
      continue;
    }
    for (final entry in entries) {
      if (entry is Directory) {
        pending.add(entry);
        continue;
      }
      if (entry is! File ||
          !audioExtensions.contains(p.extension(entry.path).toLowerCase())) {
        continue;
      }
      var title = p.basenameWithoutExtension(entry.path);
      String? artist, album;
      var duration = 0;
      try {
        final tags = readMetadata(entry);
        if (tags.title?.trim().isNotEmpty == true) title = tags.title!;
        artist = tags.artist;
        album = tags.album;
        duration = tags.duration?.inMilliseconds ?? 0;
      } catch (_) {
        skipped++;
      }
      tracks.add(
        Track(
          id: entry.path,
          title: title,
          folder: p.relative(entry.parent.path, from: root),
          artist: artist?.trim().isNotEmpty == true
              ? artist!
              : 'Artista desconocido',
          album: album?.trim().isNotEmpty == true ? album! : 'Sin álbum',
          durationMs: duration,
        ),
      );
    }
  }
  tracks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  return ScanResult(tracks, skipped);
}
