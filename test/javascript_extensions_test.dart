import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/javascript_program_runtime.dart';
import 'package:rp_music/extensions/javascript_view_schema.dart';
import 'package:rp_music/extensions/javascript_screen_view.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/extension_navigation.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'program_system_test.dart' show Registry;
import 'extension_source_test.dart' show cloudPackage;
import 'playback_and_ui_test.dart' show FakePlayer;

ProgramPackage jsPackage({String? code}) => ProgramPackage.parse({
  'apiVersion': 3,
  'engine': 'javascript',
  'id': 'test.javascript',
  'name': 'JS Test',
  'version': '0.1.0',
  'description': 'Synthetic generic screen test',
  'minAppVersion': '0.3.8',
  'permissions': ['navigation.add', 'storage.private'],
  'capabilities': ['screen'],
  'source': code ?? "function run(input){const count=((input.state||{}).count||0)+(input.action==='increment'?1:0);return {state:{count},view:{type:'column',children:[{type:'text',text:'Count '+count},{type:'button',label:'Increment',action:'increment'}]}};}",
});
void main() {
  test('API 2 stays Dart and API 3 survives registry serialization', () {
    expect(cloudPackage().engine, 'dart');
    expect(cloudPackage().toJson()['apiVersion'], 2);
    final js = jsPackage();
    expect(ProgramPackage.parse(js.toJson()).engine, 'javascript');
    expect(
      () => ProgramPackage.parse({
        ...js.toJson(),
        'permissions': ['navigation.add', 'network.http'],
      }),
      throwsFormatException,
    );
    expect(
      () => ProgramPackage.parse({
        ...js.toJson(),
        'capabilities': ['source'],
      }),
      throwsFormatException,
    );
  });
  test('visual tree rejects unknown components, duplicate fields and excessive depth', () {
    expect(
      () => validateJavascriptView({
        'type': 'webview',
        'url': 'https://example.com',
      }),
      throwsFormatException,
    );
    expect(
      () => validateJavascriptView({
        'type': 'column',
        'children': [
          {'type': 'input', 'id': 'same'},
          {'type': 'input', 'id': 'same'},
        ],
      }),
      throwsFormatException,
    );
    dynamic tree = {'type': 'text', 'text': 'x'};
    for (var i = 0; i < 15; i++) {
      tree = {
        'type': 'column',
        'children': [tree],
      };
    }
    expect(() => validateJavascriptView(tree), throwsFormatException);
  });
  test(
    'QuickJS executes real JavaScript with state and no network or Node bridge',
    () async {
      final code = jsPackage().source;
      await JavascriptProgramRuntime.validate(code);
      final result = await JavascriptProgramRuntime.execute(code, {
        'state': {'count': 4},
        'action': 'increment',
      });
      expect(result['state']['count'], 5);
      validateJavascriptView(result['view']);
      final globals = await JavascriptProgramRuntime.execute(
        "function run(){return {fetch:typeof fetch,require:typeof require,process:typeof process,xhr:typeof XMLHttpRequest};}",
        {},
      );
      expect(globals.values, everyElement('undefined'));
    },
  );
  test(
    'engine interrupts a looping script and remains usable afterwards',
    () async {
      final watch=Stopwatch()..start();
      await expectLater(
        JavascriptProgramRuntime.execute('function run(){while(true){}}', {}),
        throwsFormatException,
      );
      expect(watch.elapsedMilliseconds,lessThan(3000));
      debugPrint('Native JS loop interrupted in ${watch.elapsedMilliseconds} ms');
      expect(
        await JavascriptProgramRuntime.execute(
          'function run(){return {ok:true};}',
          {},
        ),
        {'ok': true},
      );
    },
    timeout: const Timeout(Duration(seconds: 15)),
  );
  test(
    'Dart and JavaScript coexist; state restored and malformed views rejected',
    () async {
      final store = Registry();
      final programs = ProgramController(store);
      final cloud = cloudPackage();
      await programs.install(cloud, cloud.permissions);
      final js = jsPackage();
      await programs.install(js, js.permissions);
      expect(programs.owner('source')!.package.id, cloud.id);
      expect(
        extensionDestinations(programs, 'android').map((e) => e.id),
        containsAll([js.id, cloud.id]),
      );
      await programs.invoke(js.id, 'screen', {'action': 'increment'});
      final restored = ProgramController(store);
      await restored.initialize();
      expect(restored.privateData[js.id]!['count'], 1);
      expect(restored.installed[cloud.id]!.package.engine, 'dart');
      final bad = jsPackage(
        code:
            "function run(){return {state:{bad:true},view:{type:'invalid'}};}",
      );
      await restored.install(bad, bad.permissions);
      expect(await restored.invoke(bad.id, 'screen', {}), null);
      expect(restored.privateData[js.id]!['count'], 1);
      await restored.setEnabled(js.id, false);
      expect(await restored.invoke(js.id, 'screen', {}), null);
      programs.dispose();
      restored.dispose();
    },
  );
  testWidgets('JavaScript renders own tree and handles buttons at 360px', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final programs = ProgramController(Registry());
    final js = jsPackage();
    await tester.runAsync(() => programs.install(js, js.permissions));
    final library = LibraryController(Registry(), MusicFiles());
    final audio = MusicHandler(player: FakePlayer());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JavascriptScreenView(
            programs: programs,
            extensionId: js.id,
            library: library,
            audio: audio,
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 800)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Count 0'), findsOneWidget);
    await tester.tap(find.text('Increment'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 800)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Count 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await programs.setEnabled(js.id, false);
    await tester.pumpAndSettle();
    expect(find.text('Extensión desactivada o sin permisos.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await audio.close();
    library.dispose();
    programs.dispose();
  });
}
