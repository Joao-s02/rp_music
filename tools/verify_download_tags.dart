import 'dart:convert';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:rp_music/data/download_tags.dart';

/// Generic local test helper: never contacts a music service or edits input.
Future<void> main(List<String> args) async {
  if (args.length != 2) {
    throw ArgumentError('Archivo de entrada y copia de salida');
  }
  if (File(args[0]).absolute.path == File(args[1]).absolute.path) {
    throw ArgumentError('Usa otra ruta para la copia.');
  }
  final bytes = await File(args[0]).readAsBytes();
  final tagged = DownloadTags.mp4(bytes, {
    'title': 'Prueba de etiquetas',
    'artist': 'RP Music',
    'album': 'Verificación',
    'albumArtist': 'RP Music',
    'date': '2026-10-27',
    'trackNumber': 1,
    'trackTotal': 1,
    'discNumber': 1,
    'discTotal': 1,
    'lyrics': '[00:00]Uno\n[00:02]Dos',
  });
  final file = File(args[1]);
  await file.writeAsBytes(tagged);
  final data = readMetadata(file);
  stdout.writeln(
    jsonEncode({
      'title': data.title,
      'album': data.album,
      'lyrics': data.lyrics != null,
      'durationMs': data.duration?.inMilliseconds,
    }),
  );
}
