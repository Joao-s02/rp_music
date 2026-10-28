import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import 'extension_source_service.dart';

/// Provider queries require both local-library consent and declared domains.
/// Images are private persistent files, so cached portraits also work offline.
class ArtistPortraits extends ChangeNotifier {
  ArtistPortraits(this.directory);
  final Directory directory;
  final Map<String, File> images = {};
  bool disposed = false, working = false;
  String key(String name) =>
      sha256.convert(utf8.encode(name.toLowerCase().trim())).toString();
  File? image(String name) => images[key(name)];
  Future<void> warm(
    Iterable<String> names,
    ExtensionSourceService? source,
  ) async {
    if (working || disposed) return;
    working = true;
    try {
      if (names.isEmpty) return;
      if (source?.programs.owner('source')?.package.sourceSpec?.artistArtwork !=
              true &&
          !await directory.exists()) {
        return;
      }
      await directory.create(recursive: true);
      final state = LocalStore(directory, baseName: 'portraits');
      final index = await state.load();
      final artists = names.toSet().where((s) => s != 'Artista desconocido');
      // Populate every cached portrait before attempting any network request.
      // One missing artist must not delay the existing photos while offline.
      for (final name in artists) {
        final file = File('${directory.path}/${key(name)}.jpg');
        if (await file.exists()) images[key(name)] = file;
        if (disposed) return;
      }
      if (!disposed) notifyListeners();
      for (final name in artists) {
        if (disposed) break;
        final id = key(name);
        final file = File('${directory.path}/$id.jpg');
        if (await file.exists()) {
          if (disposed) break;
          images[id] = file;
          continue;
        }
        if (source == null) continue;
        final owner = source.programs.owner('source')?.package;
        if (owner == null ||
            owner.sourceSpec?.artistArtwork != true ||
            !source.available(owner.id) ||
            !source.programs.allowed(owner.id, 'library.read')) {
          continue;
        }
        bool allowed() =>
            !disposed &&
            source.available(owner.id) &&
            source.programs.installed[owner.id]?.package == owner &&
            source.programs.allowed(owner.id, 'library.read');
        final last = index[id];
        if (last is int &&
            DateTime.now().millisecondsSinceEpoch - last <
                const Duration(days: 1).inMilliseconds) {
          continue;
        }
        // Keep browsing/playback calls ahead of optional background portraits.
        if (source.programs.busy) {
          await Future<void>.delayed(const Duration(milliseconds: 400));
          if (source.programs.busy) continue;
        }
        try {
          if (!allowed()) break;
          final result = await source.invoke(owner.id, 'artistArtwork', {
            'artist': name,
          });
          if (!allowed()) break;
          final image = result['artwork'];
          if (image is String &&
              result['artist'] is String &&
              (result['artist'] as String).toLowerCase().trim() ==
                  name.toLowerCase().trim()) {
            final uri = Uri.tryParse(image);
            if (uri == null || !owner.sourceSpec!.permits(uri)) continue;
            final client = HttpClient()
              ..connectionTimeout = const Duration(seconds: 8);
            try {
              final bytes = await (() async {
                final request = await client.getUrl(uri);
                request.followRedirects = false;
                final response = await request.close();
                if (response.statusCode != 200 ||
                    !(response.headers.contentType?.mimeType.startsWith(
                          'image/',
                        ) ??
                        false)) {
                  throw const FormatException('Imagen no disponible');
                }
                final bytes = <int>[];
                await for (final chunk in response) {
                  bytes.addAll(chunk);
                  if (bytes.length > 1024 * 1024 || !allowed()) {
                    throw const FormatException('Imagen demasiado grande');
                  }
                }
                return bytes;
              })().timeout(const Duration(seconds: 12));
              if (!allowed()) break;
              final codec = await ui.instantiateImageCodec(
                Uint8List.fromList(bytes),
                targetWidth: 256,
              );
              try {
                final frame = await codec.getNextFrame();
                try {
                  final png = await frame.image.toByteData(
                    format: ui.ImageByteFormat.png,
                  );
                  if (!allowed() || png == null) break;
                  await file.writeAsBytes(
                    png.buffer.asUint8List(),
                    flush: true,
                  );
                } finally {
                  frame.image.dispose();
                }
              } finally {
                codec.dispose();
              }
              if (!disposed) {
                images[id] = file;
                notifyListeners();
              }
            } finally {
              client.close(force: true);
            }
          }
        } on SocketException {
          break;
        } on TimeoutException {
          break;
        } catch (_) {
          /* Keep music browsing available when offline. */
        }
        index[id] = DateTime.now().millisecondsSinceEpoch;
        if (!disposed) await state.save(index);
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      // Bounded persistent storage; least recently modified portraits go first.
      final files = await directory
          .list()
          .where((f) => f.path.endsWith('.jpg'))
          .cast<File>()
          .toList();
      final dates = <String, int>{};
      var bytes = 0;
      for (final file in files) {
        final stat = await file.stat();
        bytes += stat.size;
        dates[file.path] = stat.modified.millisecondsSinceEpoch;
      }
      files.sort((a, b) => dates[a.path]!.compareTo(dates[b.path]!));
      for (final file in files) {
        if (bytes <= 64 * 1024 * 1024) break;
        bytes -= await file.length();
        await file.delete();
        images.remove(file.uri.pathSegments.last.split('.').first);
      }
    } finally {
      working = false;
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
