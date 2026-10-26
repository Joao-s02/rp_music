import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/extensions/program_catalog.dart';

void main() {
  test('solo ofrece actualizar una versión instalada inferior', () {
    final entry = CatalogEntry('a', 'A', '0.2.0', 'D', 'a.rpmx', '');
    expect(entry.offersUpdate('0.1.9'), isTrue);
    expect(entry.offersUpdate('0.2.0'), isFalse);
    expect(entry.offersUpdate('0.3.0'), isFalse);
    expect(entry.offersUpdate('inválida'), isFalse);
  });
  test('solo acepta enlaces principales de GitHub HTTPS', () {
    expect(
      ProgramCatalog.repositoryFrom('https://github.com/autor/repo/'),
      'autor/repo',
    );
    for (final url in [
      'http://github.com/a/b',
      'https://evil.test/a/b',
      'https://github.com/a/b/tree/main',
      'https://github.com/a/b?q=1',
      'https://github.com:444/a/b',
      'https://user@github.com/a/b',
    ]) {
      expect(() => ProgramCatalog.repositoryFrom(url), throwsFormatException);
    }
  });
  test(
    'índice válido y rechaza rutas externas, repetidos y hashes inválidos',
    () {
      final rows = ['biblioteca-viva', 'pulso-nocturno'].map((name) {
        final bytes = File('examples/extensions/programables/$name.rpmx')
            .readAsBytesSync();
        final package = jsonDecode(utf8.decode(bytes)) as Map;
        return {
          for (final key in ['id', 'name', 'version', 'description'])
            key: package[key],
          'path': 'packages/$name.rpmx',
          'sha256': sha256.convert(bytes).toString(),
        };
      }).toList();
      final data = {'schemaVersion': 1, 'extensions': rows};
      final catalog = ProgramCatalog.parse('autor/repo', 'main', data);
      expect(catalog.entries.length, 2);
      for (final path in [
        '../evil.rpmx',
        '/evil.rpmx',
        'https://evil.test/a.rpmx',
        'a//b.rpmx',
      ]) {
        final row = Map<String, dynamic>.from(rows[0] as Map)..['path'] = path;
        expect(
          () => ProgramCatalog.parse('a/b', 'main', {
            'schemaVersion': 1,
            'extensions': [row],
          }),
          throwsFormatException,
        );
      }
      final row = rows[0];
      expect(
        () => ProgramCatalog.parse('a/b', 'main', {
          'schemaVersion': 1,
          'extensions': [row, row],
        }),
        throwsFormatException,
      );
      final bad = Map<String, dynamic>.from(row as Map)..['sha256'] = 'bad';
      expect(
        () => ProgramCatalog.parse('a/b', 'main', {
          'schemaVersion': 1,
          'extensions': [bad],
        }),
        throwsFormatException,
      );
    },
  );
}
