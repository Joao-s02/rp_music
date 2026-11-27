import 'dart:math' as math;

const graphicEqualizerFrequencies = [
  31,
  62,
  125,
  250,
  500,
  1000,
  2000,
  4000,
  8000,
  16000,
];
const legacyDesktopFrequencies = [60, 150, 400, 1000, 2400, 6000, 12000];
const maxParametricFilters = 8;

class ParametricBand {
  const ParametricBand({this.hz = 1000, this.gain = 0, this.q = 1});

  final double hz;
  final double gain;
  final double q;

  Map<String, Object> toJson() => {'hz': hz, 'gain': gain, 'q': q};

  factory ParametricBand.fromJson(Object? data) {
    if (data is! Map) throw const FormatException('Filtro inválido.');
    return ParametricBand(
      hz: _number(data['hz'], 20, 18000),
      gain: _number(data['gain'], -12, 12),
      q: _number(data['q'], .3, 10),
    );
  }
}

class EqualizerEffects {
  const EqualizerEffects({
    this.preamp = 0,
    this.balance = 0,
    this.limiter = false,
    this.filters = const [],
  });

  final double preamp;
  final double balance;
  final bool limiter;
  final List<ParametricBand> filters;

  EqualizerEffects copyWith({
    double? preamp,
    double? balance,
    bool? limiter,
    List<ParametricBand>? filters,
  }) => EqualizerEffects(
    preamp: preamp ?? this.preamp,
    balance: balance ?? this.balance,
    limiter: limiter ?? this.limiter,
    filters: List.unmodifiable(filters ?? this.filters),
  );

  Map<String, Object> toJson() => {
    'preamp': preamp,
    'balance': balance,
    'limiter': limiter,
    'filters': filters.map((band) => band.toJson()).toList(),
  };

  factory EqualizerEffects.fromJson(Object? data) {
    if (data is! Map) throw const FormatException('Efectos inválidos.');
    final filters = data['filters'];
    final limiter = data['limiter'];
    if (filters is! List ||
        filters.length > maxParametricFilters ||
        limiter is! bool) {
      throw const FormatException('Efectos inválidos.');
    }
    return EqualizerEffects(
      preamp: _number(data['preamp'], -18, 6),
      balance: _number(data['balance'], -1, 1),
      limiter: limiter,
      filters: List.unmodifiable(filters.map(ParametricBand.fromJson)),
    );
  }
}

class EqualizerProfile {
  const EqualizerProfile({
    required this.name,
    required this.frequencies,
    required this.gains,
    required this.effects,
  });

  final String name;
  final List<int> frequencies;
  final List<double> gains;
  final EqualizerEffects effects;

  Map<String, Object> toJson() => {
    'version': 1,
    'name': name,
    'frequencies': frequencies,
    'gains': gains,
    'effects': effects.toJson(),
  };

  factory EqualizerProfile.fromJson(Object? data) {
    if (data is! Map || data['version'] != 1) {
      throw const FormatException('Formato de perfil incompatible.');
    }
    final name = data['name'];
    final frequencies = data['frequencies'];
    final gains = data['gains'];
    if (name is! String ||
        name.trim().isEmpty ||
        name.length > 48 ||
        frequencies is! List ||
        frequencies.isEmpty ||
        frequencies.length > 64 ||
        gains is! List ||
        frequencies.length != gains.length) {
      throw const FormatException('Perfil inválido.');
    }
    final bands = <int>[];
    for (final hz in frequencies) {
      if (hz is! int ||
          hz < 1 ||
          hz > 96000 ||
          (bands.isNotEmpty && hz <= bands.last)) {
        throw const FormatException('Frecuencias inválidas.');
      }
      bands.add(hz);
    }
    return EqualizerProfile(
      name: name.trim(),
      frequencies: List.unmodifiable(bands),
      gains: List.unmodifiable(gains.map((gain) => _number(gain, -100, 100))),
      effects: EqualizerEffects.fromJson(data['effects']),
    );
  }

  List<double> gainsFor(List<int> target) {
    return target.map((hz) {
      final upper = frequencies.indexWhere((frequency) => frequency >= hz);
      if (upper < 0) return gains.last;
      if (upper == 0) return gains.first;
      final lower = upper - 1;
      final fraction =
          math.log(hz / frequencies[lower]) /
          math.log(frequencies[upper] / frequencies[lower]);
      return gains[lower] + fraction * (gains[upper] - gains[lower]);
    }).toList();
  }
}

double _number(Object? value, double minimum, double maximum) {
  if (value is! num || !value.isFinite || value < minimum || value > maximum) {
    throw const FormatException('Valor fuera de rango.');
  }
  return value.toDouble();
}
