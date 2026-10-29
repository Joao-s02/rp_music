import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:rp_music/updates/update_widgets.dart';
import 'package:rp_music/updates/update_controller.dart';
import 'package:rp_music/data/local_store.dart';
import 'playback_and_ui_test.dart' show MemoryStore;

Map<String, dynamic> fixture({
  String tag = 'v9.0.0-alpha.1',
  bool preview = true,
  String? digest,
  int size = 4,
  String? url,
}) => {
  'tag_name': tag,
  'prerelease': preview,
  'draft': false,
  'body': 'Cambios de prueba',
  'assets': [
    for (final name in ['android-arm64.apk', 'android.apk', 'windows-x64.zip'])
      {
        'name': 'RP-Music-${ReleaseVersion.parse(tag).core}-$name',
        'state': 'uploaded',
        'size': size,
        'digest': 'sha256:${digest ?? 'a' * 64}',
        'browser_download_url':
            url ??
            'https://github.com/Joao-s02/rp_music/releases/download/$tag/RP-Music-${ReleaseVersion.parse(tag).core}-$name',
      },
  ],
};

class FakeHeaders implements HttpHeaders {
  final values = <String, String>{};
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name] = value.toString();
  }

  @override
  String? value(String name) => values[name];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeResponse extends Stream<List<int>> implements HttpClientResponse {
  FakeResponse(this.chunks, {this.statusCode = 200, int? length})
    : contentLength =
          length ?? chunks.fold(0, (total, chunk) => total + chunk.length);
  final List<List<int>> chunks;
  @override
  final int statusCode;
  @override
  final int contentLength;
  @override
  final HttpHeaders headers = FakeHeaders();
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream.fromIterable(chunks).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRequest implements HttpClientRequest {
  FakeRequest(this.response);
  final HttpClientResponse response;
  @override
  final HttpHeaders headers = FakeHeaders();
  @override
  bool followRedirects = false;
  @override
  Future<HttpClientResponse> close() async => response;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeClient implements HttpClient {
  FakeClient(this.response, {this.offline = false});
  final HttpClientResponse response;
  final bool offline;
  @override
  Duration? connectionTimeout;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    if (offline) throw const SocketException('Sin internet de prueba');
    return FakeRequest(response);
  }

  @override
  void close({bool force = false}) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePlatform extends UpdatePlatform {
  FakePlatform(this.directory);
  final Directory directory;
  bool installerAllowed = true;
  int installs = 0;
  bool directInstall = true;
  int pageOpens = 0;
  String? lastPage;
  @override
  Future<Map<String, dynamic>> info() async => {
    'arm64': true,
    'directory': directory.path,
    'directInstall': directInstall,
  };
  @override
  Future<bool> install(File apk, AppRelease release) async {
    installs++;
    return installerAllowed;
  }

  @override
  Future<void> openPage(String url) async {
    pageOpens++;
    lastPage = url;
  }
}

void main() {
  test('ordena versiones numéricas y distingue alfa de estable', () {
    expect(
      ReleaseVersion.parse('v0.2.10-alpha.1')
          .compareTo(ReleaseVersion.parse('0.2.9')),
      greaterThan(0),
    );
    expect(
      ReleaseVersion.parse('0.2.5-alpha.10')
          .compareTo(ReleaseVersion.parse('0.2.5-alpha.2')),
      greaterThan(0),
    );
    expect(
      ReleaseVersion.parse('0.2.5')
          .compareTo(ReleaseVersion.parse('0.2.5-alpha.1')),
      greaterThan(0),
    );
  });
  test('elige arquitectura y canal, ignora borradores, antiguos y versiones omitidas', () {
    final releases = [
      fixture(tag: 'v0.2.3-alpha.1'),
      fixture(),
      fixture(tag: 'v0.2.6', preview: false),
      {...fixture(tag: 'v0.2.7'), 'draft': true},
    ];
    final stable = selectRelease(
      releases,
      current: '0.2.4-alpha.1',
      arm64: true,
      previews: false,
      android: true,
    )!;
    expect(stable.tag, 'v0.2.6');
    expect(stable.url.path, endsWith('-android-arm64.apk'));
    final preview = selectRelease(
      [fixture()],
      current: '0.2.4-alpha.1',
      arm64: false,
      previews: true,
      android: true,
    )!;
    expect(preview.url.path, endsWith('-android.apk'));
    expect(
      selectRelease(
        [fixture()],
        current: '0.2.4-alpha.1',
        arm64: true,
        previews: true,
        android: true,
        skipped: 'v9.0.0-alpha.1',
      ),
      isNull,
    );
  });
  test('rechaza URLs externas, HTTP y digest ausente', () {
    for (final bad in [
      'http://github.com/Joao-s02/rp_music/releases/download/v/a.apk',
      'https://example.com/a.apk',
      'https://github.com/otro/repo/releases/download/a.apk',
    ]) {
      expect(
        selectRelease(
          [fixture(url: bad)],
          current: '0.2.4',
          arm64: true,
          previews: true,
          android: true,
        ),
        isNull,
      );
    }
    final missing = fixture();
    for (final asset in missing['assets'] as List) {
      asset.remove('digest');
    }
    expect(
      selectRelease(
        [missing],
        current: '0.2.4',
        arm64: true,
        previews: true,
        android: true,
      ),
      isNull,
    );
  });
  test('ARM64 usa universal si falta su variante', () {
    final release = fixture();
    (release['assets'] as List).removeAt(0);
    expect(
      selectRelease(
        [release],
        current: '0.2.4',
        arm64: true,
        previews: true,
        android: true,
      )!.url.path,
      endsWith('-android.apk'),
    );
  });
  late Directory temp;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('rp_update_');
  });
  tearDown(() async {
    await temp.delete(recursive: true);
  });
  test(
    'edición sin instalador abre la release sin descargar APK ni instalar',
    () async {
      final platform = FakePlatform(temp)..directInstall = false;
      var requests = 0;
      final updater = UpdateController(
        LocalStore(temp),
        platform: platform,
        android: true,
        clientFactory: () {
          requests++;
          return FakeClient(
            FakeResponse([
              utf8.encode(jsonEncode([fixture()])),
            ]),
          );
        },
      );
      await updater.check(manual: true);
      expect(updater.manualAndroidUpdates, isTrue);
      await updater.download();
      expect(requests, 1);
      expect(updater.downloaded, isNull);
      expect(platform.pageOpens, 1);
      expect(
        platform.lastPage,
        startsWith('https://github.com/Joao-s02/rp_music/releases/tag/'),
      );
      await updater.install();
      expect(platform.installs, 0);
      expect(platform.pageOpens, 2);
      expect(updater.message, contains('sin desinstalar'));
      updater.dispose();
    },
  );
  testWidgets(
    'oferta sin permiso de paquetes muestra descarga web y no pausa audio',
    (tester) async {
      final platform = FakePlatform(temp)..directInstall = false;
      final updates = UpdateController(
        MemoryStore(),
        platform: platform,
        android: true,
        clientFactory: () => FakeClient(
          FakeResponse([
            utf8.encode(jsonEncode([fixture()])),
          ]),
        ),
      );
      await tester.runAsync(() => updates.check(manual: true));
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      var pauses = 0;
      unawaited(
        showUpdateDialog(
          tester.element(find.byType(Scaffold)),
          updates,
          () async {
            pauses++;
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Descargar desde la web'), findsOneWidget);
      expect(find.text('Instalar actualización'), findsNothing);
      await tester.tap(find.text('Descargar desde la web'));
      await tester.pumpAndSettle();
      expect(platform.pageOpens, 1);
      expect(pauses, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      updates.dispose();
    },
  );
  test(
    'sin internet automático es silencioso y respeta la espera diaria',
    () async {
      var calls = 0;
      final updater = UpdateController(
        LocalStore(temp),
        platform: FakePlatform(temp),
        android: true,
        clientFactory: () {
          calls++;
          return FakeClient(FakeResponse([]), offline: true);
        },
      );
      await updater.check();
      expect(updater.message, isNull);
      expect(updater.checking, false);
      await updater.check();
      expect(calls, 1);
      await updater.check(manual: true);
      expect(calls, 2);
      expect(updater.message, contains('conexión'));
      await updater.setAutomatic(false);
      final saved = await LocalStore(temp).load();
      expect(saved['automatic'], false);
      updater.dispose();
    },
  );
  for (final corrupt in [false, true]) {
    test(
      'descarga ${corrupt ? 'corrupta se elimina' : 'válida se verifica antes de instalar'}',
      () async {
        final payload = [1, 2, 3, 4];
        final data = fixture(
          digest: corrupt ? 'a' * 64 : sha256.convert(payload).toString(),
        );
        var calls = 0;
        final platform = FakePlatform(temp);
        final updater = UpdateController(
          LocalStore(temp),
          platform: platform,
          android: true,
          clientFactory: () => FakeClient(
            calls++ == 0
                ? FakeResponse([
                    utf8.encode(jsonEncode([data])),
                  ])
                : FakeResponse([
                    [1, 2],
                    [3, 4],
                  ]),
          ),
        );
        await updater.check(manual: true);
        await updater.download();
        expect(
          await File('${temp.path}/rp-music-update.apk.part').exists(),
          false,
        );
        expect(updater.downloaded != null, !corrupt);
        if (!corrupt) {
          platform.installerAllowed = false;
          await updater.install();
          expect(updater.message, contains('Habilita'));
          platform.installerAllowed = true;
          await updater.install();
          expect(platform.installs, 2);
          expect(updater.message, contains('Confirma'));
        }
        updater.dispose();
      },
    );
  }
  test('cancelar elimina archivo parcial sin ejecutar instalador', () async {
    var calls = 0;
    final platform = FakePlatform(temp);
    final updater = UpdateController(
      LocalStore(temp),
      platform: platform,
      android: true,
      clientFactory: () => FakeClient(
        calls++ == 0
            ? FakeResponse([
                utf8.encode(
                  jsonEncode([
                    fixture(digest: sha256.convert([1, 2, 3, 4]).toString()),
                  ]),
                ),
              ])
            : FakeResponse([
                [1, 2],
                [3, 4],
              ]),
      ),
    );
    updater.addListener(() {
      if (updater.downloading && updater.progress > 0) updater.cancelDownload();
    });
    await updater.check(manual: true);
    await updater.download();
    expect(updater.downloaded, isNull);
    expect(platform.installs, 0);
    expect(await File('${temp.path}/rp-music-update.apk.part').exists(), false);
    expect(updater.message, contains('cancelada'));
    updater.dispose();
  });
}
