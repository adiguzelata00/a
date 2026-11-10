import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/bosses.dart';
import 'package:tengri_taslari/data/consumables.dart';
import 'package:tengri_taslari/data/kuts.dart';
import 'package:tengri_taslari/l10n/app_localizations.dart';
import 'package:tengri_taslari/ui/l10n_ext.dart';

void main() {
  for (final locale in const [Locale('tr'), Locale('en')]) {
    test('every content id has ${locale.languageCode} texts', () {
      final l10n = lookupAppLocalizations(locale);
      for (final k in allKuts) {
        expect(l10n.kutName(k.id), isNot(k.id), reason: k.id);
        expect(l10n.kutDescription(k.id), isNotEmpty, reason: k.id);
      }
      for (final b in allBosses) {
        expect(l10n.bossName(b.id), isNot(b.id), reason: b.id);
        expect(l10n.bossDescription(b.id), isNotEmpty, reason: b.id);
      }
      for (final c in allConsumables) {
        final item = ConsumableInstance(c, color: TileColor.red);
        expect(l10n.consumableName(item), isNot(c.id), reason: c.id);
        expect(l10n.consumableDescription(item), isNotEmpty, reason: c.id);
      }
      for (final v in allVouchers) {
        expect(l10n.voucherName(v.id), isNot(v.id), reason: v.id);
      }
    });
  }
}
