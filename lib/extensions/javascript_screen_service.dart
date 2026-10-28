import 'dart:convert';
import 'dart:io';

import '../domain/track.dart';
import 'extension_http_transport.dart';
import 'program_controller.dart';
import 'program_package.dart';

typedef ScreenTransport = Future<Map<String, dynamic>> Function(
  Map<String, dynamic>,
  ProgramPackage,
);

/// Host-controlled continuations: JavaScript never receives a native fetch bridge.
class JavascriptScreenService {
  JavascriptScreenService(this.programs, {ScreenTransport? transport})
    : transport = transport ?? ExtensionHttpTransport.request;
  final ProgramController programs;
  final ScreenTransport transport;

  Future<Map<String, dynamic>> run(
    String id,
    Map<String, dynamic> input, {
    bool Function()? active,
  }) async {
    final installed = programs.installed[id];
    final revision = programs.authorizationRevision;
    void check() {
      if (installed == null ||
          programs.installed[id] != installed ||
          programs.authorizationRevision != revision ||
          !programs.allowed(id, 'navigation.add') ||
          active?.call() == false) {
        throw const FormatException(
          'Operación cancelada o extensión desactivada.',
        );
      }
    }

    var stage = 'start';
    Map<String, dynamic> context = {};
    Map<String, dynamic>? response;
    for (var step = 0; step < 5; step++) {
      check();
      final data = await programs.invoke(
        id,
        'screen',
        {
          ...input,
          'stage': stage,
          'context': context,
          'date': DateTime.now()
              .toUtc()
              .toIso8601String()
              .substring(0, 10)
              .replaceAll('-', ''),
          'response': ?response,
        },
        active: () =>
            active?.call() != false &&
            programs.authorizationRevision == revision,
      );
      check();
      if (data == null) {
        throw const FormatException(
          'La extensión no respondió. Revisa sus permisos y estado.',
        );
      }
      if (!data.containsKey('request')) return data;
      if (step == 4 || !programs.allowed(id, 'network.http')) {
        throw const FormatException(
          'Sin permiso de red o límite de cuatro peticiones alcanzado.',
        );
      }
      context = data['context'] is Map
          ? Map<String, dynamic>.from(data['context'] as Map)
          : {};
      if (utf8.encode(jsonEncode(context)).length > 65536) {
        throw const FormatException('Contexto mayor de 64 KB.');
      }
      stage = data['next'] as String;
      final request = Map<String, dynamic>.from(data['request'] as Map);
      final uri = Uri.tryParse(
        request['url'] is String ? request['url'] as String : '',
      );
      if (uri == null || installed!.package.sourceSpec?.permits(uri) != true) {
        throw const FormatException('Dominio de consulta no autorizado.');
      }
      try {
        response = await transport(request, installed.package);
      } catch (_) {
        // Operational failures are data, not malformed extension outputs.
        response = {'status': 0, 'body': '', 'cookies': <String>[]};
      }
      check();
    }
    throw const FormatException('Demasiadas peticiones.');
  }

  Track remoteTrack(String id, dynamic raw) {
    final item = programs.installed[id];
    if (item == null ||
        !programs.allowed(id, 'playback.control') ||
        !programs.allowed(id, 'network.http') ||
        raw is! Map) {
      throw const FormatException('Audio remoto no autorizado.');
    }
    String text(String key, {String fallback = ''}) {
      final value = raw[key] ?? fallback;
      if (value is! String || value.length > 200) {
        throw const FormatException('Metadatos de audio inválidos.');
      }
      return value;
    }

    final key = text('id');
    final title = text('title');
    final uri = Uri.tryParse(raw['url'] is String ? raw['url'] as String : '');
    if (!RegExp(r'^[a-zA-Z0-9_.-]{1,200}$').hasMatch(key) ||
        title.trim().isEmpty ||
        uri == null ||
        !publicStreamUri(uri) ||
        uri.toString().length > 16000 ||
        (!programs.allowed(id, 'network.stream') &&
            item.package.sourceSpec?.permits(uri) != true)) {
      throw const FormatException(
        'Dirección de audio no autorizada. Solo HTTPS público.',
      );
    }
    final track = Track(
      id: 'rpmusic-screen:$id:$key',
      title: title,
      folder: item.package.name,
      artist: text('artist', fallback: item.package.name),
      album: text('album', fallback: 'En línea'),
      sourceId: id,
      sourceName: item.package.name,
      metadataLoaded: true,
    );
    if (programs.screenAudio.length >= 100) {
      programs.screenAudio.remove(programs.screenAudio.keys.first);
    }
    programs.screenAudio[track.id] = uri;
    return track;
  }
}

bool publicStreamUri(Uri uri) =>
    uri.scheme == 'https' &&
    uri.host.contains('.') &&
    uri.userInfo.isEmpty &&
    (!uri.hasPort || uri.port == 443) &&
    InternetAddress.tryParse(uri.host) == null &&
    ![
      'localhost',
      'local',
      'internal',
      'test',
      'invalid',
      'example',
    ].any((suffix) => uri.host == suffix || uri.host.endsWith('.$suffix'));

bool publicStreamAddress(InternetAddress address) {
  final b = address.rawAddress;
  if (address.type == InternetAddressType.IPv6) {
    // Accept only global unicast; excludes loopback, mapped IPv4 and local ranges.
    return b[0] & 0xe0 == 0x20 &&
        !(b[0] == 0x20 && b[1] == 0x01 && b[2] == 0x0d && b[3] == 0xb8);
  }
  return b[0] != 0 &&
      b[0] != 10 &&
      b[0] != 127 &&
      b[0] < 224 &&
      !(b[0] == 169 && b[1] == 254) &&
      !(b[0] == 172 && b[1] >= 16 && b[1] <= 31) &&
      !(b[0] == 192 && (b[1] == 168 || b[1] == 0)) &&
      !(b[0] == 100 && b[1] >= 64 && b[1] <= 127) &&
      !(b[0] == 198 && (b[1] == 18 || b[1] == 19 || b[1] == 51)) &&
      !(b[0] == 203 && b[1] == 0 && b[2] == 113);
}

/// Validate the stream and each initial redirect without downloading a live feed.
Future<Uri> resolvePublicStream(Uri initial, bool Function() allowed) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
  try {
    return await (() async {
      var uri = initial;
      for (var hop = 0; hop < 5; hop++) {
        if (!allowed() || !publicStreamUri(uri)) {
          throw const FormatException('Audio remoto no autorizado.');
        }
        final addresses = await InternetAddress.lookup(uri.host);
        if (addresses.isEmpty || !addresses.every(publicStreamAddress)) {
          throw const FormatException('Servidor de audio no público.');
        }
        final request = await client.getUrl(uri);
        request.followRedirects = false;
        request.headers.set('Range', 'bytes=0-1023');
        final response = await request.close();
        if (!allowed()) throw const FormatException('Permiso retirado.');
        if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
          final location = response.headers.value('location');
          if (location == null) {
            throw const FormatException('Redirección sin destino.');
          }
          uri = uri.resolve(location);
          await response.listen((_) {}).cancel();
          continue;
        }
        if (response.statusCode != 200 && response.statusCode != 206) {
          throw const FormatException('La emisora no está disponible.');
        }
        await response.listen((_) {}).cancel();
        return uri;
      }
      throw const FormatException('Demasiadas redirecciones de audio.');
    })().timeout(const Duration(seconds: 20));
  } finally {
    client.close(force: true);
  }
}
