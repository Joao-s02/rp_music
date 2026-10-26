import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/library_controller.dart';
import 'package:rp_music/data/music_files.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/extensions/program_controller.dart';
import 'package:rp_music/extensions/program_package.dart';
import 'package:rp_music/playback/music_handler.dart';
import 'package:rp_music/sources/youtube_music_api.dart';
import 'package:rp_music/sources/youtube_source_view.dart';

import 'playback_and_ui_test.dart' show FakePlayer;
import 'program_system_test.dart' show Registry;

class DeferredSearch extends YoutubeMusicApi {
  final started = Completer<void>();
  final response = Completer<List<Track>>();
  @override
  Future<List<Track>> search(String query, String extension) {
    started.complete();
    return response.future;
  }
}

void main() {
  testWidgets('búsqueda móvil descarta resultados si desactivas la extensión', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final programs = ProgramController(Registry());
    final audio = MusicHandler(player: FakePlayer());
    final library = LibraryController(Registry(), MusicFiles())
      ..loading = false;
    final api = DeferredSearch();
    await tester.runAsync(() async {
      final raw = jsonDecode(
        await File('examples/extensions/programables/youtube-music.rpmx')
            .readAsString(),
      ) as Map;
      final package = ProgramPackage.parse(Map<String, dynamic>.from(raw));
      await programs.install(package, package.permissions);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: YoutubeSourceView(
          programs: programs,
          extensionId: 'rp.youtube-music',
          audio: audio,
          library: library,
          api: api,
          platformSupported: () => true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Demo');
    await tester.tap(find.byTooltip('Buscar'));
    for (var i = 0; i < 50 && !api.started.isCompleted; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
    expect(api.started.isCompleted, isTrue);
    await tester.runAsync(() async {
      await programs.setEnabled('rp.youtube-music', false);
      api.response.complete([
        const Track(
          id: 'rpmusic-youtube:rp.youtube-music:abcdefghijk',
          title: 'Resultado tardío',
          folder: 'YouTube Music',
        ),
      ]);
    });
    await tester.pumpAndSettle();
    expect(find.text('Resultado tardío'), findsNothing);
    expect(
      find.text('Activa esta extensión y elígela como fuente en Extensiones.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await audio.close();
    programs.dispose();
    library.dispose();
  });
}
