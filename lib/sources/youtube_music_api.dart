import 'dart:convert';
import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../domain/track.dart';
import 'youtube_client.dart';

class YoutubeMusicApi {
  static bool validVideoId(String id) =>
      RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id);
  static String trackId(String extension, String video) =>
      'rpmusic-youtube:$extension:$video';
  static List<String>? identity(String id) {
    final parts = id.split(':');
    return parts.length == 3 &&
            parts[0] == 'rpmusic-youtube' &&
            validVideoId(parts[2])
        ? parts
        : null;
  }

  static Uri artwork(String video) =>
      Uri.https('i.ytimg.com', '/vi/$video/mqdefault.jpg');

  Future<List<Track>> search(String query, String extension) async {
    query = query.trim();
    if (query.isEmpty || query.length > 200) {
      throw const FormatException('Escribe entre 1 y 200 caracteres.');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      return await (() async {
        final date = DateTime.now()
            .toUtc()
            .toIso8601String()
            .substring(0, 10)
            .replaceAll('-', '');
        final request = await client.postUrl(
          Uri.https('music.youtube.com', '/youtubei/v1/search', {
            'prettyPrint': 'false',
          }),
        );
        request.followRedirects = false;
        request.headers.contentType = ContentType.json;
        request.headers.set('User-Agent', 'Mozilla/5.0');
        request.write(
          jsonEncode({
            'context': {
              'client': {
                'clientName': 'WEB_REMIX',
                'clientVersion': '1.$date.01.00',
                'hl': 'es',
                'gl': 'BO',
              },
            },
            'query': query,
            'params': 'EgWKAQIIAWoMEA4QChADEAQQCRAF',
          }),
        );
        final response = await request.close();
        if (response.statusCode != 200) {
          throw const FormatException(
            'YouTube Music no respondió. Intenta más tarde.',
          );
        }
        final bytes = <int>[];
        await for (final chunk in response) {
          if (bytes.length + chunk.length > 2 * 1024 * 1024) {
            throw const FormatException('Respuesta demasiado grande.');
          }
          bytes.addAll(chunk);
        }
        return parseSearch(jsonDecode(utf8.decode(bytes)), extension);
      })().timeout(const Duration(seconds: 25));
    } finally {
      client.close(force: true);
    }
  }

  static List<Track> parseSearch(dynamic data, String extension) {
    final results = <Track>[];
    final ids = <String>{};
    String text(dynamic column) {
      if (column is! Map) return '';
      final runs =
          column['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'];
      if (runs is! List) return '';
      return runs
          .whereType<Map>()
          .map((r) => r['text'] is String ? r['text'] : '')
          .join();
    }

    void visit(dynamic node, int depth) {
      if (depth > 40 || results.length >= 30) return;
      if (node is Map) {
        final row = node['musicResponsiveListItemRenderer'];
        if (row is Map && row['flexColumns'] is List) {
          final columns = row['flexColumns'] as List;
          final video = row['playlistItemData']?['videoId'];
          final title = columns.isNotEmpty ? text(columns.first) : '';
          if (video is String &&
              validVideoId(video) &&
              ids.add(video) &&
              title.isNotEmpty) {
            final detail = columns.length > 1
                ? text(columns[1])
                : 'YouTube Music';
            results.add(
              Track(
                id: trackId(extension, video),
                title: title.substring(0, title.length.clamp(0, 200)),
                artist: detail.substring(0, detail.length.clamp(0, 200)),
                folder: 'YouTube Music',
                metadataLoaded: true,
              ),
            );
          }
        }
        for (final value in node.values) {
          visit(value, depth + 1);
        }
      } else if (node is List) {
        for (final value in node) {
          visit(value, depth + 1);
        }
      }
    }

    visit(data, 0);
    return results;
  }

  Future<Uri> resolve(String video) async {
    if (!validVideoId(video)) throw const FormatException('Canción inválida.');
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streams
          .getManifest(video, ytClients: [youtubeMusicClient])
          .timeout(const Duration(seconds: 25));
      final audio =
          manifest.audioOnly.where((s) => s.tag == 140 || s.tag == 139).toList()
            ..sort((a, b) => b.tag.compareTo(a.tag));
      if (audio.isEmpty) {
        throw const FormatException(
          'No hay audio compatible para esta canción.',
        );
      }
      final uri = audio.first.url;
      if (uri.scheme != 'https' ||
          !uri.host.endsWith('.googlevideo.com') ||
          uri.userInfo.isNotEmpty) {
        throw const FormatException('Origen de audio no permitido.');
      }
      return uri;
    } finally {
      yt.close();
    }
  }
}
