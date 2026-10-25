// Host stages a same-certificate APK with versionCode 7 in the private updates
// directory of the emulator. This test runs as code 6 and never confirms install.
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rp_music/updates/update_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android valida firma, versión e integridad antes de pedir instalación',
    (tester) async {
      await tester.runAsync(() async {
        final platform = NativeUpdatePlatform();
        final info = await platform.info();
        final apk = File('${info['directory']}/rp-music-update.apk');
        for (var i = 0; i < 40 && !await apk.exists(); i++) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
        expect(
          await apk.exists(),
          true,
          reason: 'El host debe preparar el APK de prueba',
        );
        final digest = (await sha256.bind(apk.openRead()).first).toString();
        AppRelease release(String version, String hash) => AppRelease(
          tag: version,
          notes: '',
          url: Uri.https(
            'github.com',
            '/Joao-s02/rp_music/releases/download/test/a.apk',
          ),
          size: 1,
          digest: hash,
          page: '',
        );
        await expectLater(
          platform.install(apk, release('v0.2.4-alpha.2', '0' * 64)),
          throwsA(isA<PlatformException>()),
        );
        await expectLater(
          platform.install(apk, release('v0.2.5', digest)),
          throwsA(isA<PlatformException>()),
        );
        final installerOpened = await platform.install(
          apk,
          release('v0.2.4-alpha.2', digest),
        );
        expect(
          installerOpened,
          false,
          reason: 'Con instalación desde esta fuente deshabilitada debe abrir Ajustes tras validar el APK',
        );
      });
    },
  );
}
