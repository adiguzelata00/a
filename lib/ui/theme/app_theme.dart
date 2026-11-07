import 'package:flutter/material.dart';

import 'palette.dart';

/// Bundled UI font (assets/fonts, OFL licensed). Bundled instead of relying
/// on platform fonts so the look is identical on Android, iOS and web.
const String appFontFamily = 'Rubik';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: appFontFamily,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.gold,
      brightness: Brightness.dark,
      surface: Palette.night,
      primary: Palette.gold,
    ),
    scaffoldBackgroundColor: Palette.night,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Palette.cream,
      displayColor: Palette.cream,
    ),
  );
}
