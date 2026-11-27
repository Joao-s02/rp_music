import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../playback/music_handler.dart';

void showPlayerEqualizer(BuildContext context, MusicHandler audio) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 620),
    builder: (_) => _EqualizerSheet(audio: audio),
  );
}

enum _EqualizerMode { basic, advanced }

class _EqualizerSheet extends StatefulWidget {
  const _EqualizerSheet({required this.audio});
  final MusicHandler audio;

  @override
  State<_EqualizerSheet> createState() => _EqualizerSheetState();
}

class _EqualizerSheetState extends State<_EqualizerSheet> {
  MusicHandler get audio => widget.audio;
  _EqualizerMode _mode = _EqualizerMode.basic;
  List<double>? _draft;
  bool _applying = false;

  Future<void> _apply({required bool enabled, List<double>? gains}) async {
    if (_applying) return;
    setState(() {
      _applying = true;
      _draft = null;
    });
    try {
      await audio.setEqualizer(enabled: enabled, gains: gains);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: FractionallySizedBox(
      heightFactor: .85,
      child: ListenableBuilder(
        listenable: audio.equalizerBandChanges,
        builder: (context, _) => _buildControls(context),
      ),
    ),
  );

  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final frequencies = audio.equalizerFrequencies;
    final min = audio.minEqualizerGain;
    final max = audio.maxEqualizerGain;
    final ready = frequencies.isNotEmpty && max > min;
    final gains = List.generate(
      ready ? frequencies.length : 0,
      (i) => ((_draft ?? audio.equalizerGains).elementAtOrNull(i) ?? 0.0).clamp(
        min,
        max,
      ),
    );
    final editable = ready && audio.equalizerEnabled && !_applying;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(Icons.equalizer_rounded, color: colors.secondary),
          title: Text('Ecualizador', style: theme.textTheme.titleLarge),
          value: audio.equalizerEnabled,
          onChanged: audio.supportsEqualizer && !_applying
              ? (enabled) => unawaited(_apply(enabled: enabled))
              : null,
        ),
        const SizedBox(height: 12),
        SegmentedButton<_EqualizerMode>(
          segments: const [
            ButtonSegment(value: _EqualizerMode.basic, label: Text('Básico')),
            ButtonSegment(
              value: _EqualizerMode.advanced,
              label: Text('Avanzado'),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) => setState(() {
            _mode = selection.single;
            _draft = null;
          }),
        ),
        const SizedBox(height: 20),
        if (!audio.supportsEqualizer)
          const Text('El ecualizador no está disponible en este dispositivo.')
        else if (!ready)
          Text(
            frequencies.isEmpty ? 'Abre una canción para cargar las bandas.' : 'El dispositivo no permite ajustar la ganancia de las bandas.',
          )
        else ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const height = 132.0;
                  final width = constraints.maxWidth;
                  final positions = _positions(frequencies);
                  return GestureDetector(
                    excludeFromSemantics: true,
                    onTapUp: editable && _mode == _EqualizerMode.advanced
                        ? (details) {
                            final x = details.localPosition.dx / width;
                            final y = details.localPosition.dy / height;
                            var nearest = 0;
                            for (var i = 1; i < positions.length; i++) {
                              if ((positions[i] - x).abs() <
                                  (positions[nearest] - x).abs()) {
                                nearest = i;
                              }
                            }
                            gains[nearest] = (max - y * (max - min)).clamp(
                              min,
                              max,
                            );
                            unawaited(_apply(enabled: true, gains: gains));
                          }
                        : null,
                    child: CustomPaint(
                      size: Size(width, height),
                      painter: _EqualizerCurve(
                        positions: positions,
                        levels: gains
                            .map((gain) => (max - gain) / (max - min))
                            .toList(),
                        zero: (max / (max - min)).clamp(0.0, 1.0),
                        curve: audio.equalizerEnabled
                            ? colors.secondary
                            : colors.outline,
                        grid: colors.outlineVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_mode == _EqualizerMode.basic) ...[
            Text('Preajustes', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final (name, gainFor) in <(String, double Function(int))>[
                  ('Plano', (_) => 0),
                  ('Graves', (hz) => hz < 200 ? 4 : 0),
                  ('Voces', (hz) => hz >= 400 && hz <= 3000 ? 3 : 0),
                  ('Agudos', (hz) => hz >= 4000 ? 3 : 0),
                ])
                  Builder(
                    builder: (_) {
                      final preset = frequencies
                          .map((hz) => gainFor(hz).clamp(min, max))
                          .toList();
                      return ChoiceChip(
                        label: Text(name),
                        selected: preset.indexed.every(
                          (entry) => entry.$2 == gains[entry.$1],
                        ),
                        onSelected: ready && !_applying
                            ? (_) => unawaited(
                                _apply(enabled: true, gains: preset),
                              )
                            : null,
                      );
                    },
                  ),
              ],
            ),
          ] else
            for (final (index, frequency) in frequencies.indexed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('$frequency Hz'),
                trailing: Text('${gains[index].toStringAsFixed(1)} dB'),
                subtitle: Slider(
                  min: min,
                  max: max,
                  value: gains[index],
                  semanticFormatterCallback: (value) =>
                      '$frequency Hz, ${value.toStringAsFixed(1)} dB',
                  onChanged: editable
                      ? (value) => setState(() {
                          gains[index] = value;
                          _draft = gains;
                        })
                      : null,
                  onChangeEnd: editable
                      ? (value) {
                          gains[index] = value;
                          unawaited(_apply(enabled: true, gains: gains));
                        }
                      : null,
                ),
              ),
        ],
      ],
    );
  }

  List<double> _positions(List<int> frequencies) {
    final scaled = frequencies.map((hz) => math.log(math.max(1, hz))).toList();
    final span = scaled.last - scaled.first;
    return scaled
        .map(
          (frequency) =>
              span == 0 ? .5 : .03 + .94 * (frequency - scaled.first) / span,
        )
        .toList();
  }
}

class _EqualizerCurve extends CustomPainter {
  const _EqualizerCurve({
    required this.positions,
    required this.levels,
    required this.zero,
    required this.curve,
    required this.grid,
  });

  final List<double> positions;
  final List<double> levels;
  final double zero;
  final Color curve;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = size.height * zero;
    final gridPaint = Paint()..color = grid;
    final linePaint = Paint()
      ..color = curve
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final pointPaint = Paint()..color = curve;
    canvas.drawLine(
      Offset(0, baseline),
      Offset(size.width, baseline),
      gridPaint,
    );
    final path = Path();
    for (final (i, position) in positions.indexed) {
      final point = Offset(position * size.width, levels[i] * size.height);
      canvas.drawLine(
        Offset(point.dx, 0),
        Offset(point.dx, size.height),
        gridPaint,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawCircle(point, 3, pointPaint);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_EqualizerCurve oldDelegate) => true;
}
