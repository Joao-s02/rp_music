import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../domain/track.dart';
import '../extensions/extension_http_transport.dart';
import '../extensions/program_controller.dart';
import '../extensions/program_package.dart';

typedef SourceTransport = Future<Map<String, dynamic>> Function(
  Map<String, dynamic> request,
  ProgramPackage package,
);

class ExtensionSourceService {
  ExtensionSourceService(
    this.programs, {
    SourceTransport? transport,
    String? platform,
  }) : transport = transport ?? ExtensionHttpTransport.request,
       platform = platform ?? Platform.operatingSystem;
  final ProgramController programs;
  final SourceTransport transport;
  final String platform;
  bool available(String id, {bool localLyrics = false}) {
    final p = programs.owner(localLyrics ? 'lyrics' : 'source')?.package;
    return p?.id == id &&
        p?.sourceSpec?.platforms.contains(platform) == true &&
        programs.allowed(id, 'network.http') &&
        (localLyrics
            ? programs.allowed(id, 'lyrics.cache') &&
                  programs.allowed(id, 'library.read')
            : programs.allowed(id, 'playback.control'));
  }

  static String trackId(String extension, String id) =>
      'rpmusic-source:$extension:$id';
  static bool remote(String id) => id.startsWith('rpmusic-source:');
  Future<Map<String, dynamic>> invoke(
    String id,
    String operation,
    Map<String, dynamic> input, {
    bool localLyrics = false,
  }) async {
    if (localLyrics && operation != 'lyrics') {
      throw const FormatException(
        'Operación incompatible con proveedor de letras.',
      );
    }
    final package = programs.installed[id]?.package;
    if (package == null || !available(id, localLyrics: localLyrics)) {
      throw const FormatException(
        'Actualiza y activa una extensión de fuente compatible.',
      );
    }
    var stage = 'start';
    Map<String, dynamic> context = {};
    Map<String, dynamic>? response;
    for (var step = 0; step < (operation == 'metadata' ? 8 : 4); step++) {
      if (!available(id, localLyrics: localLyrics) ||
          programs.installed[id]?.package != package) {
        throw const FormatException('Fuente desactivada o modificada.');
      }
      final deadline = DateTime.now().add(const Duration(seconds: 3));
      while (programs.busy && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      final data = await programs.invoke(
        id,
        localLyrics ? 'lyrics' : 'source',
        {
          ...input,
          'operation': operation,
          'stage': stage,
          'context': context,
          'response': ?response,
          'date': DateTime.now()
              .toUtc()
              .toIso8601String()
              .substring(0, 10)
              .replaceAll('-', ''),
        },
      );
      if (data == null ||
          !available(id, localLyrics: localLyrics) ||
          programs.installed[id]?.package != package) {
        throw const FormatException(
          'La fuente no respondió o fue desactivada.',
        );
      }
      if (data['error'] is String) {
        throw FormatException(
          (data['error'] as String).substring(
            0,
            (data['error'] as String).length.clamp(0, 250),
          ),
        );
      }
      if (data['request'] == null) return data;
      if (data['request'] is! Map ||
          data['next'] is! String ||
          (data['next'] as String).length > 30) {
        throw const FormatException('Petición inválida.');
      }
      context = data['context'] is Map
          ? Map<String, dynamic>.from(data['context'] as Map)
          : {};
      if (utf8.encode(jsonEncode(context)).length > 65536) {
        throw const FormatException('Contexto de red demasiado grande.');
      }
      stage = data['next'] as String;
      final request = Map<String, dynamic>.from(data['request'] as Map);
      try {
        response = await transport(request, package);
        if (operation == 'metadata' &&
            [429, 503].contains(response['status'])) {
          await Future<void>.delayed(const Duration(milliseconds: 1200));
          if (!available(id, localLyrics: localLyrics) ||
              programs.installed[id]?.package != package) {
            throw const FormatException('Fuente desactivada o modificada.');
          }
          response = await transport(request, package);
        }
      } catch (_) {
        if (operation != 'metadata') rethrow;
        // Let the package return the metadata/lyrics already obtained. Never
        // fabricate a successful response or erase an earlier stage's result.
        response = {'status': 0, 'body': ''};
      }
    }
    throw const FormatException('La fuente excedió su límite de peticiones.');
  }

  Future<List<Track>> search(String query, String id) async {
    query = query.trim();
    if (query.isEmpty || query.length > 200) {
      throw const FormatException('Escribe entre 1 y 200 caracteres.');
    }
    final data = await invoke(id, 'search', {'query': query});
    final rows = data['tracks'];
    if (rows is! List || rows.length > 50) {
      throw const FormatException('Resultados incompatibles.');
    }
    final spec = programs.installed[id]!.package.sourceSpec!;
    final result = <Track>[];
    final ids = <String>{};
    for (final row in rows) {
      if (row is! Map ||
          row['id'] is! String ||
          !RegExp(r'^[a-zA-Z0-9_.-]{1,200}$').hasMatch(row['id'] as String) ||
          row['title'] is! String ||
          (row['title'] as String).isEmpty) {
        throw const FormatException('Canción inválida.');
      }
      final key = row['id'] as String;
      if (!ids.add(key)) continue;
      final image = row['artwork'];
      if (image != null &&
          (image is! String || !spec.permits(Uri.parse(image)))) {
        throw const FormatException(
          'Carátula fuera de los dominios aceptados.',
        );
      }
      String text(dynamic value, String fallback) => value is String
          ? value.substring(0, value.length.clamp(0, 200))
          : fallback;
      result.add(
        Track(
          id: trackId(id, key),
          title: text(row['title'], 'Canción'),
          artist: text(row['artist'], 'Artista desconocido'),
          album: text(row['album'], 'Sin álbum'),
          folder: spec.name,
          sourceId: id,
          sourceName: spec.name,
          artwork: image as String?,
          durationMs: row['durationMs'] is int
              ? (row['durationMs'] as int).clamp(0, 86400000)
              : 0,
          metadataLoaded: true,
        ),
      );
    }
    return result;
  }

  Future<Uri> resolve(Track track) async {
    final id = track.sourceId;
    if (id == null || !track.id.startsWith('rpmusic-source:$id:')) {
      throw const FormatException('Identidad de fuente inválida.');
    }
    final result = await invoke(id, 'resolve', {
      'id': track.id.substring('rpmusic-source:$id:'.length),
    });
    if (result['url'] is! String) {
      throw const FormatException('La fuente no devolvió audio.');
    }
    final uri = Uri.parse(result['url'] as String);
    if (!programs.installed[id]!.package.sourceSpec!.permits(uri)) {
      throw const FormatException('Audio fuera de los dominios aceptados.');
    }
    return uri;
  }
}
