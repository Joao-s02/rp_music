import 'dart:io';

import 'package:rp_music/extensions/program_catalog.dart';

Future<void> main() async {
  final catalog = await ProgramCatalog.load(
    'https://github.com/Joao-s02/rp-music-extensions',
  );
  for (final entry in catalog.entries.where(
    (entry) => entry.id != 'rp.youtube-music',
  )) {
    final package = await catalog.download(entry);
    stdout.writeln(
      '${package.id} ${package.version}: SHA-256 y metadatos verificados',
    );
  }
}
