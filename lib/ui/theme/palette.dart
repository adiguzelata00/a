import 'package:flutter/material.dart';
import 'package:tengri_taslari/core/core.dart';

/// Every color of the game in one place.
abstract final class Palette {
  // Base palette from the design brief.
  static const night = Color(0xFF0E1428);
  static const gold = Color(0xFFD4A84B);
  static const red = Color(0xFFC0392B);
  static const blue = Color(0xFF1F4E8C);
  static const mustard = Color(0xFFE1A72E);
  static const charcoal = Color(0xFF1C1C1C);
  static const cream = Color(0xFFF3E9D2);

  // Derived UI colors.
  static const nightLight = Color(0xFF1A2342);
  static const nightLighter = Color(0xFF26315A);
  static const goldDark = Color(0xFF8E6C25);
  static const creamShade = Color(0xFFD9CCAE);
  static const creamEdge = Color(0xFFB9A983);
  static const textMuted = Color(0xFFA9A28F);
  static const chipsBlue = Color(0xFF2F7FD1);
  static const multRed = Color(0xFFD8452F);
  static const success = Color(0xFF4FA36B);

  // Rack wood.
  static const woodLight = Color(0xFF8A5A33);
  static const woodDark = Color(0xFF5A3519);
  static const woodEdge = Color(0xFF3B220F);

  // Enhancement tints.
  static const bone = Color(0xFFEDE6D6);
  static const iron = Color(0xFFA7ADB3);
  static const goldTile = Color(0xFFEBCB79);
  static const crystal = Color(0xFFCDEAF2);
  static const skyStone = Color(0xFF1E2A55);

  // Seal colors.
  static const sealCrimson = Color(0xFFB0202A);
  static const sealGold = Color(0xFFD4A84B);
  static const sealSky = Color(0xFF3C8DDB);
  static const sealPurple = Color(0xFF7A3DB8);

  // World backgrounds (Phase 3): underworld, middle world, sky.
  static const underworldTop = Color(0xFF2A0F2E);
  static const underworldBottom = Color(0xFF120612);

  static Color tileColor(TileColor c) => switch (c) {
    TileColor.red => red,
    TileColor.yellow => mustard,
    TileColor.blue => blue,
    TileColor.black => charcoal,
  };

  static Color sealColor(Seal s) => switch (s) {
    Seal.none => Colors.transparent,
    Seal.crimson => sealCrimson,
    Seal.gold => sealGold,
    Seal.sky => sealSky,
    Seal.purple => sealPurple,
  };
}
