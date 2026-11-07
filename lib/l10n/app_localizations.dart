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
  /// **'3 veya daha az taşla oynanan ellerde +20 Çarpan.'**
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
  /// **'Seri-5 ve üstü ellerde +50 Puan, +5 Çarpan.'**
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
  /// **'İstakada tutulan Demir taşlar ayrıca +20 Puan verir.'**
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
