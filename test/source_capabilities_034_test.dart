import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/extensions/extension_navigation.dart';
import 'package:rp_music/sources/extension_source_service.dart';
import 'package:rp_music/sources/source_download.dart';
import 'package:rp_music/domain/track.dart';

import 'extension_source_test.dart' show cloudPackage;
import 'program_system_test.dart' show Registry;

void main() {
  test('dos accesos no cambian silenciosamente la fuente elegida', () async {
    final first = cloudPackage();
    final second = ProgramPackage.parse({
      ...first.toJson(),
      'id': 'test.second',
    });
    final programs = ProgramController(Registry());
    await programs.install(first, first.permissions);
    await programs.install(second, second.permissions);
    expect(extensionDestinations(programs, 'windows').map((e) => e.id), [
      first.id,
      second.id,
    ]);
    final service = ExtensionSourceService(programs, platform: 'windows');
    expect(service.available(first.id), isTrue);
    expect(service.available(second.id), isFalse);
    await programs.choose('source', second.id);
    expect(service.available(first.id), isFalse);
    expect(service.available(second.id), isTrue);
    await programs.setEnabled(second.id, false);
    expect(extensionDestinations(programs, 'windows').map((e) => e.id), [
      first.id,
    ]);
    programs.dispose();
  });
  test('descargar exige permiso separado antes de resolver audio', () async {
    final package = cloudPackage();
    final programs = ProgramController(Registry());
    await programs.install(package, package.permissions);
    var requests = 0;
    final service = ExtensionSourceService(
      programs,
      platform: 'windows',
      transport: (_, _) async {
        requests++;
        return {};
      },
    );
    await expectLater(
      SourceDownload.save(
        Track(
          id: ExtensionSourceService.trackId(package.id, 'song'),
          title: 'Demo',
          folder: '.',
          sourceId: package.id,
        ),
        service,
      ),
      throwsFormatException,
    );
    expect(requests, 0);
    programs.dispose();
  });
  test('textos propios limitados y compatibles con manifiestos anteriores', () {
    final package = cloudPackage();
    final map = package.toJson();
    final config = Map<String, dynamic>.from(map['sourceConfig'] as Map);
    config['searchLabel'] = 'Pega un enlace';
    config['description'] = 'Solo fragmentos públicos';
    map['sourceConfig'] = config;
    expect(ProgramPackage.parse(map).sourceSpec!.searchLabel, 'Pega un enlace');
    config['description'] = 'x' * 401;
    expect(() => ProgramPackage.parse(map), throwsFormatException);
  });
}
