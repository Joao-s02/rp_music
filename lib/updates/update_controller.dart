import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../app/app_version.dart';
import '../data/local_store.dart';

class ReleaseVersion implements Comparable<ReleaseVersion> {
  ReleaseVersion(this.parts, this.pre);
  final List<int> parts;
  final List<String> pre;
  static ReleaseVersion parse(String text) {
    final match = RegExp(
      r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$',
    ).firstMatch(text);
    if (match == null) throw const FormatException('Versión no válida');
    return ReleaseVersion([
      for (var i = 1; i <= 3; i++) int.parse(match[i]!),
    ], match[4]?.split('.') ?? []);
  }

  String get core => parts.join('.');
  @override
  int compareTo(ReleaseVersion other) {
    for (var i = 0; i < 3; i++) {
      final c = parts[i].compareTo(other.parts[i]);
      if (c != 0) return c;
    }
    if (pre.isEmpty || other.pre.isEmpty) {
      return pre.isEmpty == other.pre.isEmpty
          ? 0
          : pre.isEmpty
          ? 1
          : -1;
    }
    for (var i = 0; i < pre.length && i < other.pre.length; i++) {
      final a = int.tryParse(pre[i]);
      final b = int.tryParse(other.pre[i]);
      final c = a != null && b != null
          ? a.compareTo(b)
          : a != null
          ? -1
          : b != null
          ? 1
          : pre[i].compareTo(other.pre[i]);
      if (c != 0) return c;
    }
    return pre.length.compareTo(other.pre.length);
  }
}

class AppRelease {
  AppRelease({
    required this.tag,
    required this.notes,
    required this.url,
    required this.size,
    required this.digest,
    required this.page,
  });
  final String tag, notes, digest, page;
  final Uri url;
  final int size;
  ReleaseVersion get version => ReleaseVersion.parse(tag);
}

// Only public assets of this repository may be selected; redirects are checked
// again before each request. No account tokens or library metadata are sent.
AppRelease? selectRelease(
  List<dynamic> releases, {
  required String current,
  required bool arm64,
  required bool previews,
  required bool android,
  String? skipped,
}) {
  final installed = ReleaseVersion.parse(current);
  final candidates = <AppRelease>[];
  for (final raw in releases) {
    try {
      final release = Map<String, dynamic>.from(raw as Map);
      if (release['draft'] == true ||
          (!previews && release['prerelease'] == true)) {
        continue;
      }
      final tag = release['tag_name'] as String;
      final version = ReleaseVersion.parse(tag);
      if (version.compareTo(installed) <= 0 ||
          tag == skipped ||
          (!previews && version.pre.isNotEmpty)) {
        continue;
      }
      final assets = (release['assets'] as List).cast<Map>();
      final base = 'RP-Music-${version.core}';
      final wanted = android
          ? (arm64 ? '$base-android-arm64.apk' : '$base-android.apk')
          : '$base-windows-x64.zip';
      final asset =
          assets.where((a) => a['name'] == wanted).firstOrNull ??
          (android && arm64
              ? assets
                    .where((a) => a['name'] == '$base-android.apk')
                    .firstOrNull
              : null);
      if (asset == null || asset['state'] != 'uploaded') continue;
      final uri = Uri.parse(asset['browser_download_url'] as String);
      final digest = asset['digest'] as String? ?? '';
      final size = (asset['size'] as num).toInt();
      if (!validAssetUrl(uri) ||
          !RegExp(r'^sha256:[a-fA-F0-9]{64}$').hasMatch(digest) ||
          size <= 0 ||
          size > 300 * 1024 * 1024) {
        continue;
      }
      candidates.add(
        AppRelease(
          tag: tag,
          notes: release['body'] as String? ?? '',
          url: uri,
          size: size,
          digest: digest.substring(7).toLowerCase(),
          page:
              'https://github.com/Joao-s02/rp_music/releases/tag/${Uri.encodeComponent(tag)}',
        ),
      );
    } catch (_) {
      continue;
    }
  }
  candidates.sort((a, b) => b.version.compareTo(a.version));
  return candidates.firstOrNull;
}

bool validAssetUrl(Uri uri) =>
    uri.scheme == 'https' &&
    uri.host == 'github.com' &&
    uri.userInfo.isEmpty &&
    uri.port == 443 &&
    uri.path.startsWith('/Joao-s02/rp_music/releases/download/');
bool validDownloadHost(Uri uri) =>
    uri.scheme == 'https' &&
    uri.userInfo.isEmpty &&
    uri.port == 443 &&
    (validAssetUrl(uri) ||
        uri.host == 'release-assets.githubusercontent.com' ||
        uri.host == 'objects.githubusercontent.com');

abstract class UpdatePlatform {
  Future<Map<String, dynamic>> info();
  Future<bool> install(File apk, AppRelease release);
  Future<void> openPage(String url);
  Future<void> reveal(File file) async {}
}

class NativeUpdatePlatform implements UpdatePlatform {
  static const channel = MethodChannel('rp_music/updates');
  @override
  Future<Map<String, dynamic>> info() async => Platform.isAndroid
      ? Map<String, dynamic>.from(
          await channel.invokeMapMethod<String, dynamic>('info') ?? {},
        )
      : {
          'arm64': false,
          'directory':
              '${(await getApplicationSupportDirectory()).path}/updates',
        };
  @override
  Future<bool> install(File apk, AppRelease release) async =>
      await channel.invokeMethod<bool>('install', {
        'path': apk.path,
        'sha256': release.digest,
        'version': release.version.core,
      }) ??
      false;
  @override
  Future<void> reveal(File file) async {
    if (Platform.isWindows) {
      await Process.start('explorer.exe', ['/select,', file.path]);
    }
  }

  @override
  Future<void> openPage(String url) async {
    if (!url.startsWith('https://github.com/Joao-s02/rp_music/releases/tag/')) {
      throw const FormatException('Enlace no válido');
    }
    if (Platform.isAndroid) {
      await channel.invokeMethod<void>('openPage', {'url': url});
    } else if (Platform.isWindows) {
      await Process.run('rundll32.exe', ['url.dll,FileProtocolHandler', url]);
    }
  }
}

class UpdateController extends ChangeNotifier {
  UpdateController(
    this.store, {
    UpdatePlatform? platform,
    HttpClient Function()? clientFactory,
    bool? android,
  }) : platform = platform ?? NativeUpdatePlatform(),
       _clientFactory = clientFactory ?? HttpClient.new,
       android = android ?? Platform.isAndroid;
  final LocalStore store;
  final UpdatePlatform platform;
  final HttpClient Function() _clientFactory;
  final bool android;
  bool automatic = true,
      previews = true,
      checking = false,
      downloading = false,
      installing = false;
  bool _disposed = false, _cancelled = false;
  int noticeSerial = 0;
  double progress = 0;
  String? message, skipped;
  DateTime? lastCheck;
  AppRelease? available;
  File? downloaded;
  Map<String, dynamic> _info = {};
  bool get manualAndroidUpdates => android && _info['directInstall'] == false;
  HttpClient? _downloadClient;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() async {
    try {
      final data = await store.load();
      automatic = data['automatic'] as bool? ?? true;
      previews = data['previews'] as bool? ?? true;
      skipped = data['skipped'] as String?;
      lastCheck = DateTime.tryParse(data['lastCheck'] as String? ?? '');
    } catch (_) {
      automatic = true;
      previews = true;
      skipped = null;
      lastCheck = null;
    }
    if (!_disposed) unawaited(check());
  }

  Future<void> _save() async {
    try {
      await store.save({
        'automatic': automatic,
        'previews': previews,
        'skipped': skipped,
        'lastCheck': lastCheck?.toUtc().toIso8601String(),
      });
    } catch (_) {
      message = 'No se pudieron guardar las preferencias de actualización.';
    }
  }

  Future<void> setAutomatic(bool value) async {
    automatic = value;
    _notify();
    await _save();
  }

  Future<void> setPreviews(bool value) async {
    if (downloading || installing) return;
    previews = value;
    available = null;
    downloaded = null;
    _notify();
    await _save();
    await check(manual: true);
  }

  Future<void> skip() async {
    if (downloading || installing) return;
    skipped = available?.tag;
    available = null;
    _notify();
    await _save();
  }

  Future<HttpClientResponse> _get(HttpClient client, Uri uri) async {
    for (var i = 0; i < 6; i++) {
      if (uri.host != 'api.github.com' && !validDownloadHost(uri)) {
        throw const FormatException('Servidor no permitido');
      }
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));
      request.followRedirects = false;
      request.headers.set(HttpHeaders.userAgentHeader, 'RP-Music/$appVersion');
      request.headers.set(
        HttpHeaders.acceptHeader,
        uri.host == 'api.github.com'
            ? 'application/vnd.github+json'
            : 'application/octet-stream',
      );
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
        final next = response.headers.value(HttpHeaders.locationHeader);
        if (next == null) throw const HttpException('Redirección incompleta');
        final resolved = uri.resolve(next);
        if (!validDownloadHost(resolved)) {
          throw const FormatException('Redirección no permitida');
        }
        // Release assets redirect without useful bodies. Close their stream.
        unawaited(response.drain<void>().catchError((Object _) {}));
        uri = resolved;
        continue;
      }
      if (response.statusCode != 200) {
        throw HttpException('Respuesta ${response.statusCode}');
      }
      return response;
    }
    throw const HttpException('Demasiadas redirecciones');
  }

  Future<void> check({bool manual = false}) async {
    if (checking || downloading || installing || _disposed) return;
    final now = DateTime.now();
    if (!manual &&
        (!automatic ||
            (lastCheck != null &&
                now.difference(lastCheck!) < const Duration(days: 1)))) {
      return;
    }
    checking = true;
    message = null;
    _notify();
    final client = _clientFactory()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      _info = await platform.info().timeout(const Duration(seconds: 5));
      final response = await _get(
        client,
        Uri.https('api.github.com', '/repos/Joao-s02/rp_music/releases', {
          'per_page': '30',
        }),
      );
      final bytes = <int>[];
      await for (final chunk in response.timeout(const Duration(seconds: 15))) {
        bytes.addAll(chunk);
        if (bytes.length > 2 * 1024 * 1024) {
          throw const FormatException('Respuesta demasiado grande');
        }
      }
      if (_disposed) return;
      available = selectRelease(
        jsonDecode(utf8.decode(bytes)) as List,
        current: appRelease,
        arm64: _info['arm64'] == true,
        previews: previews,
        android: android,
        skipped: manual ? null : skipped,
      );
      lastCheck = now;
      downloaded = null;
      if (available != null) noticeSerial++;
      if (manual) {
        message = available == null
            ? 'No hay una actualización compatible más reciente en este canal.'
            : 'Actualización disponible: ${available!.tag}';
      }
      await _save();
    } catch (_) {
      if (manual) message = 'No se pudo consultar GitHub. Revisa tu conexión e inténtalo después.';
      // Also back off failed automatic requests instead of retrying every launch.
      lastCheck = now;
      await _save();
    } finally {
      client.close(force: true);
      checking = false;
      _notify();
    }
  }

  Future<void> download() async {
    final release = available;
    if (release == null || downloading || installing) return;
    if (manualAndroidUpdates) {
      await openRelease();
      return;
    }
    downloading = true;
    _cancelled = false;
    downloaded = null;
    progress = 0;
    message = null;
    _notify();
    File? partial;
    final client = _clientFactory()
      ..connectionTimeout = const Duration(seconds: 10);
    _downloadClient = client;
    try {
      _info = await platform.info().timeout(const Duration(seconds: 5));
      if (_cancelled) return;
      final directory = Directory(_info['directory'] as String);
      await directory.create(recursive: true);
      final target = File(
        '${directory.path}/rp-music-update.${android ? 'apk' : 'zip'}',
      );
      partial = File('${target.path}.part');
      final response = await _get(client, release.url);
      if (response.contentLength >= 0 &&
          response.contentLength != release.size) {
        throw const FormatException('Tamaño no válido');
      }
      var received = 0;
      final sink = await partial.open(mode: FileMode.write);
      try {
        await for (final chunk in response.timeout(
          const Duration(seconds: 20),
        )) {
          if (_cancelled) throw const HttpException('Cancelado');
          received += chunk.length;
          if (received > release.size) {
            throw const FormatException('Tamaño no válido');
          }
          await sink.writeFrom(chunk);
          progress = received / release.size;
          _notify();
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      if (_cancelled) throw const HttpException('Cancelado');
      if (received != release.size ||
          (await sha256.bind(partial.openRead()).first).toString() !=
              release.digest) {
        throw const FormatException('La descarga no coincide con su SHA-256');
      }
      if (_cancelled) throw const HttpException('Cancelado');
      if (await target.exists()) await target.delete();
      downloaded = await partial.rename(target.path);
      message = android ? 'Descarga verificada. Pulsa Instalar actualización.' : 'ZIP verificado. Extrae la nueva versión en otra carpeta y cierra la anterior desde la bandeja.';
    } catch (_) {
      message = _cancelled
          ? 'Descarga cancelada.'
          : 'No se pudo completar una descarga válida. Puedes reintentarlo.';
    } finally {
      client.close(force: true);
      _downloadClient = null;
      try {
        if (partial != null && await partial.exists()) await partial.delete();
      } on FileSystemException {
        /* A partial file is never accepted for installation. */
      }
      downloading = false;
      _notify();
    }
  }

  void cancelDownload() {
    _cancelled = true;
    _downloadClient?.close(force: true);
  }

  Future<void> install() async {
    if (manualAndroidUpdates) {
      await openRelease();
      return;
    }
    final release = available;
    final file = downloaded;
    if (release == null || file == null || installing || downloading) return;
    installing = true;
    _notify();
    try {
      final opened = await platform.install(file, release);
      message = opened
          ? 'Confirma la actualización en el instalador de Android.'
          : 'Habilita esta fuente de instalación y vuelve a pulsar Instalar actualización.';
    } catch (_) {
      message = 'Android rechazó el paquete o la instalación. La app actual se conserva.';
    } finally {
      installing = false;
    }
    _notify();
  }

  Future<void> revealDownload() async {
    final file = downloaded;
    if (file == null) return;
    try {
      await platform.reveal(file);
    } catch (_) {
      message = 'No se pudo mostrar el archivo descargado: ${file.path}';
      _notify();
    }
  }

  Future<void> openRelease() async {
    if (available == null) return;
    try {
      await platform.openPage(available!.page);
      if (manualAndroidUpdates) {
        message = 'Descarga el APK desde la página oficial y ábrelo en Archivos para actualizar sin desinstalar.';
        _notify();
      }
    } catch (_) {
      message = 'No se pudo abrir la descarga.';
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    cancelDownload();
    super.dispose();
  }
}
