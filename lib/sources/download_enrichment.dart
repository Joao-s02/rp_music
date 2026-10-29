import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import '../data/download_tags.dart';
import '../domain/track.dart';
import '../domain/lyrics.dart';
import '../lyrics/lyrics_controller.dart';
import 'extension_source_service.dart';
import 'download_context.dart';

class EnrichedDownload {
  EnrichedDownload(this.bytes, this.mime, this.title, this.notice, {this.file});
  final Uint8List bytes;
  final String mime, title;
  final String? notice;
  final File? file;
}

class DownloadEnrichment {
  static Future<EnrichedDownload> apply(
    Track track,
    Uint8List bytes,
    String mime,
    ExtensionSourceService service, {
    DownloadContext? albumContext,
    bool Function()? cancelled,
    Map<String, (Uint8List, String)>? coverCache,
    File? audioFile,
  }) async {
    final id = track.sourceId!;
    final package = service.programs.installed[id]!.package;
    bool allowed() =>
        cancelled?.call() != true &&
        service.available(id) &&
        service.programs.installed[id]?.package == package &&
        service.programs.allowed(id, 'storage.download');
    final tags = DownloadContext.merge(track, {}, albumContext);

    String? image = albumContext?.artwork ?? track.artwork;
    final artworkCandidates = <String>[];
    var missing = false;
    try {
      if (!allowed()) {
        throw const FormatException('Descarga cancelada o sin permiso.');
      }
      final result = await service.invoke(id, 'metadata', {
        'title': track.title,
        'artist': track.artist,
        'album': albumContext?.album ?? track.album,
        'albumLocked': albumContext != null,
        'durationMs': track.durationMs,
        'id': track.id.substring('rpmusic-source:$id:'.length),
      });
      if (result['tags'] is Map) {
        final raw = Map<String, dynamic>.from(result['tags'] as Map);
        tags.addAll(DownloadContext.merge(track, raw, albumContext));
      }
      final lyrics = LyricsController.textFrom(result);
      if (lyrics.isNotEmpty) tags['lyrics'] = lyrics;
      missing = result['complete'] != true || lyrics.isEmpty;
      final returnedTags = result['tags'];
      final matchingAlbum =
          returnedTags is Map &&
          DownloadContext.normalize('${returnedTags['album'] ?? ''}') ==
              DownloadContext.normalize('${tags['album'] ?? ''}');
      if (matchingAlbum) {
        if (result['artwork'] is String) {
          artworkCandidates.add(result['artwork'] as String);
        }
        if (result['artworkAlternatives'] is List) {
          artworkCandidates.addAll(
            (result['artworkAlternatives'] as List).whereType<String>().take(3),
          );
        }
      }
    } catch (_) {
      if (!allowed()) rethrow;
      missing = true;
      // Compatibility with sources offering lyrics before metadata enrichment.
      try {
        final text = LyricsController.textFrom(
          await service.invoke(id, 'lyrics', {
            'title': track.title,
            'artist': track.artist,
            'album': track.album,
            'durationMs': track.durationMs,
          }),
        );
        if (text.isNotEmpty) tags['lyrics'] = text;
      } catch (_) {
        /* Preserve the audio when a metadata service is offline. */
      }
    }
    if (!allowed()) {
      throw const FormatException('Fuente desactivada o permiso retirado.');
    }
    Uint8List? cover;
    String? coverMime;
    final albumCoverKey = albumContext == null
        ? null
        : 'album:${DownloadContext.normalize(albumContext.album)}\n${DownloadContext.normalize(albumContext.albumArtist)}';
    final sharedCover = albumCoverKey == null
        ? null
        : coverCache?[albumCoverKey];
    if (sharedCover != null) {
      cover = sharedCover.$1;
      coverMime = sharedCover.$2;
    }
    if (image != null) artworkCandidates.add(image);
    for (final image in artworkCandidates.toSet()) {
      if (cover != null) break;
      try {
        final result =
            coverCache?[image] ??
            await _cover(
              Uri.parse(image),
              (uri) => allowed() && package.sourceSpec!.permits(uri),
            );
        cover = result.$1;
        coverMime = result.$2;
        if (!package.sourceSpec!.permits(Uri.parse(image))) {
          throw const FormatException('Portada no autorizada.');
        }
        coverCache?[image] = result;
        if (albumCoverKey != null) coverCache?[albumCoverKey] = result;
        break;
      } catch (_) {
        // Try another explicitly returned, authorized cover of the same album.
      }
    }
    if (cover == null) missing = true;
    if (!allowed()) {
      throw const FormatException('Fuente desactivada o permiso retirado.');
    }
    // Detect the container, never guess it from an HTTP content type.
    final mp4 =
        bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp';
    if (!mp4) {
      return EnrichedDownload(
        bytes,
        mime,
        track.title,
        'Audio guardado en su formato original; no se pudieron incrustar etiquetas en este contenedor.',
        file: audioFile,
      );
    }
    Uint8List tagged;
    File? taggedFile;
    try {
      if (audioFile == null) {
        tagged = await _tag((bytes, tags, cover, coverMime));
      } else {
        taggedFile = await _tagFile(audioFile.path, tags, cover, coverMime);
        tagged = Uint8List(0);
      }
    } catch (_) {
      if (!allowed()) {
        throw const FormatException('Fuente desactivada o permiso retirado.');
      }
      return EnrichedDownload(
        bytes,
        mime,
        track.title,
        'Audio guardado sin modificar; no se pudieron incrustar las etiquetas en este archivo.',
        file: audioFile,
      );
    }
    if (!allowed()) {
      throw const FormatException('Fuente desactivada o permiso retirado.');
    }
    return EnrichedDownload(
      tagged,
      'audio/mp4',
      tags['title'] as String,
      tags['lyrics'] is String &&
              Lyrics.parse(tags['lyrics'] as String).lines.isEmpty
          ? 'Canción guardada; el proveedor solo ofreció letra de texto, sin tiempos de sincronización.'
          : missing
          ? 'Canción guardada con los metadatos disponibles; algunos datos o letras no se encontraron.'
          : null,
      file: taggedFile,
    );
  }

  static Future<File> _tagFile(
    String path,
    Map<String, dynamic> tags,
    Uint8List? cover,
    String? mime,
  ) => Isolate.run(
    () => DownloadTags.mp4File(File(path), tags, cover: cover, coverMime: mime),
  );

  static Future<EnrichedDownload> applyFile(
    Track track,
    File audio,
    String mime,
    ExtensionSourceService service, {
    DownloadContext? albumContext,
    bool Function()? cancelled,
    Map<String, (Uint8List, String)>? coverCache,
  }) async {
    final reader = await audio.open();
    late Uint8List header;
    try {
      header = await reader.read(12);
    } finally {
      await reader.close();
    }
    return apply(
      track,
      header,
      mime,
      service,
      albumContext: albumContext,
      cancelled: cancelled,
      coverCache: coverCache,
      audioFile: audio,
    );
  }

  // A separate scope captures only transferable data, never the program
  // registry, HTTP client or permission-check closures from apply().
  static Future<Uint8List> _tag(
    (Uint8List, Map<String, dynamic>, Uint8List?, String?) data,
  ) => Isolate.run(
    () =>
        DownloadTags.mp4(data.$1, data.$2, cover: data.$3, coverMime: data.$4),
  );

  static Future<(Uint8List, String)> _cover(
    Uri start,
    bool Function(Uri) allowed,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      return await (() async {
        var uri = start;
        for (var redirects = 0; redirects <= 3; redirects++) {
          if (!allowed(uri)) {
            throw const FormatException(
              'Portada fuera de los dominios autorizados.',
            );
          }
          final request = await client.getUrl(uri);
          request.followRedirects = false;
          final response = await request.close();
          if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
            final location = response.headers.value(HttpHeaders.locationHeader);
            if (location == null) {
              throw const FormatException('Portada no disponible.');
            }
            uri = uri.resolve(location);
            // Closing the client at the end discards any redirect response body.
            continue;
          }
          if (response.statusCode != 200 ||
              response.contentLength > 5 * 1024 * 1024) {
            throw const FormatException('Portada no disponible.');
          }
          final b = BytesBuilder(copy: false);
          await for (final chunk in response) {
            if (!allowed(uri) || b.length + chunk.length > 5 * 1024 * 1024) {
              throw const FormatException('Portada demasiado grande.');
            }
            b.add(chunk);
          }
          final data = b.takeBytes();
          final jpeg =
              data.length > 3 &&
              data[0] == 255 &&
              data[1] == 216 &&
              data[2] == 255;
          final png =
              data.length > 8 &&
              data[0] == 137 &&
              data[1] == 80 &&
              data[2] == 78 &&
              data[3] == 71;
          if (!jpeg && !png) {
            throw const FormatException('Formato de portada no compatible.');
          }
          return (data, png ? 'image/png' : 'image/jpeg');
        }
        throw const FormatException('Demasiadas redirecciones de portada.');
      })().timeout(const Duration(seconds: 25));
    } finally {
      client.close(force: true);
    }
  }
}
