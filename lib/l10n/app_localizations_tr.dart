// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Tengri\'nin Taşları';

  @override
  String get target => 'Hedef';

  @override
  String get score => 'Skor';

  @override
  String get hands => 'El';

  @override
  String get discards => 'Değiştir';

  @override
  String get money => 'Akçe';

  @override
  String floorLabel(int floor) {
    return 'Kat $floor';
  }

  @override
  String get roundSmall => 'Küçük Sınav';

  @override
  String get roundBig => 'Büyük Sınav';

  @override
  String get roundBoss => 'Boss';

  @override
  String get indicator => 'Gösterge';

  @override
  String get okey => 'Okey';

  @override
  String get okeyNotWild => 'Joker değil';

  @override
  String get play => 'Oyna';

  @override
  String get discard => 'Değiştir';

  @override
  String get sortByNumber => 'Sayı';

  @override
  String get sortByColor => 'Renk';

  @override
  String get selectTiles => 'Oynamak için taş seç';

  @override
  String get chips => 'Puan';

  @override
  String get mult => 'Çarpan';

  @override
  String get roundWon => 'Tur kazanıldı!';

  @override
  String get roundLost => 'Koşu bitti';

  @override
  String finalScore(int score, int target) {
    return 'Skor: $score / $target';
  }

  @override
  String bestHand(int score) {
    return 'En iyi el: $score';
  }

  @override
  String handsLeftBonus(int count) {
    return 'Kalan El: $count';
  }

  @override
  String get newRound => 'Yeni Tur';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String seedLabel(String code) {
    return 'Seed: $code';
  }

  @override
  String speedLabel(int speed) {
    return '$speed×';
  }

  @override
  String get tapToSkip => 'Atlamak için dokun';

  @override
  String get emptyKutSlot => 'Boş';

  @override
  String tilesLeft(int count) {
    return 'Deste: $count';
  }

  @override
  String tooManyTiles(int max) {
    return 'En fazla $max taş';
  }

  @override
  String get handSingle => 'Tek Taş';

  @override
  String get handPair => 'Çift';

  @override
  String get handTwoPair => 'İki Çift';

  @override
  String get handRun3 => 'Seri-3';

  @override
  String get handGroup3 => 'Grup-3';

  @override
  String get handThreePairs => 'Üç Çift';

  @override
  String get handRun4 => 'Seri-4';

  @override
  String get handRainbowRun => 'Alaca Seri';

  @override
  String get handRun5 => 'Seri-5';

  @override
  String get handGroup4 => 'Grup-4';

  @override
  String get handRun6 => 'Seri-6';

  @override
  String get handSkyMeld => 'Gök Per';

  @override
  String get kutUmayAnaName => 'Umay Ana';

  @override
  String get kutUmayAnaDesc => 'Her Kırmızı taş sayıldığında +4 Çarpan.';

  @override
  String get kutAyAtaName => 'Ay Ata';

  @override
  String get kutAyAtaDesc => 'Her Mavi taş sayıldığında +30 Puan.';

  @override
  String get kutGunAnaName => 'Gün Ana';

  @override
  String get kutGunAnaDesc => 'Her Sarı taş sayıldığında +3 Çarpan.';

  @override
  String get kutKaraDagName => 'Kara Dağ';

  @override
  String get kutKaraDagDesc =>
      'Her Siyah taş sayıldığında +20 Puan ve +1 Çarpan.';

  @override
  String get kutBozkurtName => 'Bozkurt';

  @override
  String get kutBozkurtDesc => 'Seri içeren ellerde +10 Çarpan.';

  @override
  String get kutAsenaName => 'Asena';

  @override
  String get kutAsenaDesc => 'Grup içeren ellerde ×2 Çarpan.';

  @override
  String get kutTulparName => 'Tulpar';

  @override
  String get kutTulparDesc => 'Kalan her Değiştir hakkı için +15 Puan.';

  @override
  String get kutKopuzName => 'Kopuz';

  @override
  String get kutKopuzDesc => '3 veya daha az taşla oynanan ellerde +20 Çarpan.';

  @override
  String get kutKamDavuluName => 'Kam Davulu';

  @override
  String get kutKamDavuluDesc =>
      'Her elin ilk sayılan taşı iki kez tetiklenir.';

  @override
  String get kutErlikPazarligiName => 'Erlik\'in Pazarlığı';

  @override
  String get kutErlikPazarligiDesc => '×3 Çarpan, ama El hakkı 1 azalır.';

  @override
  String get kutUlgenIsigiName => 'Ülgen\'in Işığı';

  @override
  String get kutUlgenIsigiDesc =>
      'Okey per içinde joker olarak kullanılırsa ×3 Çarpan.';

  @override
  String get kutKayraHanName => 'Kayra Han';

  @override
  String get kutKayraHanDesc =>
      'Her Destan kullanıldığında kalıcı olarak ×0.25 Çarpan kazanır.';

  @override
  String get kutZumruduankaName => 'Zümrüdüanka';

  @override
  String get kutZumruduankaDesc =>
      'Kaybedecekken hedefin %25\'ine ulaştıysan bir kez kurtarır, sonra yok olur.';

  @override
  String get kutOguzKaganName => 'Oğuz Kağan';

  @override
  String get kutOguzKaganDesc => 'Seri-5 ve üstü ellerde +50 Puan, +5 Çarpan.';

  @override
  String get kutDedeKorkutName => 'Dede Korkut';

  @override
  String get kutDedeKorkutDesc =>
      'Tur sonunda kalan her El hakkı için +2 Akçe.';

  @override
  String get kutKervanName => 'Kervan';

  @override
  String get kutKervanDesc => 'Pazar\'daki ilk yenileme ücretsiz.';

  @override
  String get kutYadaTasiName => 'Yada Taşı';

  @override
  String get kutYadaTasiDesc => 'Bu tur atılan her taş için +1 Çarpan birikir.';

  @override
  String get kutNazarBoncuguName => 'Nazar Boncuğu';

  @override
  String get kutNazarBoncuguDesc => 'Boss turlarında +15 Çarpan.';

  @override
  String get kutErgenekonName => 'Ergenekon';

  @override
  String get kutErgenekonDesc =>
      'İstakada tutulan Demir taşlar ayrıca +20 Puan verir.';

  @override
  String get kutGokBoruName => 'Gök Börü';

  @override
  String get kutGokBoruDesc =>
      'Her Grup-4 oynandığında kalıcı olarak +1 ×Çarpan kazanır.';

  @override
  String popupChips(String value) {
    return '+$value';
  }

  @override
  String popupMult(String value) {
    return '+$value Çarpan';
  }

  @override
  String popupXMult(String value) {
    return '×$value Çarpan';
  }

  @override
  String popupMoney(String value) {
    return '+$value Akçe';
  }

  @override
  String get popupAgain => 'Tekrar!';

  @override
  String get popupBroken => 'Kırıldı!';

  @override
  String get popupDebuffed => 'Sayılmadı';

  @override
  String get popupBossZero => 'Erlik: 0';

  @override
  String popupBossHalf(String value) {
    return '×$value Skor';
  }

  @override
  String handScoreTotal(int score) {
    return '+$score';
  }

  @override
  String get countedColorHint => 'Sayılan renk';

  @override
  String get playAreaHint => 'Taşları sürükleyerek diz, dokunarak seç';
}
