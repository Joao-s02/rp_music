import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'program_package.dart';
import '../app/app_version.dart';

class CatalogEntry {
  CatalogEntry(
    this.id,
    this.name,
    this.version,
    this.description,
    this.path,
    this.digest, {
    this.minAppVersion = '0.3.0',
  });
  final String id, name, version, description, path, digest;
  final String minAppVersion;

  bool offersUpdate(String installedVersion) {
    List<int>? numbers(String value) {
      if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) return null;
      return value.split('.').map(int.parse).toList();
    }

    final remote = numbers(version);
    final local = numbers(installedVersion);
    if (remote == null || local == null) return false;
    for (var i = 0; i < 3; i++) {
      if (remote[i] != local[i]) return remote[i] > local[i];
    }
    return false;
  }
}

class ProgramCatalog {
  ProgramCatalog(this.repository, this.branch, this.entries);
  final String repository, branch;
  final List<CatalogEntry> entries;

  static String repositoryFrom(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'github.com' ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      throw const FormatException(
        'Usa un enlace https://github.com/autor/repositorio',
      );
    }
    final parts = uri.pathSegments.where((p) => p.isNotEmpty).toList();
    if (parts.length != 2 ||
        parts.any(
          (p) =>
              !RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(p) ||
              p == '.' ||
              p == '..',
        )) {
      throw const FormatException(
        'Introduce el enlace principal del repositorio.',
      );
    }
    return parts.join('/');
  }

  static Future<List<int>> read(Uri uri, int limit) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      return await (() async {
        final request = await client.getUrl(uri);
        request.followRedirects = false;
        request.headers.set('User-Agent', 'RP-Music');
        final response = await request.close();
        if (response.statusCode != 200) {
          throw const FormatException(
            'No se pudo descargar. Comprueba el enlace, la conexión o el límite de GitHub.',
          );
        }
        if (response.contentLength > limit) {
          throw const FormatException('El archivo supera el tamaño permitido.');
        }
        final bytes = <int>[];
        await for (final chunk in response) {
          if (bytes.length + chunk.length > limit) {
            throw const FormatException(
              'El archivo supera el tamaño permitido.',
            );
          }
          bytes.addAll(chunk);
        }
        return bytes;
      })().timeout(const Duration(seconds: 25));
    } finally {
      client.close(force: true);
    }
  }

  static Future<ProgramCatalog> load(String link) async {
    final repo = repositoryFrom(link);
    final metadata = jsonDecode(
      utf8.decode(
        await read(Uri.https('api.github.com', '/repos/$repo'), 128 * 1024),
      ),
    ) as Map;
    final branch = metadata['default_branch'];
    if (branch is! String || branch.isEmpty) {
      throw const FormatException('Repositorio sin rama principal.');
    }
    final ref = jsonDecode(
      utf8.decode(
        await read(
          Uri.https('api.github.com', '/repos/$repo/git/ref/heads/$branch'),
          32 * 1024,
        ),
      ),
    ) as Map;
    final revision = (ref['object'] as Map)['sha'];
    if (revision is! String || !RegExp(r'^[a-f0-9]{40}$').hasMatch(revision)) {
      throw const FormatException(
        'No se pudo resolver la versión del repositorio.',
      );
    }
    final data = jsonDecode(
      utf8.decode(
        await read(
          Uri.https(
            'raw.githubusercontent.com',
            '/$repo/$revision/catalog.json',
          ),
          128 * 1024,
        ),
      ),
    );
    return parse(repo, revision, data);
  }

  static ProgramCatalog parse(
    String repo,
    String branch,
    dynamic data, {
    String hostVersion = appVersion,
  }) {
    if (data is! Map ||
        data['schemaVersion'] != 1 ||
        data['extensions'] is! List ||
        (data['extensions'] as List).length > 100) {
      throw const FormatException('Catálogo incompatible.');
    }
    final entries = <CatalogEntry>[];
    final ids = <String>{};
    for (final original in data['extensions']) {
      if (original is! Map) throw const FormatException('Entrada inválida.');
      Map row = original;
      final variants = original['versions'] ?? [];
      if (variants is! List || variants.length > 8) {
        throw const FormatException('Variantes inválidas.');
      }
      for (final candidate in variants) {
        if (candidate is! Map ||
            candidate['id'] != original['id'] ||
            candidate['version'] is! String ||
            candidate['minAppVersion'] is! String) {
          throw const FormatException('Variante inválida.');
        }
        if (versionAtLeast(hostVersion, candidate['minAppVersion']) &&
            versionAtLeast(candidate['version'], row['version'] as String)) {
          row = candidate;
        }
      }
      final minimum = row['minAppVersion'] ?? '0.3.0';
      if (minimum is! String || !versionAtLeast(hostVersion, minimum)) continue;
      String field(String key, int max) {
        final value = row[key];
        if (value is! String || value.isEmpty || value.length > max) {
          throw const FormatException('Datos de catálogo inválidos.');
        }
        return value;
      }

      final id = field('id', 100);
      final path = field('path', 180);
      final hash = field('sha256', 64);
      if (!ids.add(id) ||
          !RegExp(r'^[a-zA-Z0-9_./-]+[.]rpmx$').hasMatch(path) ||
          path.startsWith('/') ||
          path.split('/').any((p) => p.isEmpty || p == '.' || p == '..') ||
          !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash)) {
        throw const FormatException('Ruta, identidad o verificación inválida.');
      }
      entries.add(
        CatalogEntry(
          id,
          field('name', 80),
          field('version', 40),
          field('description', 500),
          path,
          hash,
          minAppVersion: minimum,
        ),
      );
    }
    return ProgramCatalog(repo, branch, entries);
  }

  Future<ProgramPackage> download(CatalogEntry entry) async {
    final bytes = await read(
      Uri.https(
        'raw.githubusercontent.com',
        '/$repository/$branch/${entry.path}',
      ),
      128 * 1024,
    );
    if (sha256.convert(bytes).toString() != entry.digest) {
      throw const FormatException(
        'El archivo cambió. Vuelve a consultar el catálogo.',
      );
    }
    final package = ProgramPackage.parse(
      Map<String, dynamic>.from(jsonDecode(utf8.decode(bytes)) as Map),
    );
    if (package.id != entry.id ||
        package.version != entry.version ||
        package.name != entry.name ||
        package.description != entry.description) {
      throw const FormatException('El paquete no coincide con el catálogo.');
    }
    return package;
  }
}
