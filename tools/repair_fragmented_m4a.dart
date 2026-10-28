import 'dart:io';

import 'package:rp_music/data/download_tags.dart';

/// Rebuild a compatible fragmented MP4 into a separate output, preserving tags
/// and media. Does not infer format from a filename or overwrite input/output.
Future<void> main(List<String> args) async {
  if (args.length != 2) {
    throw ArgumentError('Entrada y copia de salida requeridas.');
  }
  final input = File(args[0]);
  final output = File(args[1]);
  if (input.absolute.path == output.absolute.path || await output.exists()) {
    throw ArgumentError('La salida debe ser un archivo nuevo.');
  }
  final result = DownloadTags.mp4(await input.readAsBytes(), {});
  await output.parent.create(recursive: true);
  await output.writeAsBytes(result, flush: true);
  stdout.writeln(
    'Copia reparada: ${output.path} (${result.length} bytes). Original intacto.',
  );
}
