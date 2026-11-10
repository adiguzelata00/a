import 'package:flutter/material.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/l10n/app_localizations.dart';

import '../theme/palette.dart';
import '../widgets/effects.dart';

/// Text + color of the floating label for a scoring event.
(String, Color)? labelForEvent(AppLocalizations l10n, ScoreEvent e) {
  final v = formatNum(e.amount);
  return switch (e.kind) {
    ScoreEventKind.chips => (l10n.popupChips(v), Palette.chipsBlue),
    ScoreEventKind.mult => (l10n.popupMult(v), Palette.multRed),
    ScoreEventKind.xMult => (l10n.popupXMult(v), Palette.multRed),
    ScoreEventKind.money => (l10n.popupMoney(v), Palette.goldDark),
    ScoreEventKind.retrigger => (l10n.popupAgain, Palette.sealCrimson),
    ScoreEventKind.tileBroken => (l10n.popupBroken, Palette.sealSky),
    ScoreEventKind.tileDebuffed => (l10n.popupDebuffed, Palette.nightLighter),
    ScoreEventKind.bossPenalty =>
      e.amount == 0
          ? (l10n.popupBossZero, Palette.sealPurple)
          : (l10n.popupBossHalf(v), Palette.sealPurple),
    ScoreEventKind.handBase => null,
  };
}
