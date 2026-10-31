import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;

import '../domain/track.dart';
import 'mp4_album_artist.dart';

const audioExtensions = {'.mp3', '.flac', '.m4a', '.mp4', '.wav', '.opus'};

class ScanProgress {
  const ScanProgress(
    this.batch,
    this.processed,
    this.total, {
    this.discovery = false,
    this.append = false,
  });
  final List<Track> batch;
  final int processed;
  final int total;
  final bool discovery;
  final bool append;
}

class ScanResult {
  const ScanResult(this.tracks, this.skipped);
  final List<Track> tracks;
  final int skipped;
}

/// Runs in a worker. Discovery is published before opening individual media files.
ScanResult scanDirectory(
  String root, {
  List<Track> cached = const [],
  void Function(ScanProgress)? onProgress,
}) {
  final directory = Directory(root);
  if (!directory.existsSync()) {
    throw const FileSystemException('La carpeta no está disponible.');
  }
  final known = {for (final track in cached) track.id: track};
  final tracks = <Track>[];
  var skipped = 0;
  final pending = [directory];
  var discovered = <Track>[];
  var publishedDiscovery = false;
  void publishDiscovery({bool finalBatch = false}) {
    if (discovered.isEmpty && !finalBatch) return;
    onProgress?.call(
      ScanProgress(
        List.of(discovered),
        0,
        finalBatch ? tracks.length : 0,
        discovery: true,
        append: publishedDiscovery,
      ),
    );
    publishedDiscovery = true;
    discovered = [];
  }

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
      try {
        final stat = entry.statSync();
        tracks.add(
          Track(
            id: entry.path,
            title: p.basenameWithoutExtension(entry.path),
            folder: p.relative(entry.parent.path, from: root),
            size: stat.size,
            modifiedMs: stat.modified.millisecondsSinceEpoch,
          ),
        );
        discovered.add(tracks.last);
        if (discovered.length >= 128) publishDiscovery();
      } on FileSystemException {
        skipped++;
      }
    }
  }
  publishDiscovery(finalBatch: true);
  tracks.sort((a, b) => a.id.compareTo(b.id));
  var batch = <Track>[];
  final watch = Stopwatch()..start();
  for (var i = 0; i < tracks.length; i++) {
    final file = tracks[i];
    final previous = known[file.id];
    if (previous != null &&
        previous.metadataLoaded &&
        previous.metadataVersion >= 2 &&
        previous.size == file.size &&
        previous.modifiedMs == file.modifiedMs &&
        file.modifiedMs > 0) {
      tracks[i] = previous;
    } else {
      try {
        final tags = readMetadata(File(file.id));
        tracks[i] = Track(
          id: file.id,
          folder: file.folder,
          title: tags.title?.trim().isNotEmpty == true
              ? tags.title!
              : file.title,
          artist: tags.artist?.trim().isNotEmpty == true
              ? tags.artist!
              : 'Artista desconocido',
          album: tags.album?.trim().isNotEmpty == true
              ? tags.album!
              : 'Sin álbum',
          albumArtist: tags.albumArtist ?? mp4AlbumArtist(File(file.id)) ?? '',
          trackNumber: tags.trackNumber ?? 0,
          discNumber: tags.discNumber ?? 0,
          durationMs: tags.duration?.inMilliseconds ?? 0,
          size: file.size,
          modifiedMs: file.modifiedMs,
          metadataLoaded: true,
          metadataVersion: 2,
        );
      } catch (_) {
        skipped++;
      }
    }
    batch.add(tracks[i]);
    if (batch.length >= 128 ||
        watch.elapsedMilliseconds >= 160 ||
        i == tracks.length - 1) {
      onProgress?.call(ScanProgress(batch, i + 1, tracks.length));
      batch = [];
      watch.reset();
    }
  }
  tracks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  return ScanResult(tracks, skipped);
}
