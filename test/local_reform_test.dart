import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rp_music/app/music_theme.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/data/local_store.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/lyrics/lyrics_controller.dart';
import 'package:rp_music/themes/theme_library.dart';

class _EmbeddedFiles extends MusicFiles {
  @override
  Future<String?> embeddedLyrics(String id) async =>
      id == 'embedded' ? '[00:02]Incrustada' : null;
}

void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('rp_reform_');
  });
  tearDown(() => directory.deleteSync(recursive: true));

  test(
    'la actualización descarta solo las letras con origen en línea',
    () async {
      final controller = LyricsController(directory, _EmbeddedFiles());
      addTearDown(controller.dispose);
      final online = controller.file('online');
      await online.parent.create(recursive: true);
      await online.writeAsString('[00:01]En línea');
      final origin = File('${online.path}.origin.json');
      final miss = File('${online.path}.miss.json');
      await origin.writeAsString('{}');
      await miss.writeAsString('{}');
      await controller.save('imported', '[00:01]Importada');

      await controller.purgeOnlineCache();
      await controller.purgeOnlineCache();
      expect(await online.exists(), isFalse);
      expect(await origin.exists(), isFalse);
      expect(await miss.exists(), isFalse);
      expect(await controller.file('imported').exists(), isTrue);
      final lyric = await controller.ensure(
        const Track(id: 'imported', title: 'Importada', folder: '.'),
      );
      expect(lyric!.lines, hasLength(1));
      final embedded = await controller.ensure(
        const Track(id: 'embedded', title: 'Incrustada', folder: '.'),
      );
      expect(embedded!.lines, hasLength(1));
    },
  );

  test('un tema importado se restaura sin catálogo y puede quitarse', () async {
    final store = LocalStore(directory, baseName: 'themes');
    final themes = ThemeLibrary(store);
    addTearDown(themes.dispose);
    await themes.initialize();
    final package = await File('assets/themes/minimalista.rptheme')
        .readAsString();
    await themes.install(package);
    final id = themes.activeId!;
    expect(themes.active!.name, 'Minimalista');
    expect(
      themes.active!.images.keys,
      containsAll(['play', 'pause', 'previous', 'next']),
    );
    await expectLater(themes.install('{"version":2}'), throwsFormatException);
    final custom = MusicAppearance.parse(
      '{"version":1,"name":"Paleta","accent":"#102030","colors":{"surface":"#111111"}}',
    );
    expect(
      musicTheme(Brightness.dark, null, appearance: custom).colorScheme.surface,
      const Color(0xff111111),
    );
    expect(
      () => MusicAppearance.parse(
        '{"version":1,"name":"Roto","accent":"#102030","images":{"play":"AA=="}}',
      ),
      throwsFormatException,
    );

    final restored = ThemeLibrary(store);
    addTearDown(restored.dispose);
    await restored.initialize();
    expect(restored.activeId, id);
    expect(restored.active!.name, 'Minimalista');
    await restored.remove(id);
    expect(restored.installed, isEmpty);
    expect(restored.active, isNull);
  });
  for (final width in [360.0, 1280.0]) {
    testWidgets('Temas conserva navegación y recursos a $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      late ThemeLibrary themes;
      await tester.runAsync(() async {
        themes = ThemeLibrary(LocalStore(directory, baseName: 'themes'));
        await themes.initialize();
        await themes.install(
          await File('assets/themes/minimalista.rptheme').readAsString(),
        );
      });
      addTearDown(themes.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: musicTheme(Brightness.dark, null, appearance: themes.active),
          home: Scaffold(body: ThemeLibraryView(themes: themes)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Importar tema'), findsOneWidget);
      expect(find.text('Minimalista'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() => tester.tap(find.text('RP Music')));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(themes.active, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
