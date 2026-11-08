import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('tr'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tengri\'nin Taşları'**
  String get appTitle;

  /// No description provided for @target.
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get target;

  /// No description provided for @score.
  ///
  /// In tr, this message translates to:
  /// **'Skor'**
  String get score;

  /// No description provided for @hands.
  ///
  /// In tr, this message translates to:
  /// **'El'**
  String get hands;

  /// No description provided for @discards.
  ///
  /// In tr, this message translates to:
  /// **'Değiştir'**
  String get discards;

  /// No description provided for @money.
  ///
  /// In tr, this message translates to:
  /// **'Akçe'**
  String get money;

  /// No description provided for @floorLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kat {floor}'**
  String floorLabel(int floor);

  /// No description provided for @roundSmall.
  ///
  /// In tr, this message translates to:
  /// **'Küçük Sınav'**
  String get roundSmall;

  /// No description provided for @roundBig.
  ///
  /// In tr, this message translates to:
  /// **'Büyük Sınav'**
  String get roundBig;

  /// No description provided for @roundBoss.
  ///
  /// In tr, this message translates to:
  /// **'Boss'**
  String get roundBoss;

  /// No description provided for @indicator.
  ///
  /// In tr, this message translates to:
  /// **'Gösterge'**
  String get indicator;

  /// No description provided for @okey.
  ///
  /// In tr, this message translates to:
  /// **'Okey'**
  String get okey;

  /// No description provided for @okeyNotWild.
  ///
  /// In tr, this message translates to:
  /// **'Joker değil'**
  String get okeyNotWild;

  /// No description provided for @play.
  ///
  /// In tr, this message translates to:
  /// **'Oyna'**
  String get play;

  /// No description provided for @discard.
  ///
  /// In tr, this message translates to:
  /// **'Değiştir'**
  String get discard;

  /// No description provided for @sortByNumber.
  ///
  /// In tr, this message translates to:
  /// **'Sayı'**
  String get sortByNumber;

  /// No description provided for @sortByColor.
  ///
  /// In tr, this message translates to:
  /// **'Renk'**
  String get sortByColor;

  /// No description provided for @selectTiles.
  ///
  /// In tr, this message translates to:
  /// **'Oynamak için taş seç'**
  String get selectTiles;

  /// No description provided for @chips.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get chips;

  /// No description provided for @mult.
  ///
  /// In tr, this message translates to:
  /// **'Çarpan'**
  String get mult;

  /// No description provided for @roundWon.
  ///
  /// In tr, this message translates to:
  /// **'Tur kazanıldı!'**
  String get roundWon;

  /// No description provided for @roundLost.
  ///
  /// In tr, this message translates to:
  /// **'Koşu bitti'**
  String get roundLost;

  /// No description provided for @finalScore.
  ///
  /// In tr, this message translates to:
  /// **'Skor: {score} / {target}'**
  String finalScore(int score, int target);

  /// No description provided for @bestHand.
  ///
  /// In tr, this message translates to:
  /// **'En iyi el: {score}'**
  String bestHand(int score);

  /// No description provided for @handsLeftBonus.
  ///
  /// In tr, this message translates to:
  /// **'Kalan El: {count}'**
  String handsLeftBonus(int count);

  /// No description provided for @newRound.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Tur'**
  String get newRound;

  /// No description provided for @tryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tryAgain;

  /// No description provided for @seedLabel.
  ///
  /// In tr, this message translates to:
  /// **'Seed: {code}'**
  String seedLabel(String code);

  /// No description provided for @speedLabel.
  ///
  /// In tr, this message translates to:
  /// **'{speed}×'**
  String speedLabel(int speed);

  /// No description provided for @tapToSkip.
  ///
  /// In tr, this message translates to:
  /// **'Atlamak için dokun'**
  String get tapToSkip;

  /// No description provided for @emptyKutSlot.
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get emptyKutSlot;

  /// No description provided for @tilesLeft.
  ///
  /// In tr, this message translates to:
  /// **'Deste: {count}'**
  String tilesLeft(int count);

  /// No description provided for @tooManyTiles.
  ///
  /// In tr, this message translates to:
  /// **'En fazla {max} taş'**
  String tooManyTiles(int max);

  /// No description provided for @handSingle.
  ///
  /// In tr, this message translates to:
  /// **'Tek Taş'**
  String get handSingle;

  /// No description provided for @handPair.
  ///
  /// In tr, this message translates to:
  /// **'Çift'**
  String get handPair;

  /// No description provided for @handTwoPair.
  ///
  /// In tr, this message translates to:
  /// **'İki Çift'**
  String get handTwoPair;

  /// No description provided for @handRun3.
  ///
  /// In tr, this message translates to:
  /// **'Seri-3'**
  String get handRun3;

  /// No description provided for @handGroup3.
  ///
  /// In tr, this message translates to:
  /// **'Grup-3'**
  String get handGroup3;

  /// No description provided for @handThreePairs.
  ///
  /// In tr, this message translates to:
  /// **'Üç Çift'**
  String get handThreePairs;

  /// No description provided for @handRun4.
  ///
  /// In tr, this message translates to:
  /// **'Seri-4'**
  String get handRun4;

  /// No description provided for @handRainbowRun.
  ///
  /// In tr, this message translates to:
  /// **'Alaca Seri'**
  String get handRainbowRun;

  /// No description provided for @handRun5.
  ///
  /// In tr, this message translates to:
  /// **'Seri-5'**
  String get handRun5;

  /// No description provided for @handGroup4.
  ///
  /// In tr, this message translates to:
  /// **'Grup-4'**
  String get handGroup4;

  /// No description provided for @handRun6.
  ///
  /// In tr, this message translates to:
  /// **'Seri-6'**
  String get handRun6;

  /// No description provided for @handSkyMeld.
  ///
  /// In tr, this message translates to:
  /// **'Gök Per'**
  String get handSkyMeld;

  /// No description provided for @kutUmayAnaName.
  ///
  /// In tr, this message translates to:
  /// **'Umay Ana'**
  String get kutUmayAnaName;

  /// No description provided for @kutUmayAnaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her Kırmızı taş sayıldığında +4 Çarpan.'**
  String get kutUmayAnaDesc;

  /// No description provided for @kutAyAtaName.
  ///
  /// In tr, this message translates to:
  /// **'Ay Ata'**
  String get kutAyAtaName;

  /// No description provided for @kutAyAtaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her Mavi taş sayıldığında +30 Puan.'**
  String get kutAyAtaDesc;

  /// No description provided for @kutGunAnaName.
  ///
  /// In tr, this message translates to:
  /// **'Gün Ana'**
  String get kutGunAnaName;

  /// No description provided for @kutGunAnaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her Sarı taş sayıldığında +3 Çarpan.'**
  String get kutGunAnaDesc;

  /// No description provided for @kutKaraDagName.
  ///
  /// In tr, this message translates to:
  /// **'Kara Dağ'**
  String get kutKaraDagName;

  /// No description provided for @kutKaraDagDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her Siyah taş sayıldığında +20 Puan ve +1 Çarpan.'**
  String get kutKaraDagDesc;

  /// No description provided for @kutBozkurtName.
  ///
  /// In tr, this message translates to:
  /// **'Bozkurt'**
  String get kutBozkurtName;

  /// No description provided for @kutBozkurtDesc.
  ///
  /// In tr, this message translates to:
  /// **'Seri içeren ellerde +10 Çarpan.'**
  String get kutBozkurtDesc;

  /// No description provided for @kutAsenaName.
  ///
  /// In tr, this message translates to:
  /// **'Asena'**
  String get kutAsenaName;

  /// No description provided for @kutAsenaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Grup içeren ellerde ×2 Çarpan.'**
  String get kutAsenaDesc;

  /// No description provided for @kutTulparName.
  ///
  /// In tr, this message translates to:
  /// **'Tulpar'**
  String get kutTulparName;

  /// No description provided for @kutTulparDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kalan her Değiştir hakkı için +15 Puan.'**
  String get kutTulparDesc;

  /// No description provided for @kutKopuzName.
  ///
  /// In tr, this message translates to:
  /// **'Kopuz'**
  String get kutKopuzName;

  /// No description provided for @kutKopuzDesc.
  ///
  /// In tr, this message translates to:
  /// **'3 veya daha az taşla oynanan ellerde +15 Çarpan.'**
  String get kutKopuzDesc;

  /// No description provided for @kutKamDavuluName.
  ///
  /// In tr, this message translates to:
  /// **'Kam Davulu'**
  String get kutKamDavuluName;

  /// No description provided for @kutKamDavuluDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her elin ilk sayılan taşı iki kez tetiklenir.'**
  String get kutKamDavuluDesc;

  /// No description provided for @kutErlikPazarligiName.
  ///
  /// In tr, this message translates to:
  /// **'Erlik\'in Pazarlığı'**
  String get kutErlikPazarligiName;

  /// No description provided for @kutErlikPazarligiDesc.
  ///
  /// In tr, this message translates to:
  /// **'×3 Çarpan, ama El hakkı 1 azalır.'**
  String get kutErlikPazarligiDesc;

  /// No description provided for @kutUlgenIsigiName.
  ///
  /// In tr, this message translates to:
  /// **'Ülgen\'in Işığı'**
  String get kutUlgenIsigiName;

  /// No description provided for @kutUlgenIsigiDesc.
  ///
  /// In tr, this message translates to:
  /// **'Okey per içinde joker olarak kullanılırsa ×3 Çarpan.'**
  String get kutUlgenIsigiDesc;

  /// No description provided for @kutKayraHanName.
  ///
  /// In tr, this message translates to:
  /// **'Kayra Han'**
  String get kutKayraHanName;

  /// No description provided for @kutKayraHanDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her Destan kullanıldığında kalıcı olarak ×0.25 Çarpan kazanır.'**
  String get kutKayraHanDesc;

  /// No description provided for @kutZumruduankaName.
  ///
  /// In tr, this message translates to:
  /// **'Zümrüdüanka'**
  String get kutZumruduankaName;

  /// No description provided for @kutZumruduankaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kaybedecekken hedefin %25\'ine ulaştıysan bir kez kurtarır, sonra yok olur.'**
  String get kutZumruduankaDesc;

  /// No description provided for @kutOguzKaganName.
  ///
  /// In tr, this message translates to:
  /// **'Oğuz Kağan'**
  String get kutOguzKaganName;

  /// No description provided for @kutOguzKaganDesc.
  ///
  /// In tr, this message translates to:
  /// **'Seri-5 ve üstü ellerde +60 Puan, +8 Çarpan.'**
  String get kutOguzKaganDesc;

  /// No description provided for @kutDedeKorkutName.
  ///
  /// In tr, this message translates to:
  /// **'Dede Korkut'**
  String get kutDedeKorkutName;

  /// No description provided for @kutDedeKorkutDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tur sonunda kalan her El hakkı için +2 Akçe.'**
  String get kutDedeKorkutDesc;

  /// No description provided for @kutKervanName.
  ///
  /// In tr, this message translates to:
  /// **'Kervan'**
  String get kutKervanName;

  /// No description provided for @kutKervanDesc.
  ///
  /// In tr, this message translates to:
  /// **'Pazar\'daki ilk yenileme ücretsiz.'**
  String get kutKervanDesc;

  /// No description provided for @kutYadaTasiName.
  ///
  /// In tr, this message translates to:
  /// **'Yada Taşı'**
  String get kutYadaTasiName;

  /// No description provided for @kutYadaTasiDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu tur atılan her taş için +1 Çarpan birikir.'**
  String get kutYadaTasiDesc;

  /// No description provided for @kutNazarBoncuguName.
  ///
  /// In tr, this message translates to:
  /// **'Nazar Boncuğu'**
  String get kutNazarBoncuguName;

  /// No description provided for @kutNazarBoncuguDesc.
  ///
  /// In tr, this message translates to:
  /// **'Boss turlarında +15 Çarpan.'**
  String get kutNazarBoncuguDesc;

  /// No description provided for @kutErgenekonName.
  ///
  /// In tr, this message translates to:
  /// **'Ergenekon'**
  String get kutErgenekonName;

  /// No description provided for @kutErgenekonDesc.
  ///
  /// In tr, this message translates to:
  /// **'İstakada tutulan Demir taşlar ayrıca +30 Puan verir.'**
  String get kutErgenekonDesc;

  /// No description provided for @kutGokBoruName.
  ///
  /// In tr, this message translates to:
  /// **'Gök Börü'**
  String get kutGokBoruName;

  /// No description provided for @kutGokBoruDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her Grup-4 oynandığında kalıcı olarak +1 ×Çarpan kazanır.'**
  String get kutGokBoruDesc;

  /// No description provided for @popupChips.
  ///
  /// In tr, this message translates to:
  /// **'+{value}'**
  String popupChips(String value);

  /// No description provided for @popupMult.
  ///
  /// In tr, this message translates to:
  /// **'+{value} Çarpan'**
  String popupMult(String value);

  /// No description provided for @popupXMult.
  ///
  /// In tr, this message translates to:
  /// **'×{value} Çarpan'**
  String popupXMult(String value);

  /// No description provided for @popupMoney.
  ///
  /// In tr, this message translates to:
  /// **'+{value} Akçe'**
  String popupMoney(String value);

  /// No description provided for @popupAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar!'**
  String get popupAgain;

  /// No description provided for @popupBroken.
  ///
  /// In tr, this message translates to:
  /// **'Kırıldı!'**
  String get popupBroken;

  /// No description provided for @popupDebuffed.
  ///
  /// In tr, this message translates to:
  /// **'Sayılmadı'**
  String get popupDebuffed;

  /// No description provided for @popupBossZero.
  ///
  /// In tr, this message translates to:
  /// **'Erlik: 0'**
  String get popupBossZero;

  /// No description provided for @popupBossHalf.
  ///
  /// In tr, this message translates to:
  /// **'×{value} Skor'**
  String popupBossHalf(String value);

  /// No description provided for @handScoreTotal.
  ///
  /// In tr, this message translates to:
  /// **'+{score}'**
  String handScoreTotal(int score);

  /// No description provided for @countedColorHint.
  ///
  /// In tr, this message translates to:
  /// **'Sayılan renk'**
  String get countedColorHint;

  /// No description provided for @playAreaHint.
  ///
  /// In tr, this message translates to:
  /// **'Taşları sürükleyerek diz, dokunarak seç'**
  String get playAreaHint;

  /// No description provided for @menuSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeraltından Gök\'e sekiz kat'**
  String get menuSubtitle;

  /// No description provided for @menuNewRun.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Koşu'**
  String get menuNewRun;

  /// No description provided for @menuContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get menuContinue;

  /// No description provided for @menuCollection.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon'**
  String get menuCollection;

  /// No description provided for @menuSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get menuSettings;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Yakında'**
  String get comingSoon;

  /// No description provided for @worldUnderworld.
  ///
  /// In tr, this message translates to:
  /// **'Yeraltı'**
  String get worldUnderworld;

  /// No description provided for @worldMiddle.
  ///
  /// In tr, this message translates to:
  /// **'Yeryüzü'**
  String get worldMiddle;

  /// No description provided for @worldSky.
  ///
  /// In tr, this message translates to:
  /// **'Gökyüzü'**
  String get worldSky;

  /// No description provided for @endlessLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sonsuz Gök'**
  String get endlessLabel;

  /// No description provided for @rewardLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ödül: {amount} Akçe'**
  String rewardLabel(int amount);

  /// No description provided for @startRound.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get startRound;

  /// No description provided for @skipRound.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get skipRound;

  /// No description provided for @skipReward.
  ///
  /// In tr, this message translates to:
  /// **'Atlarsan: {reward}'**
  String skipReward(String reward);

  /// No description provided for @statusDone.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get statusDone;

  /// No description provided for @statusSkipped.
  ///
  /// In tr, this message translates to:
  /// **'Atlandı'**
  String get statusSkipped;

  /// No description provided for @statusUpcoming.
  ///
  /// In tr, this message translates to:
  /// **'Sırada'**
  String get statusUpcoming;

  /// No description provided for @tagMoney.
  ///
  /// In tr, this message translates to:
  /// **'+{amount} Akçe'**
  String tagMoney(int amount);

  /// No description provided for @tagKutPack.
  ///
  /// In tr, this message translates to:
  /// **'Bedava Kut Kesesi'**
  String get tagKutPack;

  /// No description provided for @tagDestanPack.
  ///
  /// In tr, this message translates to:
  /// **'Bedava Destan Kesesi'**
  String get tagDestanPack;

  /// No description provided for @tagTilsimPack.
  ///
  /// In tr, this message translates to:
  /// **'Bedava Tılsım Kesesi'**
  String get tagTilsimPack;

  /// No description provided for @bossTepegozName.
  ///
  /// In tr, this message translates to:
  /// **'Tepegöz'**
  String get bossTepegozName;

  /// No description provided for @bossTepegozDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her elde yalnızca tek bir renk sayılır.'**
  String get bossTepegozDesc;

  /// No description provided for @bossErlikHanName.
  ///
  /// In tr, this message translates to:
  /// **'Erlik Han'**
  String get bossErlikHanName;

  /// No description provided for @bossErlikHanDesc.
  ///
  /// In tr, this message translates to:
  /// **'Oynanan ilk el puan vermez.'**
  String get bossErlikHanDesc;

  /// No description provided for @bossAlKarisiName.
  ///
  /// In tr, this message translates to:
  /// **'Al Karısı'**
  String get bossAlKarisiName;

  /// No description provided for @bossAlKarisiDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her El\'den sonra istakadan bir taş çalınır.'**
  String get bossAlKarisiDesc;

  /// No description provided for @bossYelAnaName.
  ///
  /// In tr, this message translates to:
  /// **'Yel Ana'**
  String get bossYelAnaName;

  /// No description provided for @bossYelAnaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her El\'den sonra istaka karışır, taşlar kapalı gelir.'**
  String get bossYelAnaDesc;

  /// No description provided for @bossSahmeranName.
  ///
  /// In tr, this message translates to:
  /// **'Şahmeran'**
  String get bossSahmeranName;

  /// No description provided for @bossSahmeranDesc.
  ///
  /// In tr, this message translates to:
  /// **'Seri içeren eller yarım puan verir.'**
  String get bossSahmeranDesc;

  /// No description provided for @bossAlbastiName.
  ///
  /// In tr, this message translates to:
  /// **'Albastı'**
  String get bossAlbastiName;

  /// No description provided for @bossAlbastiDesc.
  ///
  /// In tr, this message translates to:
  /// **'Değiştir hakkı yok.'**
  String get bossAlbastiDesc;

  /// No description provided for @bossDemirkiyakName.
  ///
  /// In tr, this message translates to:
  /// **'Demirkıyak'**
  String get bossDemirkiyakName;

  /// No description provided for @bossDemirkiyakDesc.
  ///
  /// In tr, this message translates to:
  /// **'El başına en fazla 4 taş oynanabilir.'**
  String get bossDemirkiyakDesc;

  /// No description provided for @bossKaraKusName.
  ///
  /// In tr, this message translates to:
  /// **'Kara Kuş'**
  String get bossKaraKusName;

  /// No description provided for @bossKaraKusDesc.
  ///
  /// In tr, this message translates to:
  /// **'Okey bu turda joker değil.'**
  String get bossKaraKusDesc;

  /// No description provided for @cashoutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tur kazanıldı'**
  String get cashoutTitle;

  /// No description provided for @cashRoundReward.
  ///
  /// In tr, this message translates to:
  /// **'Tur ödülü'**
  String get cashRoundReward;

  /// No description provided for @cashHandsLeft.
  ///
  /// In tr, this message translates to:
  /// **'Kalan El'**
  String get cashHandsLeft;

  /// No description provided for @cashInterest.
  ///
  /// In tr, this message translates to:
  /// **'Faiz'**
  String get cashInterest;

  /// No description provided for @cashGoldTiles.
  ///
  /// In tr, this message translates to:
  /// **'Altın taşlar'**
  String get cashGoldTiles;

  /// No description provided for @cashTileMoney.
  ///
  /// In tr, this message translates to:
  /// **'Altın Tamgalar'**
  String get cashTileMoney;

  /// No description provided for @cashTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get cashTotal;

  /// No description provided for @collect.
  ///
  /// In tr, this message translates to:
  /// **'Topla'**
  String get collect;

  /// No description provided for @savedBy.
  ///
  /// In tr, this message translates to:
  /// **'{name} seni kurtardı!'**
  String savedBy(String name);

  /// No description provided for @shopTitle.
  ///
  /// In tr, this message translates to:
  /// **'Pazar'**
  String get shopTitle;

  /// No description provided for @reroll.
  ///
  /// In tr, this message translates to:
  /// **'Yenile · {cost}'**
  String reroll(int cost);

  /// No description provided for @rerollFree.
  ///
  /// In tr, this message translates to:
  /// **'Yenile · bedava'**
  String get rerollFree;

  /// No description provided for @leaveShop.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki tur'**
  String get leaveShop;

  /// No description provided for @buy.
  ///
  /// In tr, this message translates to:
  /// **'Al'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In tr, this message translates to:
  /// **'Sat · {amount}'**
  String sell(int amount);

  /// No description provided for @use.
  ///
  /// In tr, this message translates to:
  /// **'Kullan'**
  String get use;

  /// No description provided for @price.
  ///
  /// In tr, this message translates to:
  /// **'{price} Akçe'**
  String price(int price);

  /// No description provided for @soldOut.
  ///
  /// In tr, this message translates to:
  /// **'Satıldı'**
  String get soldOut;

  /// No description provided for @voucherTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kupon'**
  String get voucherTitle;

  /// No description provided for @packsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Keseler'**
  String get packsTitle;

  /// No description provided for @itemsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tezgâh'**
  String get itemsTitle;

  /// No description provided for @packKut.
  ///
  /// In tr, this message translates to:
  /// **'Kut Kesesi'**
  String get packKut;

  /// No description provided for @packDestan.
  ///
  /// In tr, this message translates to:
  /// **'Destan Kesesi'**
  String get packDestan;

  /// No description provided for @packTilsim.
  ///
  /// In tr, this message translates to:
  /// **'Tılsım Kesesi'**
  String get packTilsim;

  /// No description provided for @packTile.
  ///
  /// In tr, this message translates to:
  /// **'Taş Kesesi'**
  String get packTile;

  /// No description provided for @packDesc.
  ///
  /// In tr, this message translates to:
  /// **'{count} seçenekten birini al'**
  String packDesc(int count);

  /// No description provided for @packChoose.
  ///
  /// In tr, this message translates to:
  /// **'Birini seç'**
  String get packChoose;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Geç'**
  String get skip;

  /// No description provided for @kutsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kut\'lar'**
  String get kutsTitle;

  /// No description provided for @consumablesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eşyalar'**
  String get consumablesTitle;

  /// No description provided for @errNotEnoughMoney.
  ///
  /// In tr, this message translates to:
  /// **'Yeterli Akçe yok'**
  String get errNotEnoughMoney;

  /// No description provided for @errNoKutSlot.
  ///
  /// In tr, this message translates to:
  /// **'Kut yuvaları dolu'**
  String get errNoKutSlot;

  /// No description provided for @errNoConsumableSlot.
  ///
  /// In tr, this message translates to:
  /// **'Eşya yuvaları dolu'**
  String get errNoConsumableSlot;

  /// No description provided for @errInvalidTarget.
  ///
  /// In tr, this message translates to:
  /// **'Önce istakadan uygun sayıda taş seç'**
  String get errInvalidTarget;

  /// No description provided for @errGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bu şimdi yapılamaz'**
  String get errGeneric;

  /// No description provided for @runWonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tengri\'ye ulaştın!'**
  String get runWonTitle;

  /// No description provided for @runLostTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koşu bitti'**
  String get runLostTitle;

  /// No description provided for @statsFloor.
  ///
  /// In tr, this message translates to:
  /// **'Ulaşılan kat'**
  String get statsFloor;

  /// No description provided for @statsRounds.
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan tur'**
  String get statsRounds;

  /// No description provided for @statsHands.
  ///
  /// In tr, this message translates to:
  /// **'Oynanan el'**
  String get statsHands;

  /// No description provided for @statsBestHand.
  ///
  /// In tr, this message translates to:
  /// **'En yüksek el'**
  String get statsBestHand;

  /// No description provided for @statsTotalScore.
  ///
  /// In tr, this message translates to:
  /// **'Toplam skor'**
  String get statsTotalScore;

  /// No description provided for @statsFavoriteKut.
  ///
  /// In tr, this message translates to:
  /// **'En çok tetiklenen Kut'**
  String get statsFavoriteKut;

  /// No description provided for @statsFavoriteHand.
  ///
  /// In tr, this message translates to:
  /// **'En çok oynanan el'**
  String get statsFavoriteHand;

  /// No description provided for @statsSeed.
  ///
  /// In tr, this message translates to:
  /// **'Seed'**
  String get statsSeed;

  /// No description provided for @continueEndless.
  ///
  /// In tr, this message translates to:
  /// **'Sonsuz Gök\'e devam'**
  String get continueEndless;

  /// No description provided for @mainMenu.
  ///
  /// In tr, this message translates to:
  /// **'Ana Menü'**
  String get mainMenu;

  /// No description provided for @handWithLevel.
  ///
  /// In tr, this message translates to:
  /// **'{hand} · Sv.{level}'**
  String handWithLevel(String hand, int level);

  /// No description provided for @rarityCommon.
  ///
  /// In tr, this message translates to:
  /// **'Yaygın'**
  String get rarityCommon;

  /// No description provided for @rarityRare.
  ///
  /// In tr, this message translates to:
  /// **'Nadir'**
  String get rarityRare;

  /// No description provided for @rarityLegendary.
  ///
  /// In tr, this message translates to:
  /// **'Efsanevi'**
  String get rarityLegendary;

  /// No description provided for @destanDesc.
  ///
  /// In tr, this message translates to:
  /// **'{hand} seviyesini 1 artırır.'**
  String destanDesc(String hand);

  /// No description provided for @tilsimTargetHint.
  ///
  /// In tr, this message translates to:
  /// **'İstakadan en fazla {count} taş seç, sonra Kullan.'**
  String tilsimTargetHint(int count);

  /// No description provided for @colorRed.
  ///
  /// In tr, this message translates to:
  /// **'Kırmızı'**
  String get colorRed;

  /// No description provided for @colorYellow.
  ///
  /// In tr, this message translates to:
  /// **'Sarı'**
  String get colorYellow;

  /// No description provided for @colorBlue.
  ///
  /// In tr, this message translates to:
  /// **'Mavi'**
  String get colorBlue;

  /// No description provided for @colorBlack.
  ///
  /// In tr, this message translates to:
  /// **'Siyah'**
  String get colorBlack;

  /// No description provided for @destanGoc.
  ///
  /// In tr, this message translates to:
  /// **'Göç Destanı'**
  String get destanGoc;

  /// No description provided for @destanTureyis.
  ///
  /// In tr, this message translates to:
  /// **'Türeyiş Destanı'**
  String get destanTureyis;

  /// No description provided for @destanSatukBugra.
  ///
  /// In tr, this message translates to:
  /// **'Satuk Buğra Han Destanı'**
  String get destanSatukBugra;

  /// No description provided for @destanAlpamis.
  ///
  /// In tr, this message translates to:
  /// **'Alpamış Destanı'**
  String get destanAlpamis;

  /// No description provided for @destanKoroglu.
  ///
  /// In tr, this message translates to:
  /// **'Köroğlu Destanı'**
  String get destanKoroglu;

  /// No description provided for @destanDedeKorkut.
  ///
  /// In tr, this message translates to:
  /// **'Dede Korkut Hikâyeleri'**
  String get destanDedeKorkut;

  /// No description provided for @destanManas.
  ///
  /// In tr, this message translates to:
  /// **'Manas Destanı'**
  String get destanManas;

  /// No description provided for @destanSu.
  ///
  /// In tr, this message translates to:
  /// **'Şu Destanı'**
  String get destanSu;

  /// No description provided for @destanOguzKagan.
  ///
  /// In tr, this message translates to:
  /// **'Oğuz Kağan Destanı'**
  String get destanOguzKagan;

  /// No description provided for @destanErgenekon.
  ///
  /// In tr, this message translates to:
  /// **'Ergenekon Destanı'**
  String get destanErgenekon;

  /// No description provided for @destanErTostuk.
  ///
  /// In tr, this message translates to:
  /// **'Er Töstük Destanı'**
  String get destanErTostuk;

  /// No description provided for @destanYaratilis.
  ///
  /// In tr, this message translates to:
  /// **'Yaratılış Destanı'**
  String get destanYaratilis;

  /// No description provided for @tilsimDemirciName.
  ///
  /// In tr, this message translates to:
  /// **'Demirci Tılsımı'**
  String get tilsimDemirciName;

  /// No description provided for @tilsimDemirciDesc.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 2 taşı Demir taşa çevirir.'**
  String get tilsimDemirciDesc;

  /// No description provided for @tilsimSimyaciName.
  ///
  /// In tr, this message translates to:
  /// **'Simyacı Tılsımı'**
  String get tilsimSimyaciName;

  /// No description provided for @tilsimSimyaciDesc.
  ///
  /// In tr, this message translates to:
  /// **'1 taşı Altın taşa çevirir.'**
  String get tilsimSimyaciDesc;

  /// No description provided for @tilsimRenkName.
  ///
  /// In tr, this message translates to:
  /// **'Renk Tılsımı'**
  String get tilsimRenkName;

  /// No description provided for @tilsimRenkDesc.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 3 taşı {color} renge boyar.'**
  String tilsimRenkDesc(String color);

  /// No description provided for @tilsimAynaName.
  ///
  /// In tr, this message translates to:
  /// **'Ayna Tılsımı'**
  String get tilsimAynaName;

  /// No description provided for @tilsimAynaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Seçili taşın bir kopyasını desteye ekler.'**
  String get tilsimAynaDesc;

  /// No description provided for @tilsimYakmaName.
  ///
  /// In tr, this message translates to:
  /// **'Yakma Tılsımı'**
  String get tilsimYakmaName;

  /// No description provided for @tilsimYakmaDesc.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 2 taşı desteden kalıcı olarak siler.'**
  String get tilsimYakmaDesc;

  /// No description provided for @tilsimKamName.
  ///
  /// In tr, this message translates to:
  /// **'Kam Tılsımı'**
  String get tilsimKamName;

  /// No description provided for @tilsimKamDesc.
  ///
  /// In tr, this message translates to:
  /// **'Rastgele bir Kut yaratır (boş yuva gerekir).'**
  String get tilsimKamDesc;

  /// No description provided for @tilsimTamgaName.
  ///
  /// In tr, this message translates to:
  /// **'Tamga Tılsımı'**
  String get tilsimTamgaName;

  /// No description provided for @tilsimTamgaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Seçili taşa rastgele bir Tamga basar.'**
  String get tilsimTamgaDesc;

  /// No description provided for @tilsimYukseltmeName.
  ///
  /// In tr, this message translates to:
  /// **'Yükseltme Tılsımı'**
  String get tilsimYukseltmeName;

  /// No description provided for @tilsimYukseltmeDesc.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 2 taşın sayısını 1 artırır.'**
  String get tilsimYukseltmeDesc;

  /// No description provided for @voucherEkElName.
  ///
  /// In tr, this message translates to:
  /// **'Ek El'**
  String get voucherEkElName;

  /// No description provided for @voucherEkElDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her turda +1 El.'**
  String get voucherEkElDesc;

  /// No description provided for @voucherEkDegistirName.
  ///
  /// In tr, this message translates to:
  /// **'Ek Değiştir'**
  String get voucherEkDegistirName;

  /// No description provided for @voucherEkDegistirDesc.
  ///
  /// In tr, this message translates to:
  /// **'Her turda +1 Değiştir.'**
  String get voucherEkDegistirDesc;

  /// No description provided for @voucherGenisIstakaName.
  ///
  /// In tr, this message translates to:
  /// **'Geniş İstaka'**
  String get voucherGenisIstakaName;

  /// No description provided for @voucherGenisIstakaDesc.
  ///
  /// In tr, this message translates to:
  /// **'İstakaya +1 taş.'**
  String get voucherGenisIstakaDesc;

  /// No description provided for @voucherKutYuvasiName.
  ///
  /// In tr, this message translates to:
  /// **'Kut Yuvası'**
  String get voucherKutYuvasiName;

  /// No description provided for @voucherKutYuvasiDesc.
  ///
  /// In tr, this message translates to:
  /// **'+1 Kut yuvası.'**
  String get voucherKutYuvasiDesc;

  /// No description provided for @voucherHeybeName.
  ///
  /// In tr, this message translates to:
  /// **'Heybe'**
  String get voucherHeybeName;

  /// No description provided for @voucherHeybeDesc.
  ///
  /// In tr, this message translates to:
  /// **'+1 eşya yuvası.'**
  String get voucherHeybeDesc;

  /// No description provided for @voucherPazarlikName.
  ///
  /// In tr, this message translates to:
  /// **'Pazarlık'**
  String get voucherPazarlikName;

  /// No description provided for @voucherPazarlikDesc.
  ///
  /// In tr, this message translates to:
  /// **'Pazar\'da her şey %25 indirimli.'**
  String get voucherPazarlikDesc;

  /// No description provided for @voucherHazineName.
  ///
  /// In tr, this message translates to:
  /// **'Hazine'**
  String get voucherHazineName;

  /// No description provided for @voucherHazineDesc.
  ///
  /// In tr, this message translates to:
  /// **'Faiz sınırı +5.'**
  String get voucherHazineDesc;

  /// No description provided for @enhBone.
  ///
  /// In tr, this message translates to:
  /// **'Kemik: +30 Puan'**
  String get enhBone;

  /// No description provided for @enhIron.
  ///
  /// In tr, this message translates to:
  /// **'Demir: istakada tutulunca ×1.5 Çarpan'**
  String get enhIron;

  /// No description provided for @enhGold.
  ///
  /// In tr, this message translates to:
  /// **'Altın: tur sonunda istakadaysa +3 Akçe'**
  String get enhGold;

  /// No description provided for @enhCrystal.
  ///
  /// In tr, this message translates to:
  /// **'Kristal: ×2 Çarpan, 1/4 kırılır'**
  String get enhCrystal;

  /// No description provided for @enhSkyStone.
  ///
  /// In tr, this message translates to:
  /// **'Gök Taşı: her renk sayılır'**
  String get enhSkyStone;

  /// No description provided for @sealCrimson.
  ///
  /// In tr, this message translates to:
  /// **'Kızıl Tamga: iki kez tetiklenir'**
  String get sealCrimson;

  /// No description provided for @sealGold.
  ///
  /// In tr, this message translates to:
  /// **'Altın Tamga: sayılınca +3 Akçe'**
  String get sealGold;

  /// No description provided for @sealSky.
  ///
  /// In tr, this message translates to:
  /// **'Gök Tamga: tur sonunda Destan yaratır'**
  String get sealSky;

  /// No description provided for @sealPurple.
  ///
  /// In tr, this message translates to:
  /// **'Mor Tamga: atılınca Tılsım yaratır'**
  String get sealPurple;

  /// No description provided for @tileAdded.
  ///
  /// In tr, this message translates to:
  /// **'Desteye eklenir'**
  String get tileAdded;

  /// No description provided for @kutOdAnaName.
  ///
  /// In tr, this message translates to:
  /// **'Od Ana'**
  String get kutOdAnaName;

  /// No description provided for @kutOdAnaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Çift içeren ellerde (Çift, İki Çift, Üç Çift) +8 Çarpan.'**
  String get kutOdAnaDesc;

  /// No description provided for @kutYerSuName.
  ///
  /// In tr, this message translates to:
  /// **'Yer-Su'**
  String get kutYerSuName;

  /// No description provided for @kutYerSuDesc.
  ///
  /// In tr, this message translates to:
  /// **'İstakada tutulan her taş için +1 Çarpan.'**
  String get kutYerSuDesc;

  /// No description provided for @kutOtukenName.
  ///
  /// In tr, this message translates to:
  /// **'Ötüken'**
  String get kutOtukenName;

  /// No description provided for @kutOtukenDesc.
  ///
  /// In tr, this message translates to:
  /// **'Elindeki her 5 Akçe için +1 Çarpan.'**
  String get kutOtukenDesc;

  /// No description provided for @kutKokTengriName.
  ///
  /// In tr, this message translates to:
  /// **'Kök Tengri'**
  String get kutKokTengriName;

  /// No description provided for @kutKokTengriDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu elden sonra kalan her El hakkı için +0,5 ×Çarpan.'**
  String get kutKokTengriDesc;

  /// No description provided for @bossYalmavuzName.
  ///
  /// In tr, this message translates to:
  /// **'Yalmavuz'**
  String get bossYalmavuzName;

  /// No description provided for @bossYalmavuzDesc.
  ///
  /// In tr, this message translates to:
  /// **'11, 12 ve 13 sayılı taşlar sayılmaz.'**
  String get bossYalmavuzDesc;

  /// No description provided for @bossAbasiName.
  ///
  /// In tr, this message translates to:
  /// **'Abası'**
  String get bossAbasiName;

  /// No description provided for @bossAbasiDesc.
  ///
  /// In tr, this message translates to:
  /// **'İstakaya 2 taş eksik gelir.'**
  String get bossAbasiDesc;

  /// No description provided for @bossSulmusName.
  ///
  /// In tr, this message translates to:
  /// **'Şulmus'**
  String get bossSulmusName;

  /// No description provided for @bossSulmusDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tek Taş ve Çift puan vermez.'**
  String get bossSulmusDesc;

  /// No description provided for @bossKaraKamName.
  ///
  /// In tr, this message translates to:
  /// **'Kara Kam'**
  String get bossKaraKamName;

  /// No description provided for @bossKaraKamDesc.
  ///
  /// In tr, this message translates to:
  /// **'En soldaki Kut bu turda çalışmaz.'**
  String get bossKaraKamDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingSound.
  ///
  /// In tr, this message translates to:
  /// **'Ses efektleri'**
  String get settingSound;

  /// No description provided for @settingMusic.
  ///
  /// In tr, this message translates to:
  /// **'Müzik'**
  String get settingMusic;

  /// No description provided for @settingVibration.
  ///
  /// In tr, this message translates to:
  /// **'Titreşim'**
  String get settingVibration;

  /// No description provided for @settingLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingLanguage;

  /// No description provided for @settingSpeed.
  ///
  /// In tr, this message translates to:
  /// **'Oyun hızı'**
  String get settingSpeed;

  /// No description provided for @settingSpeedDesc.
  ///
  /// In tr, this message translates to:
  /// **'Puan animasyonlarının hızı'**
  String get settingSpeedDesc;

  /// No description provided for @settingColorBlind.
  ///
  /// In tr, this message translates to:
  /// **'Renk körü modu'**
  String get settingColorBlind;

  /// No description provided for @settingColorBlindDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek kontrastlı renkler ve büyük renk sembolleri'**
  String get settingColorBlindDesc;

  /// No description provided for @languageTr.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTr;

  /// No description provided for @languageEn.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @colorBlindPreview.
  ///
  /// In tr, this message translates to:
  /// **'Örnek taşlar'**
  String get colorBlindPreview;

  /// No description provided for @collectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon'**
  String get collectionTitle;

  /// No description provided for @collectionKuts.
  ///
  /// In tr, this message translates to:
  /// **'Kut\'lar · {found}/{total}'**
  String collectionKuts(int found, int total);

  /// No description provided for @collectionBosses.
  ///
  /// In tr, this message translates to:
  /// **'Boss\'lar · {found}/{total}'**
  String collectionBosses(int found, int total);

  /// No description provided for @collectionLocked.
  ///
  /// In tr, this message translates to:
  /// **'Henüz açılmadı'**
  String get collectionLocked;

  /// No description provided for @collectionHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir koşuda sahip olduğun Kut\'lar burada açılır.'**
  String get collectionHint;

  /// No description provided for @profileRuns.
  ///
  /// In tr, this message translates to:
  /// **'Başlanan koşu'**
  String get profileRuns;

  /// No description provided for @profileWins.
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan koşu'**
  String get profileWins;

  /// No description provided for @profileBestHand.
  ///
  /// In tr, this message translates to:
  /// **'En yüksek el'**
  String get profileBestHand;

  /// No description provided for @profileHighestFloor.
  ///
  /// In tr, this message translates to:
  /// **'En yüksek kat'**
  String get profileHighestFloor;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @newRunConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni koşu başlasın mı?'**
  String get newRunConfirmTitle;

  /// No description provided for @newRunConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı koşun silinecek.'**
  String get newRunConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @confirmNewRun.
  ///
  /// In tr, this message translates to:
  /// **'Yeni koşu'**
  String get confirmNewRun;

  /// No description provided for @savedRunInfo.
  ///
  /// In tr, this message translates to:
  /// **'Kat {floor} · {money} Akçe'**
  String savedRunInfo(int floor, int money);

  /// No description provided for @menuHowToPlay.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl Oynanır'**
  String get menuHowToPlay;

  /// No description provided for @howToTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl Oynanır'**
  String get howToTitle;

  /// No description provided for @howToGoalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Amaç'**
  String get howToGoalTitle;

  /// No description provided for @howToGoalBody.
  ///
  /// In tr, this message translates to:
  /// **'Her turda istakadaki okey taşlarıyla per açıp hedef puana ulaş. 4 El hakkın var; hedefe ulaşamazsan koşu biter. Yeraltından Gök\'e 8 Kat\'ı geçersen Tengri\'ye ulaşırsın.'**
  String get howToGoalBody;

  /// No description provided for @howToTurnTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir tur nasıl geçer'**
  String get howToTurnTitle;

  /// No description provided for @howToTurnBody.
  ///
  /// In tr, this message translates to:
  /// **'• Taşlara dokunarak 1–6 taş seç; ortada el türünü ve puanını görürsün.\n• Oyna: seçili taşlar puan verir, yerlerine yeni taşlar gelir.\n• Değiştir: seçili taşları atıp yenilerini çekersin (turda 3 hak).\n• Taşları sürükleyerek diz ya da Sayı / Renk ile otomatik diz.'**
  String get howToTurnBody;

  /// No description provided for @howToOkeyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gösterge ve Okey'**
  String get howToOkeyTitle;

  /// No description provided for @howToOkeyBody.
  ///
  /// In tr, this message translates to:
  /// **'Turun başında bir Gösterge taşı açılır. Onun bir üstü (aynı renk; 13\'ten sonra 1) o turun Okey\'idir; istakada yıldızlı, altın kenarlı görünür. Okey joker\'dir: bir per içinde istediğin taşın yerine geçer ve en iyi değeri kendisi seçer. Göktürk harfli Sahte Okey ise okeyin değerini taşıyan normal bir taştır.'**
  String get howToOkeyBody;

  /// No description provided for @howToScoreTitle.
  ///
  /// In tr, this message translates to:
  /// **'Puanlama'**
  String get howToScoreTitle;

  /// No description provided for @howToScoreBody.
  ///
  /// In tr, this message translates to:
  /// **'Skor = Puan × Çarpan.\nPuan = el türünün taban puanı + per\'deki taşların sayıları (1 sayılı taş 15 sayılır). Per\'e girmeyen taşlar oynanır ama puan vermez. Kut\'lar, taş geliştirmeleri ve tamgalar Puan ve Çarpan\'ı artırır.'**
  String get howToScoreBody;

  /// No description provided for @howToHandsTitle.
  ///
  /// In tr, this message translates to:
  /// **'El türleri'**
  String get howToHandsTitle;

  /// No description provided for @howToHandsBody.
  ///
  /// In tr, this message translates to:
  /// **'Seri: aynı renk, ardışık sayılar (12-13-1 olur, 13-1-2 olmaz). Grup: aynı sayı, farklı renkler. Değerler başlangıç seviyesindedir; Destan\'lar bir el türünü güçlendirir.'**
  String get howToHandsBody;

  /// No description provided for @howToKutTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kut\'lar'**
  String get howToKutTitle;

  /// No description provided for @howToKutBody.
  ///
  /// In tr, this message translates to:
  /// **'Kut\'lar pasif mitolojik güçlerdir (en fazla 5). Her elde soldan sağa tetiklenirler; kartları sürükleyerek sıralarını değiştir. Önce +Çarpan, sonra ×Çarpan veren bir sıra genelde daha çok puan getirir. Karta dokunursan ne yaptığını görürsün.'**
  String get howToKutBody;

  /// No description provided for @howToShopTitle.
  ///
  /// In tr, this message translates to:
  /// **'Akçe, Pazar ve eşyalar'**
  String get howToShopTitle;

  /// No description provided for @howToShopBody.
  ///
  /// In tr, this message translates to:
  /// **'Turu kazanınca Akçe alırsın: tur ödülü, kalan her El için +1 ve faiz (elindeki her 5 Akçe için +1, en fazla 5). Pazar\'da Kut, Destan, Tılsım, Kese ve Kupon alırsın. Destan bir el türünün seviyesini artırır; Tılsım istakada seçtiğin taşları değiştirir (Demir, Altın, renk, kopya...). Kupon kalıcı bir geliştirmedir.'**
  String get howToShopBody;

  /// No description provided for @howToBossTitle.
  ///
  /// In tr, this message translates to:
  /// **'Katlar ve Boss\'lar'**
  String get howToBossTitle;

  /// No description provided for @howToBossBody.
  ///
  /// In tr, this message translates to:
  /// **'Her Kat\'ta üç tur vardır: Küçük Sınav, Büyük Sınav ve Boss. Küçük ve Büyük Sınav atlanabilir; atlarsan küçük bir ödül alırsın. Boss atlanamaz ve bir kısıtlama getirir (ör. Kara Kuş\'ta okey joker değildir).'**
  String get howToBossBody;

  /// No description provided for @howToTipsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İpuçları'**
  String get howToTipsTitle;

  /// No description provided for @howToTipsBody.
  ///
  /// In tr, this message translates to:
  /// **'• Seri ve grup başlangıçlarını bir arada tut, tek kalan taşları Değiştir ile at.\n• Gök Per (Grup-3 + Seri-3) ve uzun seriler çok puan verir.\n• Hedefe az El ile ulaşırsan kalan El\'ler Akçe olur.\n• Akçe biriktirmek faiz getirir; her şeyi hemen harcama.'**
  String get howToTipsBody;

  /// No description provided for @howToHelpTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl oynanır?'**
  String get howToHelpTooltip;

  /// No description provided for @menuDaily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Meydan Okuma'**
  String get menuDaily;

  /// No description provided for @dailyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Meydan Okuma'**
  String get dailyTitle;

  /// No description provided for @dailyIntro.
  ///
  /// In tr, this message translates to:
  /// **'Bugün herkes aynı taşlarla, aynı Boss\'larla ve aynı Pazar\'la oynar. Tek hakkın var; en yükseğe sen çık.'**
  String get dailyIntro;

  /// No description provided for @dailyMenuAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün meydan okuması hazır'**
  String get dailyMenuAvailable;

  /// No description provided for @dailyMenuInProgress.
  ///
  /// In tr, this message translates to:
  /// **'Devam ediyor · Kat {floor}'**
  String dailyMenuInProgress(int floor);

  /// No description provided for @dailyMenuDone.
  ///
  /// In tr, this message translates to:
  /// **'Bugün tamamlandı · Kat {floor}'**
  String dailyMenuDone(int floor);

  /// No description provided for @dailyStartingKut.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Kut\'u'**
  String get dailyStartingKut;

  /// No description provided for @dailyBonusTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün lütfu'**
  String get dailyBonusTitle;

  /// No description provided for @dailyBonusMoney.
  ///
  /// In tr, this message translates to:
  /// **'+{amount} Akçe ile başla'**
  String dailyBonusMoney(int amount);

  /// No description provided for @dailyBonusExtraHand.
  ///
  /// In tr, this message translates to:
  /// **'Her turda +1 El'**
  String get dailyBonusExtraHand;

  /// No description provided for @dailyBonusExtraDiscard.
  ///
  /// In tr, this message translates to:
  /// **'Her turda +1 Değiştir'**
  String get dailyBonusExtraDiscard;

  /// No description provided for @dailyBonusExtraHandSize.
  ///
  /// In tr, this message translates to:
  /// **'İstakaya +1 taş'**
  String get dailyBonusExtraHandSize;

  /// No description provided for @dailyBonusDiscount.
  ///
  /// In tr, this message translates to:
  /// **'Pazar\'da her şey %25 indirimli'**
  String get dailyBonusDiscount;

  /// No description provided for @dailyBonusInterest.
  ///
  /// In tr, this message translates to:
  /// **'Faiz sınırı +5'**
  String get dailyBonusInterest;

  /// No description provided for @dailyStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get dailyStart;

  /// No description provided for @dailyContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get dailyContinue;

  /// No description provided for @dailyDoneButton.
  ///
  /// In tr, this message translates to:
  /// **'Yarın yeni meydan okuma'**
  String get dailyDoneButton;

  /// No description provided for @dailyResultTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü sonucun'**
  String get dailyResultTitle;

  /// No description provided for @dailyResultLine.
  ///
  /// In tr, this message translates to:
  /// **'Kat {floor} · {score} puan'**
  String dailyResultLine(int floor, int score);

  /// No description provided for @dailyResultWon.
  ///
  /// In tr, this message translates to:
  /// **'Tengri\'ye ulaştın!'**
  String get dailyResultWon;

  /// No description provided for @dailyResultOngoing.
  ///
  /// In tr, this message translates to:
  /// **'devam ediyor'**
  String get dailyResultOngoing;

  /// No description provided for @dailyShare.
  ///
  /// In tr, this message translates to:
  /// **'Sonucu paylaş'**
  String get dailyShare;

  /// No description provided for @dailyCopied.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç panoya kopyalandı'**
  String get dailyCopied;

  /// No description provided for @dailyShareText.
  ///
  /// In tr, this message translates to:
  /// **'Tengri\'nin Taşları · Günlük {date}\nKat {floor} · {score} puan{won}\n{seed}'**
  String dailyShareText(
    String date,
    int floor,
    int score,
    String won,
    String seed,
  );

  /// No description provided for @dailyShareWon.
  ///
  /// In tr, this message translates to:
  /// **' · Tengri\'ye ulaştım ★'**
  String get dailyShareWon;

  /// No description provided for @dailyHistory.
  ///
  /// In tr, this message translates to:
  /// **'Son günler'**
  String get dailyHistory;

  /// No description provided for @dailyNoHistory.
  ///
  /// In tr, this message translates to:
  /// **'Henüz günlük sonuç yok.'**
  String get dailyNoHistory;

  /// No description provided for @dailyTag.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get dailyTag;

  /// No description provided for @leaderboardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün sıralaması'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama bu sürümde yok. Paylaşılan tarayıcı sürümünde, sayfaya erişimi olan herkesle birlikte görünür.'**
  String get leaderboardUnavailable;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bugün henüz sonuç yok. İlk sen ol!'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardError.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama şu an alınamadı.'**
  String get leaderboardError;

  /// No description provided for @leaderboardRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get leaderboardRefresh;

  /// No description provided for @leaderboardYou.
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get leaderboardYou;

  /// No description provided for @leaderboardSomeone.
  ///
  /// In tr, this message translates to:
  /// **'Bir oyuncu'**
  String get leaderboardSomeone;

  /// No description provided for @leaderboardYourRank.
  ///
  /// In tr, this message translates to:
  /// **'Bugün {rank}. sıradasın · {total} oyuncu'**
  String leaderboardYourRank(int rank, int total);

  /// No description provided for @leaderboardRow.
  ///
  /// In tr, this message translates to:
  /// **'Kat {floor} · {score}'**
  String leaderboardRow(int floor, int score);

  /// No description provided for @leaderboardOngoing.
  ///
  /// In tr, this message translates to:
  /// **'sürüyor'**
  String get leaderboardOngoing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
