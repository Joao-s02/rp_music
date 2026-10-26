import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tools/youtube_buffer_source.dart';

void main() {
  test(
    'dos lecturas comparten una descarga secuencial y conservan los bytes',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final bytes = List<int>.generate(600000, (i) => i % 251);
      var connections = 0;
      server.listen((request) async {
        connections++;
        final match = RegExp(r'bytes=(\d+)-(\d+)')
            .firstMatch(request.headers.value('range')!)!;
        final from = int.parse(match[1]!);
        final last = int.parse(match[2]!);
        request.response.statusCode = 206;
        request.response.headers.set(
          'content-range',
          'bytes $from-$last/${bytes.length}',
        );
        request.response.contentLength = last - from + 1;
        request.response.add(bytes.sublist(from, last + 1));
        await request.response.close();
      });
      final source = YoutubeBufferProbeSource(
        Uri.parse('http://127.0.0.1:${server.port}/media'),
        bytes.length,
      );
      try {
        final a = await source.request(10, 300000);
        final b = await source.request(200000, 580000);
        final results = await Future.wait([
          a.stream.expand((b) => b).toList(),
          b.stream.expand((b) => b).toList(),
        ]);
        expect(results[0], bytes.sublist(10, 300000));
        expect(results[1], bytes.sublist(200000, 580000));
        final tail = await source.request(580000, bytes.length);
        expect(
          await tail.stream.expand((b) => b).toList(),
          bytes.sublist(580000),
        );
        expect(connections, 3);
        expect(source.bytesReceived, bytes.length);
      } finally {
        source.close();
        await server.close(force: true);
      }
    },
  );
  test('la sonda limita memoria y rechaza tamaños inválidos', () {
    for (final size in [0, -1, 16 * 1024 * 1024 + 1]) {
      expect(
        () => YoutubeBufferProbeSource(
          Uri.parse('https://example.com/audio'),
          size,
        ),
        throwsArgumentError,
      );
    }
  });
}
