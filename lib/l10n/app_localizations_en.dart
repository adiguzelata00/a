// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stones of Tengri';

  @override
  String get target => 'Target';

  @override
  String get score => 'Score';

  @override
  String get hands => 'Hands';

  @override
  String get discards => 'Discards';

  @override
  String get money => 'Akçe';

  @override
  String floorLabel(int floor) {
    return 'Floor $floor';
  }

  @override
  String get roundSmall => 'Small Trial';

  @override
  String get roundBig => 'Big Trial';

  @override
  String get roundBoss => 'Boss';

  @override
  String get indicator => 'Indicator';

  @override
  String get okey => 'Okey';

  @override
  String get okeyNotWild => 'Not wild';

  @override
  String get play => 'Play';

  @override
  String get discard => 'Discard';

  @override
  String get sortByNumber => 'Number';

  @override
  String get sortByColor => 'Color';

  @override
  String get selectTiles => 'Select tiles to play';

  @override
  String get chips => 'Chips';

  @override
  String get mult => 'Mult';

  @override
  String get roundWon => 'Round won!';

  @override
  String get roundLost => 'Run over';

  @override
  String finalScore(int score, int target) {
    return 'Score: $score / $target';
  }

  @override
  String bestHand(int score) {
    return 'Best hand: $score';
  }

  @override
  String handsLeftBonus(int count) {
    return 'Hands left: $count';
  }

  @override
  String get newRound => 'New Round';

  @override
  String get tryAgain => 'Try Again';

  @override
  String seedLabel(String code) {
    return 'Seed: $code';
  }

  @override
  String speedLabel(int speed) {
    return '$speed×';
  }

  @override
  String get tapToSkip => 'Tap to skip';

  @override
  String get emptyKutSlot => 'Empty';

  @override
  String tilesLeft(int count) {
    return 'Deck: $count';
  }

  @override
  String tooManyTiles(int max) {
    return 'At most $max tiles';
  }

  @override
  String get handSingle => 'High Tile';

  @override
  String get handPair => 'Pair';

  @override
  String get handTwoPair => 'Two Pair';

  @override
  String get handRun3 => 'Run-3';

  @override
  String get handGroup3 => 'Group-3';

  @override
  String get handThreePairs => 'Three Pairs';

  @override
  String get handRun4 => 'Run-4';

  @override
  String get handRainbowRun => 'Rainbow Run';

  @override
  String get handRun5 => 'Run-5';

  @override
  String get handGroup4 => 'Group-4';

  @override
  String get handRun6 => 'Run-6';

  @override
  String get handSkyMeld => 'Sky Meld';

  @override
  String get kutUmayAnaName => 'Umay Ana';

  @override
  String get kutUmayAnaDesc => '+4 Mult for each Red tile counted.';

  @override
  String get kutAyAtaName => 'Ay Ata';

  @override
  String get kutAyAtaDesc => '+30 Chips for each Blue tile counted.';

  @override
  String get kutGunAnaName => 'Gün Ana';

  @override
  String get kutGunAnaDesc => '+3 Mult for each Yellow tile counted.';

  @override
  String get kutKaraDagName => 'Kara Dağ';

  @override
  String get kutKaraDagDesc =>
      '+20 Chips and +1 Mult for each Black tile counted.';

  @override
  String get kutBozkurtName => 'Bozkurt';

  @override
  String get kutBozkurtDesc => '+10 Mult if the hand contains a run.';

  @override
  String get kutAsenaName => 'Asena';

  @override
  String get kutAsenaDesc => '×2 Mult if the hand contains a group.';

  @override
  String get kutTulparName => 'Tulpar';

  @override
  String get kutTulparDesc => '+15 Chips for each remaining discard.';

  @override
  String get kutKopuzName => 'Kopuz';

  @override
  String get kutKopuzDesc => '+20 Mult if 3 or fewer tiles are played.';

  @override
  String get kutKamDavuluName => 'Shaman Drum';

  @override
  String get kutKamDavuluDesc =>
      'The first counted tile of each hand triggers twice.';

  @override
  String get kutErlikPazarligiName => 'Erlik\'s Bargain';

  @override
  String get kutErlikPazarligiDesc => '×3 Mult, but one fewer hand per round.';

  @override
  String get kutUlgenIsigiName => 'Light of Ülgen';

  @override
  String get kutUlgenIsigiDesc =>
      '×3 Mult if the okey is used as a joker in the meld.';

  @override
  String get kutKayraHanName => 'Kayra Han';

  @override
  String get kutKayraHanDesc =>
      'Permanently gains ×0.25 Mult whenever a Destan is used.';

  @override
  String get kutZumruduankaName => 'Zümrüdüanka';

  @override
  String get kutZumruduankaDesc =>
      'Prevents a loss once if you reached 25% of the target, then vanishes.';

  @override
  String get kutOguzKaganName => 'Oğuz Kağan';

  @override
  String get kutOguzKaganDesc => '+50 Chips and +5 Mult for Run-5 or longer.';

  @override
  String get kutDedeKorkutName => 'Dede Korkut';

  @override
  String get kutDedeKorkutDesc => '+2 Akçe per remaining hand at round end.';

  @override
  String get kutKervanName => 'Caravan';

  @override
  String get kutKervanDesc => 'The first reroll in the Bazaar is free.';

  @override
  String get kutYadaTasiName => 'Rain Stone';

  @override
  String get kutYadaTasiDesc => '+1 Mult for every tile discarded this round.';

  @override
  String get kutNazarBoncuguName => 'Evil Eye Bead';

  @override
  String get kutNazarBoncuguDesc => '+15 Mult in boss rounds.';

  @override
  String get kutErgenekonName => 'Ergenekon';

  @override
  String get kutErgenekonDesc =>
      'Iron tiles held in the rack also give +20 Chips.';

  @override
  String get kutGokBoruName => 'Sky Wolf';

  @override
  String get kutGokBoruDesc =>
      'Permanently gains +1 ×Mult each time a Group-4 is played.';

  @override
  String popupChips(String value) {
    return '+$value';
  }

  @override
  String popupMult(String value) {
    return '+$value Mult';
  }

  @override
  String popupXMult(String value) {
    return '×$value Mult';
  }

  @override
  String popupMoney(String value) {
    return '+$value Akçe';
  }

  @override
  String get popupAgain => 'Again!';

  @override
  String get popupBroken => 'Shattered!';

  @override
  String get popupDebuffed => 'Not counted';

  @override
  String get popupBossZero => 'Erlik: 0';

  @override
  String popupBossHalf(String value) {
    return '×$value Score';
  }

  @override
  String handScoreTotal(int score) {
    return '+$score';
  }

  @override
  String get countedColorHint => 'Counted color';

  @override
  String get playAreaHint => 'Drag to arrange tiles, tap to select';
}
