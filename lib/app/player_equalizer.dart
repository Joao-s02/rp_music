import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../playback/equalizer_settings.dart';
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
  int? _dragBand;
  bool _applying = false;

  Future<void> _apply({
    required bool enabled,
    List<double>? gains,
    EqualizerEffects? effects,
  }) => _perform(
    () => audio.setEqualizer(enabled: enabled, gains: gains, effects: effects),
  );

  Future<void> _perform(Future<void> Function() action) async {
    if (_applying) return;
    setState(() {
      _applying = true;
      _draft = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        final message = error is FormatException
            ? error.message
            : 'No se pudo completar la operación del ecualizador.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: FractionallySizedBox(
      heightFactor: .85,
      child: _buildControls(context),
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
                  final canEdit =
                      editable && _mode == _EqualizerMode.advanced && width > 0;
                  int nearestBand(double dx) {
                    final x = dx / width;
                    var nearest = 0;
                    for (var i = 1; i < positions.length; i++) {
                      if ((positions[i] - x).abs() <
                          (positions[nearest] - x).abs()) {
                        nearest = i;
                      }
                    }
                    return nearest;
                  }

                  void changeBand(int index, double dy) {
                    gains[index] = (max - dy / height * (max - min)).clamp(
                      min,
                      max,
                    );
                  }

                  return GestureDetector(
                    key: const ValueKey('equalizer-graph'),
                    behavior: HitTestBehavior.opaque,
                    excludeFromSemantics: true,
                    onVerticalDragDown: canEdit
                        ? (details) {
                            _dragBand = nearestBand(details.localPosition.dx);
                          }
                        : null,
                    onVerticalDragUpdate: canEdit
                        ? (details) {
                            final index =
                                _dragBand ??
                                nearestBand(details.localPosition.dx);
                            setState(() {
                              changeBand(index, details.localPosition.dy);
                              _draft = gains;
                            });
                          }
                        : null,
                    onVerticalDragEnd: canEdit
                        ? (_) {
                            _dragBand = null;
                            unawaited(
                              _apply(enabled: true, gains: _draft ?? gains),
                            );
                          }
                        : null,
                    onVerticalDragCancel: canEdit
                        ? () => setState(() {
                            _dragBand = null;
                            _draft = null;
                          })
                        : null,
                    onTapUp: canEdit
                        ? (details) {
                            changeBand(
                              nearestBand(details.localPosition.dx),
                              details.localPosition.dy,
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
            _toneControl(
              'Nivel de graves',
              frequencies,
              gains,
              (hz) => hz <= 125,
              editable,
            ),
            _toneControl(
              'Nivel de agudos',
              frequencies,
              gains,
              (hz) => hz >= 4000,
              editable,
            ),
          ] else ...[
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
            ..._effectControls(editable),
          ],
          ..._profileControls(),
        ],
      ],
    );
  }

  Widget _toneControl(
    String label,
    List<int> frequencies,
    List<double> gains,
    bool Function(int) matches,
    bool editable,
  ) {
    final indices = [
      for (final (i, hz) in frequencies.indexed)
        if (matches(hz)) i,
    ];
    if (indices.isEmpty) return const SizedBox.shrink();
    final average =
        indices.map((i) => gains[i]).reduce((a, b) => a + b) / indices.length;
    return _EffectSlider(
      label: label,
      value: average,
      min: -12,
      max: 12,
      onEnd: editable
          ? (value) {
              for (final index in indices) {
                gains[index] = value;
              }
              unawaited(_apply(enabled: true, gains: gains));
            }
          : null,
    );
  }

  List<Widget> _effectControls(bool editable) {
    if (!audio.supportsParametricEqualizer) {
      return const [
        Divider(),
        Text(
          'La curva se adapta a las bandas del ecualizador de Android. '
          'Los filtros paramétricos y los efectos adicionales no están disponibles.',
        ),
      ];
    }
    final effects = audio.equalizerEffects;
    final dynamics = audio.supportsEqualizerDynamics;
    return [
      const Divider(),
      if (dynamics) ...[
        _EffectSlider(
          label: 'Preamplificación',
          value: effects.preamp,
          min: -18,
          max: 6,
          onEnd: editable
              ? (value) => unawaited(
                  _apply(
                    enabled: true,
                    effects: effects.copyWith(preamp: value),
                  ),
                )
              : null,
        ),
        _EffectSlider(
          label: 'Balance estéreo',
          value: effects.balance,
          min: -1,
          max: 1,
          format: (value) => value == 0
              ? 'Centro'
              : '${(value.abs() * 100).round()}% ${value < 0 ? 'izq.' : 'der.'}',
          onEnd: editable
              ? (value) => unawaited(
                  _apply(
                    enabled: true,
                    effects: effects.copyWith(balance: value),
                  ),
                )
              : null,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Limitador de picos'),
          value: effects.limiter,
          onChanged: editable
              ? (value) => unawaited(
                  _apply(
                    enabled: true,
                    effects: effects.copyWith(limiter: value),
                  ),
                )
              : null,
        ),
      ] else
        const Text(
          'Esta compilación no dispone de preamplificación, balance ni limitador.',
        ),
      const Divider(),
      Text(
        'Filtros paramétricos',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      for (final (i, band) in effects.filters.indexed)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${band.hz.toStringAsFixed(0)} Hz'),
          subtitle: Text(
            '${band.gain.toStringAsFixed(1)} dB · Q ${band.q.toStringAsFixed(2)}',
          ),
          onTap: editable ? () => _editFilter(i) : null,
          trailing: IconButton(
            tooltip: 'Quitar filtro',
            icon: const Icon(Icons.close),
            onPressed: editable
                ? () {
                    final filters = [...effects.filters]..removeAt(i);
                    unawaited(
                      _apply(
                        enabled: true,
                        effects: effects.copyWith(filters: filters),
                      ),
                    );
                  }
                : null,
          ),
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: OutlinedButton.icon(
          onPressed: editable && effects.filters.length < maxParametricFilters
              ? () => _editFilter(null)
              : null,
          icon: const Icon(Icons.add),
          label: const Text('Añadir filtro'),
        ),
      ),
    ];
  }

  Future<void> _editFilter(int? index) async {
    final effects = audio.equalizerEffects;
    final band = await showDialog<ParametricBand>(
      context: context,
      builder: (_) => _FilterDialog(
        band: index == null ? const ParametricBand() : effects.filters[index],
      ),
    );
    if (!mounted || band == null) return;
    final filters = [...effects.filters];
    if (index == null) {
      filters.add(band);
    } else {
      filters[index] = band;
    }
    await _apply(enabled: true, effects: effects.copyWith(filters: filters));
  }

  List<Widget> _profileControls() => [
    const SizedBox(height: 12),
    const Divider(),
    Text('Perfiles', style: Theme.of(context).textTheme.titleMedium),
    for (final profile in audio.equalizerProfiles)
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(profile.name),
        subtitle: const Text('Toca para aplicar'),
        onTap: _applying
            ? null
            : () => _perform(() => audio.applyEqualizerProfile(profile)),
        trailing: PopupMenuButton<_ProfileAction>(
          enabled: !_applying,
          tooltip: 'Opciones del perfil',
          onSelected: (action) => _perform(
            () => switch (action) {
              _ProfileAction.export => _exportProfile(profile),
              _ProfileAction.remove => audio.removeEqualizerProfile(profile),
            },
          ),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: _ProfileAction.export,
              child: Text('Exportar'),
            ),
            PopupMenuItem(
              value: _ProfileAction.remove,
              child: Text('Eliminar'),
            ),
          ],
        ),
      ),
    Wrap(
      spacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _applying ? null : _saveProfile,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar perfil'),
        ),
        OutlinedButton.icon(
          onPressed: _applying ? null : () => _perform(_importProfile),
          icon: const Icon(Icons.file_open_outlined),
          label: const Text('Importar perfil'),
        ),
      ],
    ),
  ];

  Future<void> _saveProfile() async {
    var name = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar perfil'),
        content: TextField(
          autofocus: true,
          maxLength: 48,
          decoration: const InputDecoration(labelText: 'Nombre del perfil'),
          onChanged: (value) => name = value.trim(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _perform(
      () => audio.saveEqualizerProfile(audio.currentEqualizerProfile(name)),
    );
  }

  Future<void> _importProfile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return;
    final length = await file.length();
    if (length == null || length > 16 * 1024) {
      throw const FormatException('El archivo del perfil es demasiado grande.');
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > 16 * 1024) {
      throw const FormatException('El archivo del perfil es demasiado grande.');
    }
    final profile = EqualizerProfile.fromJson(jsonDecode(utf8.decode(bytes)));
    if (mounted) await audio.saveEqualizerProfile(profile);
  }

  Future<void> _exportProfile(EqualizerProfile profile) async {
    await FilePicker.saveFile(
      fileName: 'rp-music-ecualizador.json',
      mimeType: 'application/json',
      bytes: Uint8List.fromList(utf8.encode(jsonEncode(profile.toJson()))),
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

enum _ProfileAction { export, remove }

class _EffectSlider extends StatefulWidget {
  const _EffectSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onEnd,
    this.format,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onEnd;
  final String Function(double)? format;

  @override
  State<_EffectSlider> createState() => _EffectSliderState();
}

class _EffectSliderState extends State<_EffectSlider> {
  double? draft;

  @override
  Widget build(BuildContext context) {
    final value = draft ?? widget.value;
    final formatted =
        widget.format?.call(value) ?? '${value.toStringAsFixed(1)} dB';
    final onEnd = widget.onEnd;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(widget.label),
      trailing: Text(formatted),
      subtitle: Slider(
        min: widget.min,
        max: widget.max,
        value: value,
        label: formatted,
        semanticFormatterCallback: (value) =>
            '${widget.label}, ${widget.format?.call(value) ?? "${value.toStringAsFixed(1)} dB"}',
        onChanged: onEnd == null
            ? null
            : (value) => setState(() => draft = value),
        onChangeEnd: onEnd == null
            ? null
            : (value) {
                setState(() => draft = null);
                onEnd(value);
              },
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  const _FilterDialog({required this.band});
  final ParametricBand band;

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  final form = GlobalKey<FormState>();
  late double hz = widget.band.hz;
  late double gain = widget.band.gain;
  late double q = widget.band.q;

  Widget field(
    String label,
    double initial,
    double min,
    double max,
    ValueChanged<double> save,
  ) => TextFormField(
    initialValue: initial.toString(),
    decoration: InputDecoration(labelText: label),
    keyboardType: TextInputType.numberWithOptions(
      decimal: true,
      signed: min < 0,
    ),
    validator: (value) {
      final number = double.tryParse(value?.trim().replaceAll(',', '.') ?? '');
      if (number == null || !number.isFinite || number < min || number > max) {
        return 'Introduce un valor entre $min y $max.';
      }
      return null;
    },
    onSaved: (value) => save(double.parse(value!.trim().replaceAll(',', '.'))),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Filtro paramétrico'),
    scrollable: true,
    content: Form(
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          field('Frecuencia (Hz)', hz, 20, 18000, (value) => hz = value),
          field('Ganancia (dB)', gain, -12, 12, (value) => gain = value),
          field('Factor Q · ancho de banda', q, .3, 10, (value) => q = value),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (!form.currentState!.validate()) return;
          form.currentState!.save();
          Navigator.pop(context, ParametricBand(hz: hz, gain: gain, q: q));
        },
        child: const Text('Aplicar'),
      ),
    ],
  );
}
