// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Gök Taşları';

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

  @override
  String get kutOdAnaName => 'Od Ana';

  @override
  String get kutOdAnaDesc =>
      'Çift içeren ellerde (Çift, İki Çift, Üç Çift) +8 Çarpan.';

  @override
  String get kutYerSuName => 'Yer-Su';

  @override
  String get kutYerSuDesc => 'İstakada tutulan her taş için +1 Çarpan.';

  @override
  String get kutOtukenName => 'Ötüken';

  @override
  String get kutOtukenDesc => 'Elindeki her 5 Akçe için +1 Çarpan.';

  @override
  String get kutKokTengriName => 'Kök Tengri';

  @override
  String get kutKokTengriDesc =>
      'Bu elden sonra kalan her El hakkı için +0,5 ×Çarpan.';

  @override
  String get bossYalmavuzName => 'Yalmavuz';

  @override
  String get bossYalmavuzDesc => '11, 12 ve 13 sayılı taşlar sayılmaz.';

  @override
  String get bossAbasiName => 'Abası';

  @override
  String get bossAbasiDesc => 'İstakaya 2 taş eksik gelir.';

  @override
  String get bossSulmusName => 'Şulmus';

  @override
  String get bossSulmusDesc => 'Tek Taş ve Çift puan vermez.';

  @override
  String get bossKaraKamName => 'Kara Kam';

  @override
  String get bossKaraKamDesc => 'En soldaki Kut bu turda çalışmaz.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingSound => 'Ses efektleri';

  @override
  String get settingMusic => 'Müzik';

  @override
  String get settingVibration => 'Titreşim';

  @override
  String get settingLanguage => 'Dil';

  @override
  String get settingSpeed => 'Oyun hızı';

  @override
  String get settingSpeedDesc => 'Puan animasyonlarının hızı';

  @override
  String get settingColorBlind => 'Renk körü modu';

  @override
  String get settingColorBlindDesc =>
      'Yüksek kontrastlı renkler ve büyük renk sembolleri';

  @override
  String get languageTr => 'Türkçe';

  @override
  String get languageEn => 'English';

  @override
  String get colorBlindPreview => 'Örnek taşlar';

  @override
  String get collectionTitle => 'Koleksiyon';

  @override
  String collectionKuts(int found, int total) {
    return 'Kut\'lar · $found/$total';
  }

  @override
  String collectionBosses(int found, int total) {
    return 'Boss\'lar · $found/$total';
  }

  @override
  String get collectionLocked => 'Henüz açılmadı';

  @override
  String get collectionHint =>
      'Bir koşuda sahip olduğun Kut\'lar burada açılır.';

  @override
  String get profileRuns => 'Başlanan koşu';

  @override
  String get profileWins => 'Kazanılan koşu';

  @override
  String get profileBestHand => 'En yüksek el';

  @override
  String get profileHighestFloor => 'En yüksek kat';

  @override
  String get back => 'Geri';

  @override
  String get newRunConfirmTitle => 'Yeni koşu başlasın mı?';

  @override
  String get newRunConfirmBody => 'Kayıtlı koşun silinecek.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get confirmNewRun => 'Yeni koşu';

  @override
  String savedRunInfo(int floor, int money) {
    return 'Kat $floor · $money Akçe';
  }

  @override
  String get menuHowToPlay => 'Nasıl Oynanır';

  @override
  String get howToTitle => 'Nasıl Oynanır';

  @override
  String get howToGoalTitle => 'Amaç';

  @override
  String get howToGoalBody =>
      'Her turda istakadaki okey taşlarıyla per açıp hedef puana ulaş. 4 El hakkın var; hedefe ulaşamazsan koşu biter. Yeraltından Gök\'e 8 Kat\'ı geçersen Tengri\'ye ulaşırsın.';

  @override
  String get howToTurnTitle => 'Bir tur nasıl geçer';

  @override
  String get howToTurnBody =>
      '• Taşlara dokunarak 1–6 taş seç; ortada el türünü ve puanını görürsün.\n• Oyna: seçili taşlar puan verir, yerlerine yeni taşlar gelir.\n• Değiştir: seçili taşları atıp yenilerini çekersin (turda 3 hak).\n• Taşları sürükleyerek diz ya da Sayı / Renk ile otomatik diz.';

  @override
  String get howToOkeyTitle => 'Gösterge ve Okey';

  @override
  String get howToOkeyBody =>
      'Turun başında bir Gösterge taşı açılır. Onun bir üstü (aynı renk; 13\'ten sonra 1) o turun Okey\'idir; istakada yıldızlı, altın kenarlı görünür. Okey joker\'dir: bir per içinde istediğin taşın yerine geçer ve en iyi değeri kendisi seçer. Göktürk harfli Sahte Okey ise okeyin değerini taşıyan normal bir taştır.';

  @override
  String get howToScoreTitle => 'Puanlama';

  @override
  String get howToScoreBody =>
      'Skor = Puan × Çarpan.\nPuan = el türünün taban puanı + per\'deki taşların sayıları (1 sayılı taş 15 sayılır). Per\'e girmeyen taşlar oynanır ama puan vermez. Kut\'lar, taş geliştirmeleri ve tamgalar Puan ve Çarpan\'ı artırır.';

  @override
  String get howToHandsTitle => 'El türleri';

  @override
  String get howToHandsBody =>
      'Seri: aynı renk, ardışık sayılar (12-13-1 olur, 13-1-2 olmaz). Grup: aynı sayı, farklı renkler. Değerler başlangıç seviyesindedir; Destan\'lar bir el türünü güçlendirir.';

  @override
  String get howToKutTitle => 'Kut\'lar';

  @override
  String get howToKutBody =>
      'Kut\'lar pasif mitolojik güçlerdir (en fazla 5). Her elde soldan sağa tetiklenirler; kartları sürükleyerek sıralarını değiştir. Önce +Çarpan, sonra ×Çarpan veren bir sıra genelde daha çok puan getirir. Karta dokunursan ne yaptığını görürsün.';

  @override
  String get howToShopTitle => 'Akçe, Pazar ve eşyalar';

  @override
  String get howToShopBody =>
      'Turu kazanınca Akçe alırsın: tur ödülü, kalan her El için +1 ve faiz (elindeki her 5 Akçe için +1, en fazla 5). Pazar\'da Kut, Destan, Tılsım, Kese ve Kupon alırsın. Destan bir el türünün seviyesini artırır; Tılsım istakada seçtiğin taşları değiştirir (Demir, Altın, renk, kopya...). Kupon kalıcı bir geliştirmedir.';

  @override
  String get howToBossTitle => 'Katlar ve Boss\'lar';

  @override
  String get howToBossBody =>
      'Her Kat\'ta üç tur vardır: Küçük Sınav, Büyük Sınav ve Boss. Küçük ve Büyük Sınav atlanabilir; atlarsan küçük bir ödül alırsın. Boss atlanamaz ve bir kısıtlama getirir (ör. Kara Kuş\'ta okey joker değildir).';

  @override
  String get howToTipsTitle => 'İpuçları';

  @override
  String get howToTipsBody =>
      '• Seri ve grup başlangıçlarını bir arada tut, tek kalan taşları Değiştir ile at.\n• Gök Per (Grup-3 + Seri-3) ve uzun seriler çok puan verir.\n• Hedefe az El ile ulaşırsan kalan El\'ler Akçe olur.\n• Akçe biriktirmek faiz getirir; her şeyi hemen harcama.';

  @override
  String get howToHelpTooltip => 'Nasıl oynanır?';

  @override
  String get menuDaily => 'Günlük Meydan Okuma';

  @override
  String get dailyTitle => 'Günlük Meydan Okuma';

  @override
  String get dailyIntro =>
      'Bugün herkes aynı taşlarla, aynı Boss\'larla ve aynı Pazar\'la oynar. Tek hakkın var; en yükseğe sen çık.';

  @override
  String get dailyMenuAvailable => 'Bugünün meydan okuması hazır';

  @override
  String dailyMenuInProgress(int floor) {
    return 'Devam ediyor · Kat $floor';
  }

  @override
  String dailyMenuDone(int floor) {
    return 'Bugün tamamlandı · Kat $floor';
  }

  @override
  String get dailyStartingKut => 'Başlangıç Kut\'u';

  @override
  String get dailyBonusTitle => 'Günün lütfu';

  @override
  String dailyBonusMoney(int amount) {
    return '+$amount Akçe ile başla';
  }

  @override
  String get dailyBonusExtraHand => 'Her turda +1 El';

  @override
  String get dailyBonusExtraDiscard => 'Her turda +1 Değiştir';

  @override
  String get dailyBonusExtraHandSize => 'İstakaya +1 taş';

  @override
  String get dailyBonusDiscount => 'Pazar\'da her şey %25 indirimli';

  @override
  String get dailyBonusInterest => 'Faiz sınırı +5';

  @override
  String get dailyStart => 'Başla';

  @override
  String get dailyContinue => 'Devam Et';

  @override
  String get dailyDoneButton => 'Yarın yeni meydan okuma';

  @override
  String get dailyResultTitle => 'Bugünkü sonucun';

  @override
  String dailyResultLine(int floor, int score) {
    return 'Kat $floor · $score puan';
  }

  @override
  String get dailyResultWon => 'Tengri\'ye ulaştın!';

  @override
  String get dailyResultOngoing => 'devam ediyor';

  @override
  String get dailyShare => 'Sonucu paylaş';

  @override
  String get dailyCopied => 'Sonuç panoya kopyalandı';

  @override
  String dailyShareText(
    String date,
    int floor,
    int score,
    String won,
    String seed,
  ) {
    return 'Gök Taşları · Günlük $date\nKat $floor · $score puan$won\n$seed';
  }

  @override
  String get dailyShareWon => ' · Tengri\'ye ulaştım ★';

  @override
  String get dailyHistory => 'Son günler';

  @override
  String get dailyNoHistory => 'Henüz günlük sonuç yok.';

  @override
  String get dailyTag => 'Günlük';

  @override
  String get leaderboardTitle => 'Günün sıralaması';

  @override
  String get leaderboardUnavailable => 'Çevrimiçi sıralama bu sürümde kapalı.';

  @override
  String get leaderboardEmpty => 'Bugün henüz sonuç yok. İlk sen ol!';

  @override
  String get leaderboardError => 'Sıralama şu an alınamadı.';

  @override
  String get leaderboardRefresh => 'Yenile';

  @override
  String get leaderboardYou => 'Sen';

  @override
  String get leaderboardSomeone => 'Bir oyuncu';

  @override
  String leaderboardYourRank(int rank, int total) {
    return 'Bugün $rank. sıradasın · $total oyuncu';
  }

  @override
  String leaderboardRow(int floor, int score) {
    return 'Kat $floor · $score';
  }

  @override
  String get leaderboardOngoing => 'sürüyor';

  @override
  String get settingPlayerName => 'Oyuncu adı';

  @override
  String get settingPlayerNameDesc =>
      'Günlük sıralamada diğer oyunculara görünen ad (en çok 20 harf). Boş bırakırsan \"Bir oyuncu\" görünür.';

  @override
  String get leaderboardNameHint =>
      'Sıralamada adının görünmesi için Ayarlar\'dan oyuncu adı belirle.';
}
