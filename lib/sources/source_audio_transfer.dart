import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../domain/track.dart';
import 'extension_source_service.dart';

/// Bounded transport for explicitly authorized audio exports.
class SourceAudioTransfer {
  static const maxBytes = 64 * 1024 * 1024;
  static const maxFileBytes = 512 * 1024 * 1024;
  static Future<(File, String)> receiveFile(
    Track track,
    ExtensionSourceService service,
    Directory temporary, {
    bool Function()? cancelled,
    void Function(int received, int? total)? onProgress,
  }) async {
    final id = track.sourceId;
    final package = service.programs.installed[id]?.package;
    bool allowed() =>
        id != null &&
        package != null &&
        cancelled?.call() != true &&
        service.available(id) &&
        service.programs.installed[id]?.package == package &&
        service.programs.allowed(id, 'storage.download');
    if (!allowed()) {
      throw const FormatException(
        'Fuente desactivada o sin permiso de descarga.',
      );
    }
    final uri = await service.resolve(track);
    if (!allowed()) throw const FormatException('Descarga cancelada.');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    final file = File('${temporary.path}/audio.part');
    try {
      return await (() async {
        final request = await client.getUrl(uri);
        request.followRedirects = false;
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-');
        final response = await request.close();
        if (![200, 206].contains(response.statusCode)) {
          throw FormatException(
            'El servidor respondió HTTP ${response.statusCode}. Reintenta la canción.',
          );
        }
        if (response.contentLength > maxFileBytes) {
          throw const FormatException(
            'Esta canción supera el límite de 512 MiB.',
          );
        }
        var expectedLength = response.contentLength;
        if (response.statusCode == 206) {
          final range = RegExp(r'^bytes 0-(\d+)/(\d+)$').firstMatch(
            response.headers.value(HttpHeaders.contentRangeHeader) ?? '',
          );
          if (range == null ||
              int.parse(range.group(1)!) + 1 != int.parse(range.group(2)!)) {
            throw const FormatException(
              'El servidor entregó solo parte del audio.',
            );
          }
          if (int.parse(range.group(2)!) > maxFileBytes) {
            throw const FormatException(
              'Esta canción supera el límite de 512 MiB.',
            );
          }
          expectedLength = int.parse(range.group(2)!);
        }
        final mime = response.headers.contentType?.mimeType ?? '';
        if (!(mime.startsWith('audio/') ||
            mime == 'video/mp4' ||
            mime == 'application/octet-stream')) {
          throw const FormatException('La respuesta no contiene audio.');
        }
        var received = 0;
        final sink = file.openWrite();
        try {
          await for (final chunk in response.timeout(
            const Duration(seconds: 30),
          )) {
            if (!allowed()) {
              throw const FormatException(
                'Descarga cancelada o permiso retirado.',
              );
            }
            received += chunk.length;
            if (received > maxFileBytes) {
              throw const FormatException(
                'Esta canción supera el límite de 512 MiB.',
              );
            }
            sink.add(chunk);
            await sink.flush();
            onProgress?.call(
              received,
              expectedLength < 0 ? null : expectedLength,
            );
          }
          await sink.flush();
        } finally {
          await sink.close();
        }
        if (!allowed()) throw const FormatException('Descarga cancelada.');
        if (received == 0 ||
            (expectedLength >= 0 && received != expectedLength)) {
          throw const FormatException('Descarga incompleta.');
        }
        return (file, mime);
      })().timeout(const Duration(minutes: 15));
    } finally {
      client.close(force: true);
    }
  }

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
        if (![200, 206].contains(response.statusCode)) {
          throw FormatException(
            'El servidor de audio respondió HTTP ${response.statusCode}. Reintenta la canción.',
          );
        }
        if (response.contentLength > maxBytes) {
          throw const FormatException(
            'El archivo de esta canción supera el límite actual de 64 MiB.',
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
