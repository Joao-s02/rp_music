import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../domain/track.dart';
import 'extension_source_service.dart';

/// Bounded transport for explicitly authorized audio exports.
class SourceAudioTransfer {
  static const maxBytes = 64 * 1024 * 1024;
  static Future<(Uint8List, String)> receive(
    Track track,
    ExtensionSourceService service,
  ) async {
    final id = track.sourceId;
    bool allowed() =>
        id != null &&
        service.available(id) &&
        service.programs.allowed(id, 'storage.download');
    if (!allowed()) {
      throw const FormatException(
        'Acepta el permiso de descarga de esta extensión.',
      );
    }
    final package = service.programs.installed[id]!.package;
    final uri = await service.resolve(track);
    if (!allowed()) throw const FormatException('Permiso retirado.');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final result = await (() async {
        final request = await client.getUrl(uri);
        request.followRedirects = false;
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-');
        final response = await request.close();
        if (![200, 206].contains(response.statusCode) ||
            response.contentLength > maxBytes) {
          throw const FormatException(
            'No se pudo descargar el audio o supera 64 MB.',
          );
        }
        if (response.statusCode == 206) {
          final range = RegExp(r'^bytes 0-(\d+)/(\d+)$').firstMatch(
            response.headers.value(HttpHeaders.contentRangeHeader) ?? '',
          );
          if (range == null ||
              int.parse(range.group(1)!) + 1 != int.parse(range.group(2)!) ||
              int.parse(range.group(2)!) > maxBytes) {
            throw const FormatException(
              'La fuente entregó solo una parte del audio.',
            );
          }
        }
        final mime = response.headers.contentType?.mimeType ?? '';
        if (!(mime.startsWith('audio/') ||
            mime == 'video/mp4' ||
            mime == 'application/octet-stream')) {
          throw const FormatException(
            'La fuente no entregó un archivo de audio.',
          );
        }
        final data = BytesBuilder(copy: false);
        await for (final chunk in response) {
          if (!allowed() ||
              service.programs.installed[id]?.package != package) {
            throw const FormatException('Fuente desactivada o modificada.');
          }
          if (data.length + chunk.length > maxBytes) {
            throw const FormatException('La descarga supera 64 MB.');
          }
          data.add(chunk);
        }
        if (data.length == 0) {
          throw const FormatException('El audio está vacío.');
        }
        if (response.contentLength >= 0 &&
            data.length != response.contentLength) {
          throw const FormatException('Descarga incompleta.');
        }
        return (data.takeBytes(), mime);
      })().timeout(const Duration(minutes: 3));
      if (!allowed() || service.programs.installed[id]?.package != package) {
        throw const FormatException('Permiso retirado.');
      }
      return result;
    } finally {
      client.close(force: true);
    }
  }
}
