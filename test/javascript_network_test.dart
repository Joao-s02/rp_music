import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/extensions/javascript_screen_service.dart';
import 'package:rp_music/extensions/javascript_program_runtime.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/sources/extension_source_service.dart';
import 'package:rp_music/sources/extension_source_broker.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'program_system_test.dart' show Registry;
import 'playback_and_ui_test.dart' show FakePlayer;
import 'javascript_extensions_test.dart' show jsPackage;
import 'extension_source_test.dart' show cloudPackage;

ProgramPackage networkPackage({String? code, bool stream = false}) =>
    ProgramPackage.parse({
      ...jsPackage().toJson(),
      'minAppVersion': '0.3.9',
      'permissions': [
        'navigation.add',
        'network.http',
        'storage.private',
        'playback.control',
        if (stream) 'network.stream',
      ],
      'sourceConfig': {
        'name': 'Synthetic network',
        'domains': ['example.com'],
        'platforms': ['android', 'windows'],
      },
      'source': code ?? "function run(i){if(i.stage==='start')return {request:{url:'https://example.com/data'},next:'result',context:{value:5}};return {view:{type:'text',text:String(i.response.status)},state:{value:i.context.value,status:i.response.status}};}",
    });

void main() {
  test(
    'native stack limit stops recursion and the next evaluation still works',
    () async {
      await expectLater(
        JavascriptProgramRuntime.execute(
          'function recurse(){return recurse();} function run(){return {value:recurse()};}',
          {},
        ),
        throwsFormatException,
      );
      expect(
        await JavascriptProgramRuntime.execute(
          'function run(){return {ok:true};}',
          {},
        ),
        {'ok': true},
      );
    },
  );
  test(
    'network packages require new minimum, domains and explicit permissions',
    () {
      final p = networkPackage();
      expect(ProgramPackage.parse(p.toJson()).sourceSpec!.domains, [
        'example.com',
      ]);
      expect(
        () => ProgramPackage.parse({...p.toJson(), 'minAppVersion': '0.3.8'}),
        throwsFormatException,
      );
      expect(
        () => ProgramPackage.parse({...p.toJson(), 'sourceConfig': null}),
        throwsFormatException,
      );
      expect(
        () => ProgramPackage.parse({
          ...networkPackage(stream: true).toJson(),
          'permissions': ['navigation.add', 'network.http', 'network.stream'],
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'host continuations validate context and persist only final state',
    () async {
      final programs = ProgramController(Registry());
      addTearDown(programs.dispose);
      final p = networkPackage();
      await programs.install(p, p.permissions);
      var requests = 0;
      final service = JavascriptScreenService(
        programs,
        transport: (request, package) async {
          requests++;
          expect(programs.busy, isFalse);
          expect(programs.privateData[p.id], isNull);
          return {'status': 200, 'body': '{}'};
        },
      );
      final result = await service.run(p.id, {'action': 'search'});
      expect(result['view']['text'], '200');
      expect(requests, 1);
      expect(programs.privateData[p.id]!['value'], 5);
    },
  );
  test(
    'revocation while network is pending discards response and state',
    () async {
      final programs = ProgramController(Registry());
      addTearDown(programs.dispose);
      final p = networkPackage();
      await programs.install(p, p.permissions);
      final started = Completer<void>(),
          pending = Completer<Map<String, dynamic>>();
      final service = JavascriptScreenService(
        programs,
        transport: (r, p) {
          started.complete();
          return pending.future;
        },
      );
      final future = service.run(p.id, {'action': 'search'});
      final expectation = expectLater(future, throwsFormatException);
      await started.future;
      await programs.setGrants(p.id, {'navigation.add'});
      pending.complete({'status': 200, 'body': '{}'});
      await expectation;
      expect(programs.privateData[p.id], isNull);
    },
  );
  test('cancelled network cannot commit late state or audio', () async {
    final programs = ProgramController(Registry());
    addTearDown(programs.dispose);
    final p = networkPackage();
    await programs.install(p, p.permissions);
    var active = true;
    final service = JavascriptScreenService(
      programs,
      transport: (r, p) async {
        active = false;
        return {'status': 200, 'body': '{}'};
      },
    );
    await expectLater(
      service.run(p.id, {'action': 'search'}, active: () => active),
      throwsFormatException,
    );
    expect(programs.privateData[p.id], isNull);
  });
  test(
    'network outage is data and request loops stop after four requests',
    () async {
      final programs = ProgramController(Registry());
      addTearDown(programs.dispose);
      final p = networkPackage();
      await programs.install(p, p.permissions);
      final service = JavascriptScreenService(
        programs,
        transport: (r, p) async => throw const SocketException('offline'),
      );
      expect(
        (await service.run(p.id, {'action': 'search'}))['view']['text'],
        '0',
      );
      expect(programs.installed[p.id]!.failures, 0);
      final loop = networkPackage(
        code: "function run(){return {request:{url:'https://example.com/data'},next:'again'};}",
      );
      await programs.install(loop, loop.permissions);
      var calls = 0;
      final loops = JavascriptScreenService(
        programs,
        transport: (r, p) async {
          calls++;
          return {'status': 200, 'body': ''};
        },
      );
      await expectLater(
        loops.run(p.id, {'action': 'search'}),
        throwsFormatException,
      );
      expect(calls, 4);
    },
  );
  test(
    'foreign request domains are rejected before transport is called',
    () async {
      final programs = ProgramController(Registry());
      addTearDown(programs.dispose);
      final p = networkPackage(
        code: "function run(){return {request:{url:'https://evil.org/data'},next:'again'};}",
      );
      await programs.install(p, p.permissions);
      var called = false;
      final service = JavascriptScreenService(
        programs,
        transport: (r, p) async {
          called = true;
          return {};
        },
      );
      await expectLater(
        service.run(p.id, {'action': 'search'}),
        throwsFormatException,
      );
      expect(called, isFalse);
    },
  );
  test(
    'screen audio coexists with source owner and revocation stops playback',
    () async {
      final programs = ProgramController(Registry());
      addTearDown(programs.dispose);
      final cloud = cloudPackage();
      await programs.install(cloud, cloud.permissions);
      final p = networkPackage();
      await programs.install(p, p.permissions);
      final player = FakePlayer();
      final audio = MusicHandler(player: player);
      final sources = ExtensionSourceService(programs, platform: 'windows');
      final broker = ExtensionSourceBroker(programs, audio, service: sources);
      addTearDown(broker.dispose);
      addTearDown(audio.close);
      final screens = JavascriptScreenService(programs);
      final track = screens.remoteTrack(p.id, {
        'id': 'demo',
        'title': 'Demo',
        'url': 'https://example.com/audio.mp3',
      });
      expect(programs.owner('source')!.package.id, cloud.id);
      expect(
        await sources.resolve(track),
        Uri.parse('https://example.com/audio.mp3'),
      );
      await audio.select([track], 0);
      await Future<void>.delayed(Duration.zero);
      expect(audio.mediaItem.value!.title, 'Demo');
      await programs.setEnabled(p.id, false);
      await Future<void>.delayed(Duration.zero);
      expect(player.playing, isFalse);
      expect(broker.allowed(track), isFalse);
      expect(
        () => screens.remoteTrack(p.id, {
          'id': 'demo',
          'title': 'Demo',
          'url': 'https://example.com/audio.mp3',
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'remote audio rejects credentials, local targets, HTTP and foreign domains',
    () async {
      final programs = ProgramController(Registry());
      addTearDown(programs.dispose);
      final p = networkPackage();
      await programs.install(p, p.permissions);
      final service = JavascriptScreenService(programs);
      for (final url in [
        'http://example.com/a',
        'https://u@example.com/a',
        'https://127.0.0.1/a',
        'https://device.local/a',
        'https://example.com:8443/a',
        'https://evil.org/a',
      ]) {
        expect(
          () => service.remoteTrack(p.id, {
            'id': 'demo',
            'title': 'Demo',
            'url': url,
          }),
          throwsFormatException,
        );
      }
      for (final ip in [
        '127.0.0.1',
        '10.0.0.2',
        '192.168.1.1',
        '172.16.0.1',
        '169.254.1.1',
        '100.64.0.1',
        '::1',
        'fc00::1',
        '::ffff:127.0.0.1',
        '2001:db8::1',
      ]) {
        expect(publicStreamAddress(InternetAddress(ip)), isFalse, reason: ip);
      }
      expect(publicStreamAddress(InternetAddress('8.8.8.8')), isTrue);
      await expectLater(
        resolvePublicStream(Uri.parse('https://device.local/a'), () => true),
        throwsFormatException,
      );
    },
  );
  test('automatic remote playback on open is rejected', () async {
    final programs = ProgramController(Registry());
    addTearDown(programs.dispose);
    final p = networkPackage(
      code: "function run(){return {view:{type:'text',text:'x'},playRemote:{id:'x',title:'x',url:'https://example.com/a'}};}",
    );
    await programs.install(p, p.permissions);
    expect(await programs.invoke(p.id, 'screen', {'action': 'open'}), isNull);
    expect(programs.screenAudio, isEmpty);
  });
}
