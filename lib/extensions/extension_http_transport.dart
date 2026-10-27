import 'dart:convert';
import 'dart:io';

import 'program_package.dart';

class ExtensionHttpTransport {
  static Future<Map<String, dynamic>> request(
    Map<String, dynamic> request,
    ProgramPackage package,
  ) async {
    final uri = Uri.tryParse(
      request['url'] is String ? request['url'] as String : '',
    );
    if (uri == null || package.sourceSpec?.permits(uri) != true) {
      throw const FormatException('Dominio no autorizado.');
    }
    final delay = request['delayMs'] ?? 0;
    if (delay is! int || delay < 0 || delay > 2000) {
      throw const FormatException('Espera de petición inválida.');
    }
    if (delay > 0) await Future<void>.delayed(Duration(milliseconds: delay));
    final method = request['method'] ?? 'GET';
    if (!['GET', 'POST'].contains(method)) {
      throw const FormatException('Método no admitido.');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      return await (() async {
        final outgoing = await client.openUrl(method as String, uri);
        outgoing.followRedirects = false;
        final headers = request['headers'];
        if (headers != null && headers is! Map) {
          throw const FormatException('Cabeceras inválidas.');
        }
        if (headers is Map) {
          if (headers.length > 16) {
            throw const FormatException('Demasiadas cabeceras.');
          }
          for (final entry in headers.entries) {
            if (entry.key is! String ||
                entry.value is! String ||
                [
                  'host',
                  'authorization',
                  'proxy-authorization',
                  'connection',
                  'content-length',
                  'transfer-encoding',
                ].contains((entry.key as String).toLowerCase()) ||
                (entry.value as String).length > 4096 ||
                (entry.value as String).contains('\r') ||
                (entry.value as String).contains('\n')) {
              throw const FormatException('Cabecera no admitida.');
            }
            outgoing.headers.set(entry.key as String, entry.value as String);
          }
        }
        if (request.containsKey('body')) {
          final body = jsonEncode(request['body']);
          if (utf8.encode(body).length > 65536) {
            throw const FormatException('Petición demasiado grande.');
          }
          outgoing.headers.contentType = ContentType.json;
          outgoing.write(body);
        }
        final response = await outgoing.close();
        if (response.statusCode >= 300 && response.statusCode < 400) {
          throw const FormatException('Redirección no permitida.');
        }
        final bytes = <int>[];
        await for (final chunk in response) {
          if (bytes.length + chunk.length > 1536 * 1024) {
            throw const FormatException(
              'Respuesta de fuente demasiado grande.',
            );
          }
          bytes.addAll(chunk);
        }
        return {
          'status': response.statusCode,
          'body': utf8.decode(bytes),
          'cookies': response.cookies
              .map((c) => '${c.name}=${c.value}')
              .toList(),
        };
      })().timeout(const Duration(seconds: 25));
    } finally {
      client.close(force: true);
    }
  }
}
