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
    'od_ana' => (kutOdAnaName, kutOdAnaDesc),
    'yer_su' => (kutYerSuName, kutYerSuDesc),
    'otuken' => (kutOtukenName, kutOtukenDesc),
    'kok_tengri' => (kutKokTengriName, kutKokTengriDesc),
    _ => null,
  };
}

extension RunTexts on AppLocalizations {
  String bossName(String id) => _boss(id)?.$1 ?? id;
  String bossDescription(String id) => _boss(id)?.$2 ?? '';

  (String, String)? _boss(String id) => switch (id) {
    'tepegoz' => (bossTepegozName, bossTepegozDesc),
    'erlik_han' => (bossErlikHanName, bossErlikHanDesc),
    'al_karisi' => (bossAlKarisiName, bossAlKarisiDesc),
    'yel_ana' => (bossYelAnaName, bossYelAnaDesc),
    'sahmeran' => (bossSahmeranName, bossSahmeranDesc),
    'albasti' => (bossAlbastiName, bossAlbastiDesc),
    'demirkiyak' => (bossDemirkiyakName, bossDemirkiyakDesc),
    'kara_kus' => (bossKaraKusName, bossKaraKusDesc),
    'yalmavuz' => (bossYalmavuzName, bossYalmavuzDesc),
    'abasi' => (bossAbasiName, bossAbasiDesc),
    'sulmus' => (bossSulmusName, bossSulmusDesc),
    'kara_kam' => (bossKaraKamName, bossKaraKamDesc),
    _ => null,
  };

  String worldName(int world) => switch (world) {
    0 => worldUnderworld,
    1 => worldMiddle,
    _ => worldSky,
  };

  String roundName(int roundInFloor) => switch (roundInFloor) {
    0 => roundSmall,
    1 => roundBig,
    _ => roundBoss,
  };

  String colorName(TileColor c) => switch (c) {
    TileColor.red => colorRed,
    TileColor.yellow => colorYellow,
    TileColor.blue => colorBlue,
    TileColor.black => colorBlack,
  };

  String rarityName(Rarity r) => switch (r) {
    Rarity.common => rarityCommon,
    Rarity.rare => rarityRare,
    Rarity.legendary => rarityLegendary,
  };

  String tagText(SkipTag tag, int money) => switch (tag) {
    SkipTag.money => tagMoney(money),
    SkipTag.kutPack => tagKutPack,
    SkipTag.destanPack => tagDestanPack,
    SkipTag.tilsimPack => tagTilsimPack,
  };

  String packName(PackKind kind) => switch (kind) {
    PackKind.kut => packKut,
    PackKind.destan => packDestan,
    PackKind.tilsim => packTilsim,
    PackKind.tile => packTile,
  };

  String consumableName(ConsumableInstance item) => switch (item.id) {
    'goc_destani' => destanGoc,
    'tureyis_destani' => destanTureyis,
    'satuk_bugra_destani' => destanSatukBugra,
    'alpamis_destani' => destanAlpamis,
    'koroglu_destani' => destanKoroglu,
    'dede_korkut_hikayeleri' => destanDedeKorkut,
    'manas_destani' => destanManas,
    'su_destani' => destanSu,
    'oguz_kagan_destani' => destanOguzKagan,
    'ergenekon_destani' => destanErgenekon,
    'er_tostuk_destani' => destanErTostuk,
    'yaratilis_destani' => destanYaratilis,
    'demirci_tilsimi' => tilsimDemirciName,
    'simyaci_tilsimi' => tilsimSimyaciName,
    'renk_tilsimi' => tilsimRenkName,
    'ayna_tilsimi' => tilsimAynaName,
    'yakma_tilsimi' => tilsimYakmaName,
    'kam_tilsimi' => tilsimKamName,
    'tamga_tilsimi' => tilsimTamgaName,
    'yukseltme_tilsimi' => tilsimYukseltmeName,
    _ => item.id,
  };

  String consumableDescription(ConsumableInstance item) {
    final def = item.definition;
    if (def.kind == ConsumableKind.destan) {
      return destanDesc(handName(def.hand!));
    }
    return switch (def.effect!) {
      TilsimEffect.iron => tilsimDemirciDesc,
      TilsimEffect.gold => tilsimSimyaciDesc,
      TilsimEffect.paint => tilsimRenkDesc(
        colorName(item.color ?? TileColor.red),
      ),
      TilsimEffect.copy => tilsimAynaDesc,
      TilsimEffect.destroy => tilsimYakmaDesc,
      TilsimEffect.createKut => tilsimKamDesc,
      TilsimEffect.seal => tilsimTamgaDesc,
      TilsimEffect.increment => tilsimYukseltmeDesc,
    };
  }

  String voucherName(String id) => _voucher(id)?.$1 ?? id;
  String voucherDescription(String id) => _voucher(id)?.$2 ?? '';

  (String, String)? _voucher(String id) => switch (id) {
    'ek_el' => (voucherEkElName, voucherEkElDesc),
    'ek_degistir' => (voucherEkDegistirName, voucherEkDegistirDesc),
    'genis_istaka' => (voucherGenisIstakaName, voucherGenisIstakaDesc),
    'kut_yuvasi' => (voucherKutYuvasiName, voucherKutYuvasiDesc),
    'heybe' => (voucherHeybeName, voucherHeybeDesc),
    'pazarlik' => (voucherPazarlikName, voucherPazarlikDesc),
    'hazine' => (voucherHazineName, voucherHazineDesc),
    _ => null,
  };

  /// Description of a tile's enhancement and seal (pack choices, tooltips).
  String tileDescription(Tile t) => [
    switch (t.enhancement) {
      Enhancement.none => null,
      Enhancement.bone => enhBone,
      Enhancement.iron => enhIron,
      Enhancement.gold => enhGold,
      Enhancement.crystal => enhCrystal,
      Enhancement.skyStone => enhSkyStone,
    },
    switch (t.seal) {
      Seal.none => null,
      Seal.crimson => sealCrimson,
      Seal.gold => sealGold,
      Seal.sky => sealSky,
      Seal.purple => sealPurple,
    },
  ].whereType<String>().join('\n');

  String errorText(RunError e) => switch (e) {
    RunError.notEnoughMoney => errNotEnoughMoney,
    RunError.noKutSlot => errNoKutSlot,
    RunError.noConsumableSlot => errNoConsumableSlot,
    RunError.invalidTarget => errInvalidTarget,
    _ => errGeneric,
  };
}
