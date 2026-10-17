import 'package:flutter/material.dart';
import 'package:rp_music/features/settings/domain/app_settings.dart';

class AppTheme {
  static ThemeData light(AppSettings settings) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(settings.primaryColorValue),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      visualDensity: _mapDensity(settings.density),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  static ThemeData dark(AppSettings settings) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(settings.primaryColorValue),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      visualDensity: _mapDensity(settings.density),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  static VisualDensity _mapDensity(UiDensity density) {
    return switch (density) {
      UiDensity.compact => VisualDensity.compact,
      UiDensity.standard => VisualDensity.standard,
      UiDensity.comfortable => VisualDensity.comfortable,
    };
  }
}
