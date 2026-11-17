import 'package:flutter/material.dart';

import '../themes/theme_library.dart';

ThemeData musicTheme(
  Brightness brightness,
  int? accent, {
  MusicAppearance? appearance,
}) {
  final dark = brightness == Brightness.dark;
  var colors = ColorScheme.fromSeed(
    seedColor: Color(appearance?.accent ?? accent ?? 0xff47efe0),
    brightness: brightness,
  );
  if (dark && appearance == null) {
    colors = colors.copyWith(
      primary: Color(appearance?.accent ?? accent ?? 0xff47efe0),
      onPrimary: const Color(0xff003733),
      secondary: const Color(0xffd0bcff),
      surface: const Color(0xff10131a),
      surfaceContainerLowest: const Color(0xff0b0e15),
      surfaceContainerLow: const Color(0xff191b23),
      surfaceContainer: const Color(0xff1d1f27),
      surfaceContainerHigh: const Color(0xff272a32),
      surfaceContainerHighest: const Color(0xff32353d),
      onSurface: const Color(0xffe1e2ec),
      onSurfaceVariant: const Color(0xffbacac7),
      outlineVariant: const Color(0xff3b4a47),
    );
  }
  final palette = appearance?.colors ?? const <String, Color>{};
  colors = colors.copyWith(
    primary: palette['primary'],
    onPrimary: palette['onPrimary'],
    secondary: palette['secondary'],
    onSecondary: palette['onSecondary'],
    surface: palette['surface'],
    onSurface: palette['onSurface'],
    onSurfaceVariant: palette['onSurfaceVariant'],
    outline: palette['outline'],
    surfaceContainer: palette['surfaceContainer'],
    surfaceContainerLow: palette['surfaceContainerLow'],
    surfaceContainerLowest: palette['surfaceContainerLowest'],
  );
  final base = ThemeData(
    colorScheme: colors,
    fontFamily: 'Inter',
    useMaterial3: true,
  );
  return base.copyWith(
    extensions: [?appearance],
    scaffoldBackgroundColor:
        appearance?.images.containsKey('background') == true
        ? Colors.transparent
        : colors.surface,
    textTheme: base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: colors.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide.none,
      showCheckmark: false,
      backgroundColor: colors.surfaceContainer,
      selectedColor: colors.primary.withValues(alpha: 0.16),
      shape: const StadiumBorder(),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colors.surfaceContainerLowest,
      indicatorColor: colors.primary.withValues(alpha: 0.12),
      selectedIconTheme: IconThemeData(color: colors.primary),
      selectedLabelTextStyle: TextStyle(
        color: colors.primary,
        fontFamily: 'Plus Jakarta Sans',
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surfaceContainerLowest,
      indicatorColor: colors.primary.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11)),
      height: 72,
    ),
    sliderTheme: base.sliderTheme.copyWith(
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
    ),
  );
}
