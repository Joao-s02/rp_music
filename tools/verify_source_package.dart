// Generic development harness; source-specific programs live in their own repo.
import 'dart:convert';
import 'dart:io';

import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/program_runtime.dart';
import 'package:rp_music/extensions/extension_http_transport.dart';

Future<void> main(List<String> args) async {
  if (args.length < 2) throw ArgumentError('Paquete y consulta requeridos');
  final package = ProgramPackage.parse(
    Map<String, dynamic>.from(
      jsonDecode(await File(args[0]).readAsString()) as Map,
    ),
  );
  final runtime = ProgramRuntime();
  Future<Map<String, dynamic>> invoke(
    String operation,
    Map<String, dynamic> input,
  ) async {
    var stage = 'start';
    Map<String, dynamic> context = {};
    Map<String, dynamic>? response;
    for (var i = 0; i < 4; i++) {
      final data = await runtime.execute(package.source, {
        'event': 'source',
        'operation': operation,
        'stage': stage,
        'context': context,
        ...input,
        'response': ?response,
        'date': DateTime.now()
            .toUtc()
            .toIso8601String()
            .substring(0, 10)
            .replaceAll('-', ''),
      });
      if (data['error'] != null) throw StateError(data['error'] as String);
      if (data['request'] == null) return data;
      stage = data['next'] as String;
      context = data['context'] is Map
          ? Map<String, dynamic>.from(data['context'] as Map)
          : {};
      response = await ExtensionHttpTransport.request(
        Map<String, dynamic>.from(data['request'] as Map),
        package,
      );
    }
    throw StateError('Too many requests');
  }

  final result = await invoke('search', {'query': args[1]});
  final tracks = result['tracks'] as List;
  stdout.writeln('Search results: ${tracks.length}');
  if (tracks.isEmpty) throw StateError('Empty search');
  final audio = await invoke('resolve', {'id': (tracks.first as Map)['id']});
  final uri = Uri.parse(audio['url'] as String);
  if (package.sourceSpec?.permits(uri) != true) {
    throw StateError('Invalid audio domain');
  }
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    request.headers.set('Range', 'bytes=0-65535');
    final response = await request.close().timeout(const Duration(seconds: 15));
    var received = 0;
    await for (final chunk in response) {
      received += chunk.length;
    }
    if (response.statusCode != 206 || received != 65536) {
      throw StateError('No audio');
    }
    stdout.writeln('Audio verified: $received bytes');
  } finally {
    client.close(force: true);
  }
}
