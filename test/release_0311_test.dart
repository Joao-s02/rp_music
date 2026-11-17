import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/track_swipe.dart';
import 'package:rp_music/domain/track.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer;

void main() {
  const track = Track(
    id: 'a',
    title: 'Elegida',
    artist: 'Artista',
    album: 'Original',
    folder: '.',
  );
  testWidgets(
    'deslizar izquierda avanza, derecha vuelve y un roce corto no cambia',
    (tester) async {
      final audio = MusicHandler(player: FakePlayer());
      await audio.select([
        track,
        const Track(id: 'b', title: 'B', folder: '.'),
      ], 0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrackSwipe(
              audio: audio,
              child: const SizedBox(width: 300, height: 300),
            ),
          ),
        ),
      );
      final area = find.byType(TrackSwipe);
      await tester.drag(area, const Offset(-150, 0));
      await tester.pumpAndSettle();
      expect(audio.index, 1);
      await tester.drag(area, const Offset(150, 0));
      await tester.pumpAndSettle();
      expect(audio.index, 0);
      final gesture = await tester.startGesture(tester.getCenter(area));
      await gesture.moveBy(const Offset(-12, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(audio.index, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      await audio.close();
    },
  );
}
