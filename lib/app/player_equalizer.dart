import 'dart:async';

import 'package:flutter/material.dart';

import '../playback/music_handler.dart';

void showPlayerEqualizer(BuildContext context, MusicHandler audio) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _EqualizerSheet(audio: audio),
  );
}

class _EqualizerSheet extends StatefulWidget {
  const _EqualizerSheet({required this.audio});
  final MusicHandler audio;
  @override
  State<_EqualizerSheet> createState() => _EqualizerSheetState();
}

class _EqualizerSheetState extends State<_EqualizerSheet> {
  MusicHandler get audio => widget.audio;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: FractionallySizedBox(
      heightFactor: .75,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          if (audio.supportsEqualizer) ...[
            SwitchListTile(
              title: const Text('Ecualizador'),
              subtitle: audio.equalizerFrequencies.isEmpty
                  ? const Text('Abre una canción para cargar las bandas.')
                  : null,
              value: audio.equalizerEnabled,
              onChanged: (value) =>
                  setState(() => unawaited(audio.setEqualizer(enabled: value))),
            ),
            if (audio.equalizerEnabled && audio.equalizerFrequencies.isNotEmpty)
              ...equalizerControls(),
          ],
        ],
      ),
    ),
  );
  Iterable<Widget> equalizerControls() sync* {
    final frequencies = audio.equalizerFrequencies;
    final min = audio.minEqualizerGain;
    final max = audio.maxEqualizerGain;
    yield ListTile(
      title: const Text('Preajustes'),
      subtitle: Wrap(
        spacing: 8,
        children: [
          for (final (name, gains) in <(String, double Function(int))>[
            ('Plano', (_) => 0),
            ('Graves', (hz) => hz < 200 ? 4 : 0),
            ('Voces', (hz) => hz >= 400 && hz <= 3000 ? 3 : 0),
          ])
            ActionChip(
              label: Text(name),
              onPressed: () => setState(
                () => unawaited(
                  audio.setEqualizer(
                    enabled: true,
                    gains: frequencies.map(gains).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    for (final (index, frequency) in frequencies.indexed) {
      final gains = List.generate(
        frequencies.length,
        (i) => audio.equalizerGains.elementAtOrNull(i) ?? 0.0,
      );
      final gain = gains[index].clamp(min, max);
      yield ListTile(
        title: Text('$frequency Hz'),
        trailing: Text('${gain.toStringAsFixed(1)} dB'),
        subtitle: Slider(
          min: min,
          max: max,
          value: gain,
          onChanged: (value) {
            setState(() {
              gains[index] = value;
              audio.equalizerGains = List.unmodifiable(gains);
            });
          },
          onChangeEnd: (_) => unawaited(audio.setEqualizer(enabled: true)),
        ),
      );
    }
  }
}
