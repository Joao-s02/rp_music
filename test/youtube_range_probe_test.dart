import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tools/youtube_range_source.dart';

void main() {
  test(
    'renueva una vez ante 403 y vuelve a solicitar el mismo rango',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var refreshed = 0;
      server.listen((request) async {
        if (request.uri.path == '/old') {
          request.response.statusCode = 403;
        } else {
          expect(request.headers.value('range'), 'bytes=0-3');
          request.response.statusCode = 206;
          request.response.headers.set('content-range', 'bytes 0-3/4');
          request.response.contentLength = 4;
          request.response.add([1, 2, 3, 4]);
        }
        await request.response.close();
      });
      final source = YoutubeRangeProbeSource(
        Uri.parse('http://127.0.0.1:${server.port}/old'),
        4,
        refresh: () async {
          refreshed++;
          return Uri.parse('http://127.0.0.1:${server.port}/new');
        },
      );
      try {
        final response = await source.request();
        expect(await response.stream.expand((b) => b).toList(), [1, 2, 3, 4]);
        expect(refreshed, 1);
      } finally {
        source.close();
        await server.close(force: true);
      }
    },
  );
  test(
    'el adaptador conserva bytes y desplazamientos sin escribir archivos',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final bytes = List<int>.generate(600000, (i) => i % 251);
      final ranges = <String>[];
      server.listen((request) async {
        final range = request.headers.value('range')!;
        ranges.add(range);
        final match = RegExp(r'bytes=(\d+)-(\d+)').firstMatch(range)!;
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
      final source = YoutubeRangeProbeSource(
        Uri.parse('http://127.0.0.1:${server.port}/media'),
        bytes.length,
      );
      try {
        final response = await source.request(123, 580000);
        expect(response.offset, 123);
        expect(response.contentLength, 580000 - 123);
        final received = await response.stream.expand((b) => b).toList();
        expect(received, bytes.sublist(123, 580000));
        expect(ranges.length, 3);
        source.close();
        await expectLater(source.request(), throwsStateError);
      } finally {
        source.close();
        await server.close(force: true);
      }
    },
  );
  test('rechaza respuestas que no respetan el rango solicitado', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.statusCode = 200;
      await request.response.close();
    });
    final source = YoutubeRangeProbeSource(
      Uri.parse('http://127.0.0.1:${server.port}/media'),
      100,
    );
    try {
      final response = await source.request();
      await expectLater(
        response.stream.drain<void>(),
        throwsA(isA<HttpException>()),
      );
    } finally {
      source.close();
      await server.close(force: true);
    }
  });
}
