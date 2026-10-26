import 'dart:io';

import 'package:rp_music/sources/youtube_music_api.dart';

Future<void> main() async {
  final api = YoutubeMusicApi();
  final found = await api.search('Kevin MacLeod', 'rp.youtube-music');
  stdout.writeln('YouTube Music search: ${found.length} song results');
  if (found.isEmpty) throw StateError('No song results');
  final id = YoutubeMusicApi.identity(found.first.id)!;
  final uri = await api.resolve(id[2]);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(uri);
    request.headers.set('Range', 'bytes=0-65535');
    final response = await request.close().timeout(const Duration(seconds: 15));
    var size = 0;
    await for (final chunk in response.timeout(const Duration(seconds: 15))) {
      size += chunk.length;
    }
    stdout.writeln(
      'First song audio: HTTP ${response.statusCode}, $size bytes',
    );
    if (response.statusCode != 206 || size != 65536) {
      throw StateError('Audio unavailable');
    }
  } finally {
    client.close(force: true);
  }
}
