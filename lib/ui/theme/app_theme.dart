import 'package:flutter/material.dart';

import 'palette.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
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
