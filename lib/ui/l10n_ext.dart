import 'package:flutter/widgets.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension GameTexts on AppLocalizations {
  String handName(HandType type) => switch (type) {
    HandType.single => handSingle,
    HandType.pair => handPair,
    HandType.twoPair => handTwoPair,
    HandType.run3 => handRun3,
    HandType.group3 => handGroup3,
    HandType.threePairs => handThreePairs,
    HandType.run4 => handRun4,
    HandType.rainbowRun => handRainbowRun,
    HandType.run5 => handRun5,
    HandType.group4 => handGroup4,
    HandType.run6 => handRun6,
    HandType.skyMeld => handSkyMeld,
  };

  /// Localized Kut name; falls back to the id for unknown Kuts.
  String kutName(String id) => _kutTexts(id)?.$1 ?? id;

  String kutDescription(String id) => _kutTexts(id)?.$2 ?? '';

  (String, String)? _kutTexts(String id) => switch (id) {
    'umay_ana' => (kutUmayAnaName, kutUmayAnaDesc),
    'ay_ata' => (kutAyAtaName, kutAyAtaDesc),
    'gun_ana' => (kutGunAnaName, kutGunAnaDesc),
    'kara_dag' => (kutKaraDagName, kutKaraDagDesc),
    'bozkurt' => (kutBozkurtName, kutBozkurtDesc),
    'asena' => (kutAsenaName, kutAsenaDesc),
    'tulpar' => (kutTulparName, kutTulparDesc),
    'kopuz' => (kutKopuzName, kutKopuzDesc),
    'kam_davulu' => (kutKamDavuluName, kutKamDavuluDesc),
    'erlik_pazarligi' => (kutErlikPazarligiName, kutErlikPazarligiDesc),
    'ulgen_isigi' => (kutUlgenIsigiName, kutUlgenIsigiDesc),
    'kayra_han' => (kutKayraHanName, kutKayraHanDesc),
    'zumruduanka' => (kutZumruduankaName, kutZumruduankaDesc),
    'oguz_kagan' => (kutOguzKaganName, kutOguzKaganDesc),
    'dede_korkut' => (kutDedeKorkutName, kutDedeKorkutDesc),
    'kervan' => (kutKervanName, kutKervanDesc),
    'yada_tasi' => (kutYadaTasiName, kutYadaTasiDesc),
    'nazar_boncugu' => (kutNazarBoncuguName, kutNazarBoncuguDesc),
    'ergenekon' => (kutErgenekonName, kutErgenekonDesc),
    'gok_boru' => (kutGokBoruName, kutGokBoruDesc),
    _ => null,
  };
}
