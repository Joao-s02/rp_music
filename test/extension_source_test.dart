import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/extension_navigation.dart';
import 'package:rp_music/extensions/extension_http_transport.dart';
import 'package:rp_music/sources/extension_source_service.dart';
import 'package:rp_music/sources/extension_source_broker.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer;
import 'program_system_test.dart' show Registry;

ProgramPackage cloudPackage() => ProgramPackage.parse({
  'apiVersion': 2,
  'id': 'test.cloud',
  'name': 'Nube de prueba',
  'version': '1.0.0',
  'description': 'Fuente sintética para validar el contrato genérico.',
  'minAppVersion': '0.3.2',
  'permissions': ['network.http', 'navigation.add', 'playback.control'],
  'capabilities': ['source'],
  'sourceConfig': {
    'name': 'Nube de prueba',
    'domains': ['example.com', '*.example.org'],
    'platforms': ['android', 'windows'],
    'navigation': {'label': 'Nube', 'icon': 'cloud', 'color': '#00CCBB'},
  },
  'source': r"""
import 'dart:convert';
String run(String request) => jsonEncode(handle(jsonDecode(request)));
Map<String,dynamic> handle(dynamic input) {
  if (input['stage'] == 'start') return {'request': {'url': 'https://example.com/query'}, 'next': 'response'};
  if (input['operation'] == 'resolve') return {'url': 'https://audio.example.org/music.m4a'};
  return {'tracks': [{'id': 'song', 'title': 'Canción de prueba', 'artist': 'Artista', 'artwork': 'https://example.com/cover.png'}]};
}
""",
});

void main() {
  test(
    'dominios, permisos de navegación y compatibilidad se validan',
    () async {
      final p = cloudPackage();
      for (final url in [
        'http://example.com/a',
        'https://example.com.evil.test/a',
        'https://user@example.com/a',
        'https://example.com:444/a',
        'https://127.0.0.1/a',
      ]) {
        expect(p.sourceSpec!.permits(Uri.parse(url)), isFalse);
      }
      expect(
        p.sourceSpec!.permits(Uri.parse('https://a.example.org/a')),
        isTrue,
      );
      final programs = ProgramController(Registry());
      await programs.install(p, p.permissions);
      expect(extensionDestinations(programs, 'android').single.label, 'Nube');
      await programs.setGrants(p.id, {'network.http', 'playback.control'});
      expect(extensionDestinations(programs, 'android'), isEmpty);
      final future = ProgramPackage.parse({
        ...p.toJson(),
        'minAppVersion': '9.0.0',
      });
      await expectLater(
        programs.install(future, future.permissions),
        throwsFormatException,
      );
      await expectLater(
        ExtensionHttpTransport.request({'url': 'http://example.com'}, p),
        throwsFormatException,
      );
      await expectLater(
        ExtensionHttpTransport.request({
          'url': 'https://example.com',
          'method': 'DELETE',
        }, p),
        throwsFormatException,
      );
      programs.dispose();
    },
  );
  test(
    'búsqueda y audio usan el contrato externo y publican nombre y carátula',
    () async {
      final p = cloudPackage();
      final programs = ProgramController(Registry());
      await programs.install(p, p.permissions);
      var calls = 0;
      final service = ExtensionSourceService(
        programs,
        platform: 'android',
        transport: (request, package) async {
          calls++;
          return {'status': 200, 'body': '{}'};
        },
      );
      final tracks = await service.search('demo', p.id);
      expect(tracks.single.sourceName, 'Nube de prueba');
      final player = FakePlayer();
      final audio = MusicHandler(player: player);
      final broker = ExtensionSourceBroker(programs, audio, service: service);
      await audio.select(tracks, 0);
      expect(calls, 2);
      expect(player.played.single.host, 'audio.example.org');
      expect(audio.mediaItem.value!.extras!['sourceName'], 'Nube de prueba');
      expect(
        audio.mediaItem.value!.artUri.toString(),
        'https://example.com/cover.png',
      );
      await programs.setEnabled(p.id, false);
      await Future<void>.delayed(Duration.zero);
      expect(player.calls, contains('stop'));
      broker.dispose();
      await audio.close();
      programs.dispose();
    },
  );
  test(
    'retirar permiso durante la respuesta descarta resultados pendientes',
    () async {
      final p = cloudPackage();
      final programs = ProgramController(Registry());
      await programs.install(p, p.permissions);
      final gate = Completer<Map<String, dynamic>>();
      final service = ExtensionSourceService(
        programs,
        platform: 'android',
        transport: (_, _) => gate.future,
      );
      final pending = service.search('demo', p.id);
      while (!programs.busy) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      while (programs.busy) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await programs.setEnabled(p.id, false);
      gate.complete({'status': 200, 'body': '{}'});
      await expectLater(pending, throwsFormatException);
      programs.dispose();
    },
  );
}
