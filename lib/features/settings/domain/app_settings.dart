enum AppThemeMode {
  system,
  light,
  dark,
}

enum UiDensity {
  compact,
  standard,
  comfortable,
}

class AppSettings {
  final AppThemeMode themeMode;
  final int primaryColorValue;
  final UiDensity density;
  final double textScale;
  final bool reduceMotion;
  final bool closeToTray;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.primaryColorValue = 0xFF6750A4, // Material deep purple / primary
    this.density = UiDensity.standard,
    this.textScale = 1.0,
    this.reduceMotion = false,
    this.closeToTray = false,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    int? primaryColorValue,
    UiDensity? density,
    double? textScale,
    bool? reduceMotion,
    bool? closeToTray,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      density: density ?? this.density,
      textScale: textScale ?? this.textScale,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      closeToTray: closeToTray ?? this.closeToTray,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'primaryColorValue': primaryColorValue,
    'density': density.name,
    'textScale': textScale,
    'reduceMotion': reduceMotion,
    'closeToTray': closeToTray,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.values.where((e) => e.name == json['themeMode']).firstOrNull ?? AppThemeMode.system,
      primaryColorValue: json['primaryColorValue'] as int? ?? 0xFF6750A4,
      density: UiDensity.values.where((e) => e.name == json['density']).firstOrNull ?? UiDensity.standard,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
      closeToTray: json['closeToTray'] as bool? ?? false,
    );
  }
}
