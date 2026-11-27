import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rp_music/app/player_equalizer.dart';
import 'package:rp_music/playback/equalizer_settings.dart';
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
    EqualizerEffects? effects,
  }) async {
    equalizerEnabled = enabled;
    if (gains != null) equalizerGains = List.unmodifiable(gains);
    if (effects != null) equalizerEffects = effects;
  }
}

void main() {
  test('portable profiles retain effects and map gain by frequency', () {
    const profile = EqualizerProfile(
      name: 'Audífonos',
      frequencies: [100, 400],
      gains: [-4, 4],
      effects: EqualizerEffects(
        preamp: -6,
        balance: .4,
        limiter: true,
        filters: [ParametricBand(hz: 1500, gain: -3, q: 2)],
      ),
    );
    final imported = EqualizerProfile.fromJson(profile.toJson());
    expect(imported.toJson(), profile.toJson());
    expect(imported.gainsFor([31, 200, 1000]), [-4, 0, 4]);
    expect(
      () => EqualizerProfile.fromJson({
        ...profile.toJson(),
        'frequencies': [400, 100],
      }),
      throwsFormatException,
    );
  });

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

    final graph = find.byKey(const ValueKey('equalizer-graph'));
    await tester.ensureVisible(graph);
    final bounds = tester.getRect(graph);
    await tester.dragFrom(
      Offset(bounds.left + bounds.width * .03, bounds.center.dy),
      const Offset(0, -40),
    );
    await tester.pumpAndSettle();
    expect(audio.equalizerGains.first, greaterThan(2));
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
