import 'dart:convert';
import 'dart:isolate';
import 'dart:io';

import 'package:flutter_qjs_next/quickjs/quickjs_runtime2.dart';
import 'package:flutter_qjs_next/web/web_apis.dart';

// A fresh engine per event: only explicit JSON state survives. No fetch/XHR,
// filesystem, Node modules or app callbacks are installed in this runtime.
void _javascriptWorker((String, String?, SendPort) request) {
  QuickJsRuntime2? engine;
  late Map<String, dynamic> message;
  try {
    engine = QuickJsRuntime2(
      timeout: 1000,
      memoryLimit: 32 * 1024 * 1024,
      // Debug Windows builds need room for ordinary nested JSON responses.
      // Remain below the Windows thread's 1 MiB stack; never disable this limit.
      stackSize: Platform.isWindows ? 512 * 1024 : 1024 * 1024,
      autoExecutePendingJobs: false,
      webApis: const JsWebApis.none(),
    );
    final lockdown = engine.evaluate('''
      globalThis.fetch = undefined; globalThis.XMLHttpRequest = undefined;
      globalThis.setTimeout = undefined; globalThis.setInterval = undefined;
      globalThis.sendMessage = undefined;
      globalThis.console = {log:function(){},warn:function(){},error:function(){}};
    ''');
    if (lockdown.isError) {
      throw const FormatException('No se pudo preparar JavaScript.');
    }
    final body = request.$2 == null
        ? "if(typeof run !== 'function') throw Error('Se requiere run(input)'); return '{}';"
        : "if(typeof run !== 'function') throw Error('Se requiere run(input)'); return JSON.stringify(run(JSON.parse(${jsonEncode(request.$2)})));";
    final result = engine.evaluate('''
(function(){"use strict";
${request.$1}
$body
})()
''');
    if (result.isError) {
      throw const FormatException(
        'Error de JavaScript o límite de ejecución alcanzado.',
      );
    }
    final text = result.stringResult;
    if (utf8.encode(text).length > 512 * 1024) {
      throw const FormatException('Respuesta JavaScript demasiado grande.');
    }
    final value = jsonDecode(text);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('run debe devolver un objeto JSON síncrono.');
    }
    message = {'value': value};
  } catch (error) {
    message = {
      'error': Platform.environment['FLUTTER_TEST'] == 'true'
          ? error.toString()
          : 'No se pudo ejecutar JavaScript. Revisa el paquete o sus límites.',
    };
  } finally {
    engine?.dispose();
  }
  // Dispose the native heap before signalling completion. The caller may kill
  // the isolate immediately after receiving this message.
  request.$3.send(message);
}

class JavascriptProgramRuntime {
  static Future<Map<String, dynamic>> _call(
    String source,
    Map<String, dynamic>? input,
  ) async {
    if (utf8.encode(source).length > 65536) {
      throw const FormatException('Código JavaScript mayor de 64 KB.');
    }
    final encoded = input == null ? null : jsonEncode(input);
    if (encoded != null && utf8.encode(encoded).length > 4 * 1024 * 1024) {
      throw const FormatException('Entrada JavaScript demasiado grande.');
    }
    final port = ReceivePort();
    Isolate? worker;
    try {
      worker = await Isolate.spawn(_javascriptWorker, (
        source,
        encoded,
        port.sendPort,
      ));
      final result = await port.first.timeout(
        const Duration(seconds: 4),
        onTimeout: () => {'error': 'Límite de tiempo JavaScript excedido.'},
      );
      if (result is! Map || result['error'] != null) {
        throw FormatException(
          Platform.environment['FLUTTER_TEST'] == 'true'
              ? '${result is Map ? result['error'] : result}'
              : 'JavaScript falló o excedió sus límites.',
        );
      }
      return Map<String, dynamic>.from(result['value'] as Map);
    } finally {
      worker?.kill(priority: Isolate.immediate);
      port.close();
    }
  }

  static Future<void> validate(String source) async {
    await _call(source, null);
  }

  static Future<Map<String, dynamic>> execute(
    String source,
    Map<String, dynamic> input,
  ) => _call(source, input);
}
