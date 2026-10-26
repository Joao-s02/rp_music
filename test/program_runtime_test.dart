import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/extensions/program_runtime.dart';

void main() {
  test('ejecuta un programa Dart instalado con lógica y JSON', () async {
    final result = await ProgramRuntime().execute(
      """
import 'dart:convert';
String run(String input) {
 final Map<String, dynamic> data = jsonDecode(input) as Map<String, dynamic>;
 final List<dynamic> list = data['values'] as List<dynamic>;
 int sum = 0;
 for (int i = 0; i < list.length; i = i + 1) { final int item = list[i] as int; if (item > 2) { sum = sum + item; } }
 return jsonEncode({'sum': sum});
}
""",
      {
        'values': [1, 2, 3, 4],
      },
    );
    expect(result['sum'], 7);
  });
  test('un bucle infinito termina y el motor sigue utilizable', () async {
    final runtime = ProgramRuntime();
    await expectLater(
      runtime.execute(
        'String run(String input) { while (true) {} return input; }',
        {},
        timeout: const Duration(milliseconds: 150),
      ),
      throwsFormatException,
    );
    expect(
      (await runtime.execute('String run(String input) => input;', {
        'ok': true,
      }))['ok'],
      true,
    );
  });
  test('no concede acceso a archivos', () async {
    await expectLater(
      ProgramRuntime().execute(
        "import 'dart:io'; String run(String input) { return File('pubspec.yaml').readAsStringSync(); }",
        {},
      ),
      throwsFormatException,
    );
  });
  test(
    'rechaza fuente sin entrada válida y respuestas que superan bytes UTF-8',
    () async {
      final runtime = ProgramRuntime();
      await expectLater(
        runtime.compile('String otra(String input) => input;'),
        throwsFormatException,
      );
      await expectLater(
        runtime.compile('String run() => "{}";'),
        throwsFormatException,
      );
      await expectLater(
        runtime.execute('String run(String input) => input;', {
          'text': 'á' * 300000,
        }),
        throwsFormatException,
      );
    },
  );
}
