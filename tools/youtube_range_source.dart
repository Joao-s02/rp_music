// Experimental transport API is used deliberately only in this technical probe.
// ignore_for_file: experimental_member_use
// Probe-only adapter: stream bounded byte ranges, without caching to disk.
import 'dart:io';
import 'dart:math';

import 'package:just_audio/just_audio.dart';

class YoutubeRangeProbeSource extends StreamAudioSource {
  YoutubeRangeProbeSource(this.uri, this.length, {this.refresh});
  final Future<Uri> Function()? refresh;
  final Uri uri;
  final int length;
  int bytesReceived = 0;
  int requests = 0;
  int? lastStatus;
  final _clients = <HttpClient>{};
  bool _closed = false;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    requests++;
    final from = start ?? 0;
    final to = min(end ?? length, length);
    if (_closed || from < 0 || from >= to) throw StateError('Invalid range');
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: to - from,
      offset: from,
      contentType: 'audio/mp4',
      stream: _read(from, to),
    );
  }

  Stream<List<int>> _read(int from, int end) async* {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    _clients.add(client);
    try {
      var currentUri = uri;
      while (from < end && !_closed) {
        final last = min(from + 256 * 1024, end) - 1;
        Future<HttpClientResponse> open(Uri target) async {
          final request = await client
              .getUrl(target)
              .timeout(const Duration(seconds: 15));
          request.headers.set(HttpHeaders.rangeHeader, 'bytes=$from-$last');
          return request.close().timeout(const Duration(seconds: 15));
        }

        var response = await open(currentUri);
        if (response.statusCode == 403 && refresh != null) {
          await response.drain<void>();
          currentUri = await refresh!().timeout(const Duration(seconds: 30));
          response = await open(currentUri);
        }
        lastStatus = response.statusCode;
        if (response.statusCode != 206 ||
            response.headers.value(HttpHeaders.contentRangeHeader) !=
                'bytes $from-$last/$length') {
          throw const HttpException('Unexpected media range response');
        }
        var received = 0;
        await for (final bytes in response.timeout(
          const Duration(seconds: 15),
        )) {
          received += bytes.length;
          bytesReceived += bytes.length;
          if (received > last - from + 1) {
            throw const HttpException('Oversized range');
          }
          yield bytes;
        }
        if (received != last - from + 1) {
          throw const HttpException('Incomplete range');
        }
        from = last + 1;
      }
    } finally {
      _clients.remove(client);
      client.close(force: true);
    }
  }

  void close() {
    _closed = true;
    for (final client in _clients.toList()) {
      client.close(force: true);
    }
    _clients.clear();
  }
}
