import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/platform/playback_diagnostics.dart';
import 'package:rp_music/platform/android_notifications.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer;

class FakeDiagnostics extends AndroidNotifications {
  @override
  Future<Map<String, dynamic>> diagnostics() async => {
    'foreground': true,
    'api': 36,
    'mediaNotifications': 1,
  };
}

void main() {
  testWidgets(
    'diagnóstico copia errores completos con texto ampliado en móvil',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final handler = MusicHandler(player: FakePlayer());
      final source = StreamController<Object>();
      handler.observeSystemErrors(source.stream);
      source.add(
        PlatformException(
          code: 'startForegroundService() not allowed',
          message: 'mAllowStartForeground false',
        ),
      );
      await tester.pump();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    showDiagnostics(context, handler, FakeDiagnostics()),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copiar texto'));
      await tester.pumpAndSettle();
      expect(copied, contains('mAllowStartForeground false'));
      expect(copied, contains('api: 36'));
      expect(find.text('Texto copiado.'), findsOneWidget);
      expect(find.text('Exportar log'), findsOneWidget);
      expect(find.text('Importar log'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(handler.close);
      await tester.runAsync(source.close);
    },
  );
  test('registro multimedia mantiene un límite de cien eventos', () async {
    final handler = MusicHandler(player: FakePlayer());
    for (var i = 0; i < 150; i++) {
      handler.recordEvent('Evento $i');
    }
    expect(handler.diagnosticEvents.length, 100);
    expect(handler.diagnosticEvents.last, contains('Evento 149'));
    await handler.close();
  });
}
