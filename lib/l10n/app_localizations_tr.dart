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
  String get kutKopuzDesc => '3 veya daha az taşla oynanan ellerde +15 Çarpan.';

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
  String get kutOguzKaganDesc => 'Seri-5 ve üstü ellerde +60 Puan, +8 Çarpan.';

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
      'İstakada tutulan Demir taşlar ayrıca +30 Puan verir.';

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

  @override
  String get menuSubtitle => 'Yeraltından Gök\'e sekiz kat';

  @override
  String get menuNewRun => 'Yeni Koşu';

  @override
  String get menuContinue => 'Devam Et';

  @override
  String get menuCollection => 'Koleksiyon';

  @override
  String get menuSettings => 'Ayarlar';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get worldUnderworld => 'Yeraltı';

  @override
  String get worldMiddle => 'Yeryüzü';

  @override
  String get worldSky => 'Gökyüzü';

  @override
  String get endlessLabel => 'Sonsuz Gök';

  @override
  String rewardLabel(int amount) {
    return 'Ödül: $amount Akçe';
  }

  @override
  String get startRound => 'Başla';

  @override
  String get skipRound => 'Atla';

  @override
  String skipReward(String reward) {
    return 'Atlarsan: $reward';
  }

  @override
  String get statusDone => 'Tamamlandı';

  @override
  String get statusSkipped => 'Atlandı';

  @override
  String get statusUpcoming => 'Sırada';

  @override
  String tagMoney(int amount) {
    return '+$amount Akçe';
  }

  @override
  String get tagKutPack => 'Bedava Kut Kesesi';

  @override
  String get tagDestanPack => 'Bedava Destan Kesesi';

  @override
  String get tagTilsimPack => 'Bedava Tılsım Kesesi';

  @override
  String get bossTepegozName => 'Tepegöz';

  @override
  String get bossTepegozDesc => 'Her elde yalnızca tek bir renk sayılır.';

  @override
  String get bossErlikHanName => 'Erlik Han';

  @override
  String get bossErlikHanDesc => 'Oynanan ilk el puan vermez.';

  @override
  String get bossAlKarisiName => 'Al Karısı';

  @override
  String get bossAlKarisiDesc => 'Her El\'den sonra istakadan bir taş çalınır.';

  @override
  String get bossYelAnaName => 'Yel Ana';

  @override
  String get bossYelAnaDesc =>
      'Her El\'den sonra istaka karışır, taşlar kapalı gelir.';

  @override
  String get bossSahmeranName => 'Şahmeran';

  @override
  String get bossSahmeranDesc => 'Seri içeren eller yarım puan verir.';

  @override
  String get bossAlbastiName => 'Albastı';

  @override
  String get bossAlbastiDesc => 'Değiştir hakkı yok.';

  @override
  String get bossDemirkiyakName => 'Demirkıyak';

  @override
  String get bossDemirkiyakDesc => 'El başına en fazla 4 taş oynanabilir.';

  @override
  String get bossKaraKusName => 'Kara Kuş';

  @override
  String get bossKaraKusDesc => 'Okey bu turda joker değil.';

  @override
  String get cashoutTitle => 'Tur kazanıldı';

  @override
  String get cashRoundReward => 'Tur ödülü';

  @override
  String get cashHandsLeft => 'Kalan El';

  @override
  String get cashInterest => 'Faiz';

  @override
  String get cashGoldTiles => 'Altın taşlar';

  @override
  String get cashTileMoney => 'Altın Tamgalar';

  @override
  String get cashTotal => 'Toplam';

  @override
  String get collect => 'Topla';

  @override
  String savedBy(String name) {
    return '$name seni kurtardı!';
  }

  @override
  String get shopTitle => 'Pazar';

  @override
  String reroll(int cost) {
    return 'Yenile · $cost';
  }

  @override
  String get rerollFree => 'Yenile · bedava';

  @override
  String get leaveShop => 'Sonraki tur';

  @override
  String get buy => 'Al';

  @override
  String sell(int amount) {
    return 'Sat · $amount';
  }

  @override
  String get use => 'Kullan';

  @override
  String price(int price) {
    return '$price Akçe';
  }

  @override
  String get soldOut => 'Satıldı';

  @override
  String get voucherTitle => 'Kupon';

  @override
  String get packsTitle => 'Keseler';

  @override
  String get itemsTitle => 'Tezgâh';

  @override
  String get packKut => 'Kut Kesesi';

  @override
  String get packDestan => 'Destan Kesesi';

  @override
  String get packTilsim => 'Tılsım Kesesi';

  @override
  String get packTile => 'Taş Kesesi';

  @override
  String packDesc(int count) {
    return '$count seçenekten birini al';
  }

  @override
  String get packChoose => 'Birini seç';

  @override
  String get skip => 'Geç';

  @override
  String get kutsTitle => 'Kut\'lar';

  @override
  String get consumablesTitle => 'Eşyalar';

  @override
  String get errNotEnoughMoney => 'Yeterli Akçe yok';

  @override
  String get errNoKutSlot => 'Kut yuvaları dolu';

  @override
  String get errNoConsumableSlot => 'Eşya yuvaları dolu';

  @override
  String get errInvalidTarget => 'Önce istakadan uygun sayıda taş seç';

  @override
  String get errGeneric => 'Bu şimdi yapılamaz';

  @override
  String get runWonTitle => 'Tengri\'ye ulaştın!';

  @override
  String get runLostTitle => 'Koşu bitti';

  @override
  String get statsFloor => 'Ulaşılan kat';

  @override
  String get statsRounds => 'Kazanılan tur';

  @override
  String get statsHands => 'Oynanan el';

  @override
  String get statsBestHand => 'En yüksek el';

  @override
  String get statsTotalScore => 'Toplam skor';

  @override
  String get statsFavoriteKut => 'En çok tetiklenen Kut';

  @override
  String get statsFavoriteHand => 'En çok oynanan el';

  @override
  String get statsSeed => 'Seed';

  @override
  String get continueEndless => 'Sonsuz Gök\'e devam';

  @override
  String get mainMenu => 'Ana Menü';

  @override
  String handWithLevel(String hand, int level) {
    return '$hand · Sv.$level';
  }

  @override
  String get rarityCommon => 'Yaygın';

  @override
  String get rarityRare => 'Nadir';

  @override
  String get rarityLegendary => 'Efsanevi';

  @override
  String destanDesc(String hand) {
    return '$hand seviyesini 1 artırır.';
  }

  @override
  String tilsimTargetHint(int count) {
    return 'İstakadan en fazla $count taş seç, sonra Kullan.';
  }

  @override
  String get colorRed => 'Kırmızı';

  @override
  String get colorYellow => 'Sarı';

  @override
  String get colorBlue => 'Mavi';

  @override
  String get colorBlack => 'Siyah';

  @override
  String get destanGoc => 'Göç Destanı';

  @override
  String get destanTureyis => 'Türeyiş Destanı';

  @override
  String get destanSatukBugra => 'Satuk Buğra Han Destanı';

  @override
  String get destanAlpamis => 'Alpamış Destanı';

  @override
  String get destanKoroglu => 'Köroğlu Destanı';

  @override
  String get destanDedeKorkut => 'Dede Korkut Hikâyeleri';

  @override
  String get destanManas => 'Manas Destanı';

  @override
  String get destanSu => 'Şu Destanı';

  @override
  String get destanOguzKagan => 'Oğuz Kağan Destanı';

  @override
  String get destanErgenekon => 'Ergenekon Destanı';

  @override
  String get destanErTostuk => 'Er Töstük Destanı';

  @override
  String get destanYaratilis => 'Yaratılış Destanı';

  @override
  String get tilsimDemirciName => 'Demirci Tılsımı';

  @override
  String get tilsimDemirciDesc => 'En fazla 2 taşı Demir taşa çevirir.';

  @override
  String get tilsimSimyaciName => 'Simyacı Tılsımı';

  @override
  String get tilsimSimyaciDesc => '1 taşı Altın taşa çevirir.';

  @override
  String get tilsimRenkName => 'Renk Tılsımı';

  @override
  String tilsimRenkDesc(String color) {
    return 'En fazla 3 taşı $color renge boyar.';
  }

  @override
  String get tilsimAynaName => 'Ayna Tılsımı';

  @override
  String get tilsimAynaDesc => 'Seçili taşın bir kopyasını desteye ekler.';

  @override
  String get tilsimYakmaName => 'Yakma Tılsımı';

  @override
  String get tilsimYakmaDesc => 'En fazla 2 taşı desteden kalıcı olarak siler.';

  @override
  String get tilsimKamName => 'Kam Tılsımı';

  @override
  String get tilsimKamDesc => 'Rastgele bir Kut yaratır (boş yuva gerekir).';

  @override
  String get tilsimTamgaName => 'Tamga Tılsımı';

  @override
  String get tilsimTamgaDesc => 'Seçili taşa rastgele bir Tamga basar.';

  @override
  String get tilsimYukseltmeName => 'Yükseltme Tılsımı';

  @override
  String get tilsimYukseltmeDesc => 'En fazla 2 taşın sayısını 1 artırır.';

  @override
  String get voucherEkElName => 'Ek El';

  @override
  String get voucherEkElDesc => 'Her turda +1 El.';

  @override
  String get voucherEkDegistirName => 'Ek Değiştir';

  @override
  String get voucherEkDegistirDesc => 'Her turda +1 Değiştir.';

  @override
  String get voucherGenisIstakaName => 'Geniş İstaka';

  @override
  String get voucherGenisIstakaDesc => 'İstakaya +1 taş.';

  @override
  String get voucherKutYuvasiName => 'Kut Yuvası';

  @override
  String get voucherKutYuvasiDesc => '+1 Kut yuvası.';

  @override
  String get voucherHeybeName => 'Heybe';

  @override
  String get voucherHeybeDesc => '+1 eşya yuvası.';

  @override
  String get voucherPazarlikName => 'Pazarlık';

  @override
  String get voucherPazarlikDesc => 'Pazar\'da her şey %25 indirimli.';

  @override
  String get voucherHazineName => 'Hazine';

  @override
  String get voucherHazineDesc => 'Faiz sınırı +5.';

  @override
  String get enhBone => 'Kemik: +30 Puan';

  @override
  String get enhIron => 'Demir: istakada tutulunca ×1.5 Çarpan';

  @override
  String get enhGold => 'Altın: tur sonunda istakadaysa +3 Akçe';

  @override
  String get enhCrystal => 'Kristal: ×2 Çarpan, 1/4 kırılır';

  @override
  String get enhSkyStone => 'Gök Taşı: her renk sayılır';

  @override
  String get sealCrimson => 'Kızıl Tamga: iki kez tetiklenir';

  @override
  String get sealGold => 'Altın Tamga: sayılınca +3 Akçe';

  @override
  String get sealSky => 'Gök Tamga: tur sonunda Destan yaratır';

  @override
  String get sealPurple => 'Mor Tamga: atılınca Tılsım yaratır';

  @override
  String get tileAdded => 'Desteye eklenir';
}
