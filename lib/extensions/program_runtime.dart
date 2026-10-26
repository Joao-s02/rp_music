import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';

void _compile((String, SendPort) request) {
  try {
    final unit = parseString(
      content: request.$1,
      throwIfDiagnostics: true,
    ).unit;
    for (final directive in unit.directives) {
      if (directive is! ImportDirective ||
          directive.configurations.isNotEmpty ||
          !{
            'dart:core',
            'dart:convert',
            'dart:math',
          }.contains(directive.uri.stringValue)) {
        throw const FormatException(
          'Solo se admiten imports de dart:core, dart:convert y dart:math.',
        );
      }
    }
    final entries = unit.declarations
        .whereType<FunctionDeclaration>()
        .where((function) => function.name.lexeme == 'run')
        .toList();
    if (entries.length != 1) {
      throw const FormatException('Se requiere String run(String request).');
    }
    final entry = entries.single;
    final parameters = entry.functionExpression.parameters?.parameters;
    if (entry.returnType?.toSource() != 'String' ||
        entry.functionExpression.body.isAsynchronous ||
        parameters == null ||
        parameters.length != 1 ||
        parameters.single is! SimpleFormalParameter ||
        (parameters.single as SimpleFormalParameter).type?.toSource() !=
            'String') {
      throw const FormatException(
        'Se requiere String run(String request), síncrona y sin parámetros opcionales.',
      );
    }
    final compiler = Compiler()
      ..entrypoints.add('package:rp_extension/main.dart');
    final program = compiler.compile({
      'rp_extension': {'main.dart': request.$1},
    });
    request.$2.send(program.write().buffer.asUint8List());
  } catch (error) {
    request.$2.send({
      'error': error.toString().substring(
        0,
        error.toString().length.clamp(0, 700),
      ),
    });
  }
}

void _execute((Uint8List, String, SendPort) request) {
  try {
    final runtime = Runtime(ByteData.sublistView(request.$1));
    // No filesystem, network, process, Flutter or MethodChannel bridges are granted.
    final result = runtime.executeLib('package:rp_extension/main.dart', 'run', [
      $String(request.$2),
    ]);
    final value = result is $Value ? result.$value : result;
    if (value is! String || utf8.encode(value).length > 512 * 1024) {
      throw const FormatException(
        'La extensión debe devolver JSON de hasta 512 KB.',
      );
    }
    request.$3.send(value);
  } catch (error) {
    request.$3.send({
      'error': error.toString().substring(
        0,
        error.toString().length.clamp(0, 700),
      ),
    });
  }
}

/// Experimental interpreter boundary. Isolates provide termination, not an OS memory sandbox.
class ProgramRuntime {
  final _cache = <String, Uint8List>{};
  Future<T> _worker<T>(
    Future<Isolate> Function(SendPort) spawn,
    Duration timeout,
  ) async {
    final port = ReceivePort();
    Isolate? worker;
    try {
      worker = await spawn(port.sendPort);
      final message = await port.first.timeout(timeout);
      if (message is Map && message['error'] != null) {
        throw FormatException(message['error'].toString());
      }
      return message as T;
    } on TimeoutException {
      throw const FormatException('La extensión superó su tiempo permitido.');
    } finally {
      worker?.kill(priority: Isolate.immediate);
      port.close();
    }
  }

  Future<Uint8List> compile(String source) async {
    if (utf8.encode(source).length > 65536) {
      throw const FormatException('Código de extensión mayor de 64 KB.');
    }
    final key = sha256.convert(utf8.encode(source)).toString();
    final cached = _cache[key];
    if (cached != null) return cached;
    final bytes = await _worker<Uint8List>(
      (port) => Isolate.spawn(_compile, (source, port)),
      const Duration(seconds: 12),
    );
    if (bytes.length > 4 * 1024 * 1024) {
      throw const FormatException('Programa compilado demasiado grande.');
    }
    if (_cache.length >= 8) _cache.remove(_cache.keys.first);
    _cache[key] = bytes;
    return bytes;
  }

  Future<Map<String, dynamic>> execute(
    String source,
    Map<String, dynamic> input, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final request = jsonEncode(input);
    if (utf8.encode(request).length > 4 * 1024 * 1024) {
      throw const FormatException(
        'La selección supera el límite de esta extensión.',
      );
    }
    final bytes = await compile(source);
    final response = await _worker<String>(
      (port) => Isolate.spawn(_execute, (bytes, request, port)),
      timeout,
    );
    final decoded = jsonDecode(response);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('La extensión no devolvió un objeto.');
    }
    return decoded;
  }
}
