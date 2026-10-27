import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/lyrics_view.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer;

class PositionPlayer extends FakePlayer {
  final positions = StreamController<Duration>.broadcast();
  @override
  Stream<Duration> get positionStream => positions.stream;
  @override
  Future<void> dispose() async {
    await super.dispose();
    unawaited(positions.close());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('letra guardada sigue posición, retroceso y cambio de canción', (
    tester,
  ) async {
    const id = '/a.mp3';
    final root = (await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp('lyrics_test_');
      final file = File(
        '${directory.path}/lyrics/${sha256.convert(utf8.encode(id))}.lrc',
      );
      await file.parent.create();
      await file.writeAsString('[00:00]Primera\n[00:02]Segunda');
      return directory;
    }))!;
    addTearDown(() => tester.runAsync(() => root.delete(recursive: true)));
    final player = PositionPlayer();
    final audio = MusicHandler(player: player);
    await audio.select([
      const Track(id: id, title: 'A', folder: '.'),
      const Track(id: '/b.mp3', title: 'B', folder: '.'),
    ], 0);
    await tester.pumpWidget(
      MaterialApp(
        home: LyricsView(audio: audio, directory: () async => root),
      ),
    );
    for (var i = 0; i < 10 && find.text('Primera').evaluate().isEmpty; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
    }
    await tester.pumpAndSettle();
    expect(
      find.text('Primera'),
      findsOneWidget,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .join(' | '),
    );
    player.positions.add(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ListTile>(
            find.ancestor(
              of: find.text('Segunda'),
              matching: find.byType(ListTile),
            ),
          )
          .selected,
      isTrue,
    );
    player.positions.add(Duration.zero);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ListTile>(
            find.ancestor(
              of: find.text('Primera'),
              matching: find.byType(ListTile),
            ),
          )
          .selected,
      isTrue,
    );
    await tester.tap(find.text('Segunda'));
    expect(player.position, const Duration(seconds: 2));
    await audio.skipToNext();
    await tester.pumpAndSettle();
    expect(find.text('Primera'), findsNothing);
    expect(find.text('B'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(audio.close);
  });
}
