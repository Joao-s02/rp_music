import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/player_equalizer.dart';
import 'package:rp_music/playback/music_handler.dart';

import 'playback_and_ui_test.dart' show FakePlayer;

class _EqualizerHandler extends MusicHandler {
  _EqualizerHandler() : super(player: FakePlayer());

  @override
  bool get supportsEqualizer => true;

  @override
  List<int> get equalizerFrequencies => const [60, 1000, 6000];

  @override
  Future<void> setEqualizer({
    required bool enabled,
    List<double>? gains,
  }) async {
    equalizerEnabled = enabled;
    if (gains != null) equalizerGains = List.unmodifiable(gains);
  }
}

void main() {
  testWidgets('preset and manual bands share the same audio settings', (
    tester,
  ) async {
    final audio = _EqualizerHandler();
    addTearDown(audio.close);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPlayerEqualizer(context, audio),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Graves'));
    await tester.pumpAndSettle();
    expect(audio.equalizerEnabled, isTrue);
    expect(audio.equalizerGains, [4.0, 0.0, 0.0]);

    await tester.tap(find.text('Avanzado'));
    await tester.pumpAndSettle();
    final firstBand = find.byType(Slider).first;
    await tester.ensureVisible(firstBand);
    await tester.tapAt(tester.getCenter(firstBand));
    await tester.pumpAndSettle();
    expect(audio.equalizerGains.first, closeTo(0, .5));
    expect(audio.equalizerGains.skip(1), [0.0, 0.0]);

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Básico'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Graves'))
          .selected,
      isFalse,
    );
  });
}
