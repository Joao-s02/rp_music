// Probe-only bounded RAM transport. No permanent/offline file is created.
// ignore_for_file: experimental_member_use
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:just_audio/just_audio.dart';

class YoutubeBufferProbeSource extends StreamAudioSource {
  YoutubeBufferProbeSource(this.uri, this.length) {
    if (length <= 0 || length > 16 * 1024 * 1024) {
      throw ArgumentError('Probe RAM limit');
    }
  }
  final Uri uri;
  final int length;
  final _chunks = <List<int>>[];
  final _offsets = <int>[];
  HttpClient? _client;
  Completer<void> _changed = Completer<void>();
  int bytesReceived = 0;
  int requests = 0;
  int? lastStatus;
  bool _started = false, _closed = false, _done = false;
  Object? _error;

  void _notify() {
    final old = _changed;
    _changed = Completer<void>();
    old.complete();
  }

  Future<void> _download() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    _client = client;
    try {
      while (!_closed && bytesReceived < length) {
        final from = bytesReceived;
        final last = min(from + 256 * 1024, length) - 1;
        final request = await client
            .getUrl(uri)
            .timeout(const Duration(seconds: 15));
        request.headers.set('Range', 'bytes=$from-$last');
        final response = await request.close().timeout(
          const Duration(seconds: 15),
        );
        lastStatus = response.statusCode;
        if (response.statusCode != 206 ||
            response.contentLength != last - from + 1 ||
            response.headers.value('content-range') !=
                'bytes $from-$last/$length') {
          throw const HttpException('Unexpected media response');
        }
        await for (final chunk in response.timeout(
          const Duration(seconds: 15),
        )) {
          if (_closed) break;
          if (bytesReceived + chunk.length > last + 1) {
            throw const HttpException('Oversized media');
          }
          _offsets.add(bytesReceived);
          _chunks.add(chunk);
          bytesReceived += chunk.length;
          _notify();
        }
        if (!_closed && bytesReceived != last + 1) {
          throw const HttpException('Incomplete media range');
        }
      }
      if (!_closed && bytesReceived != length) {
        throw const HttpException('Incomplete media');
      }
    } catch (e) {
      _error = e;
    } finally {
      _done = true;
      client.close(force: true);
      _notify();
    }
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    requests++;
    final from = start ?? 0;
    final to = min(end ?? length, length);
    if (_closed || from < 0 || from >= to) throw StateError('Invalid range');
    if (!_started) {
      _started = true;
      unawaited(_download());
    }
    return StreamAudioResponse(
      sourceLength: length,
      contentLength: to - from,
      offset: from,
      contentType: 'audio/mp4',
      stream: _slice(from, to),
    );
  }

  Stream<List<int>> _slice(int from, int end) async* {
    var index = 0;
    while (from < end && !_closed) {
      if (from >= bytesReceived) {
        if (_error != null) throw _error!;
        if (_done) throw const HttpException('Incomplete buffered range');
        await _changed.future;
        continue;
      }
      while (index + 1 < _offsets.length && _offsets[index + 1] <= from) {
        index++;
      }
      final chunk = _chunks[index];
      final offset = _offsets[index];
      final last = min(chunk.length, end - offset);
      yield chunk.sublist(from - offset, last);
      from = offset + last;
    }
  }

  void close() {
    _closed = true;
    _client?.close(force: true);
    _notify();
    // Active slices exit on _closed; drop references after probe disposal.
  }
}
