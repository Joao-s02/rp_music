import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/platform/android_notifications.dart';

class TestNotifications extends AndroidNotifications {
  @override
  bool get supported => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('rp_music/system');
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  test(
    'permiso denegado no interrumpe la app y permite abrir ajustes',
    () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return call.method == 'notificationSettings' ? null : false;
          });
      final notifications = TestNotifications();
      await notifications.request(firstLaunch: true);
      expect(notifications.enabled, isFalse);
      expect(calls.first.arguments, {'firstLaunch': true});
      await notifications.openSettings();
      expect(calls.last.method, 'notificationSettings');
      notifications.dispose();
    },
  );
  test('al volver de ajustes se actualiza el estado del permiso', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => true);
    final notifications = TestNotifications();
    await notifications.refresh();
    expect(notifications.enabled, isTrue);
    notifications.dispose();
  });
}
