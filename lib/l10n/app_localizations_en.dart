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
  String get kutKopuzDesc => '+15 Mult if 3 or fewer tiles are played.';

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
  String get kutOguzKaganDesc => '+60 Chips and +8 Mult for Run-5 or longer.';

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
      'Iron tiles held in the rack also give +30 Chips.';

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

  @override
  String get menuSubtitle => 'Eight floors from the Underworld to the Sky';

  @override
  String get menuNewRun => 'New Run';

  @override
  String get menuContinue => 'Continue';

  @override
  String get menuCollection => 'Collection';

  @override
  String get menuSettings => 'Settings';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get worldUnderworld => 'Underworld';

  @override
  String get worldMiddle => 'Middle World';

  @override
  String get worldSky => 'Sky';

  @override
  String get endlessLabel => 'Endless Sky';

  @override
  String rewardLabel(int amount) {
    return 'Reward: $amount Akçe';
  }

  @override
  String get startRound => 'Start';

  @override
  String get skipRound => 'Skip';

  @override
  String skipReward(String reward) {
    return 'Skip reward: $reward';
  }

  @override
  String get statusDone => 'Cleared';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String tagMoney(int amount) {
    return '+$amount Akçe';
  }

  @override
  String get tagKutPack => 'Free Kut Pack';

  @override
  String get tagDestanPack => 'Free Destan Pack';

  @override
  String get tagTilsimPack => 'Free Tılsım Pack';

  @override
  String get bossTepegozName => 'Tepegöz';

  @override
  String get bossTepegozDesc => 'Only one color counts in each hand.';

  @override
  String get bossErlikHanName => 'Erlik Han';

  @override
  String get bossErlikHanDesc => 'The first hand scores nothing.';

  @override
  String get bossAlKarisiName => 'Al Karısı';

  @override
  String get bossAlKarisiDesc =>
      'A tile is stolen from the rack after each hand.';

  @override
  String get bossYelAnaName => 'Yel Ana';

  @override
  String get bossYelAnaDesc =>
      'After each hand the rack is shuffled face down.';

  @override
  String get bossSahmeranName => 'Şahmeran';

  @override
  String get bossSahmeranDesc => 'Hands with a run score half.';

  @override
  String get bossAlbastiName => 'Albastı';

  @override
  String get bossAlbastiDesc => 'No discards.';

  @override
  String get bossDemirkiyakName => 'Demirkıyak';

  @override
  String get bossDemirkiyakDesc => 'At most 4 tiles per hand.';

  @override
  String get bossKaraKusName => 'Kara Kuş';

  @override
  String get bossKaraKusDesc => 'The okey is not wild this round.';

  @override
  String get cashoutTitle => 'Round won';

  @override
  String get cashRoundReward => 'Round reward';

  @override
  String get cashHandsLeft => 'Hands left';

  @override
  String get cashInterest => 'Interest';

  @override
  String get cashGoldTiles => 'Gold tiles';

  @override
  String get cashTileMoney => 'Gold seals';

  @override
  String get cashTotal => 'Total';

  @override
  String get collect => 'Collect';

  @override
  String savedBy(String name) {
    return '$name saved you!';
  }

  @override
  String get shopTitle => 'Bazaar';

  @override
  String reroll(int cost) {
    return 'Reroll · $cost';
  }

  @override
  String get rerollFree => 'Reroll · free';

  @override
  String get leaveShop => 'Next round';

  @override
  String get buy => 'Buy';

  @override
  String sell(int amount) {
    return 'Sell · $amount';
  }

  @override
  String get use => 'Use';

  @override
  String price(int price) {
    return '$price Akçe';
  }

  @override
  String get soldOut => 'Sold';

  @override
  String get voucherTitle => 'Voucher';

  @override
  String get packsTitle => 'Packs';

  @override
  String get itemsTitle => 'Stall';

  @override
  String get packKut => 'Kut Pack';

  @override
  String get packDestan => 'Destan Pack';

  @override
  String get packTilsim => 'Tılsım Pack';

  @override
  String get packTile => 'Tile Pack';

  @override
  String packDesc(int count) {
    return 'Pick one of $count';
  }

  @override
  String get packChoose => 'Choose one';

  @override
  String get skip => 'Skip';

  @override
  String get kutsTitle => 'Kuts';

  @override
  String get consumablesTitle => 'Items';

  @override
  String get errNotEnoughMoney => 'Not enough Akçe';

  @override
  String get errNoKutSlot => 'Kut slots are full';

  @override
  String get errNoConsumableSlot => 'Item slots are full';

  @override
  String get errInvalidTarget => 'Select a valid number of rack tiles first';

  @override
  String get errGeneric => 'You can\'t do that now';

  @override
  String get runWonTitle => 'You reached Tengri!';

  @override
  String get runLostTitle => 'Run over';

  @override
  String get statsFloor => 'Floor reached';

  @override
  String get statsRounds => 'Rounds won';

  @override
  String get statsHands => 'Hands played';

  @override
  String get statsBestHand => 'Best hand';

  @override
  String get statsTotalScore => 'Total score';

  @override
  String get statsFavoriteKut => 'Most triggered Kut';

  @override
  String get statsFavoriteHand => 'Most played hand';

  @override
  String get statsSeed => 'Seed';

  @override
  String get continueEndless => 'Continue into the Endless Sky';

  @override
  String get mainMenu => 'Main Menu';

  @override
  String handWithLevel(String hand, int level) {
    return '$hand · Lv.$level';
  }

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String destanDesc(String hand) {
    return 'Levels up $hand by 1.';
  }

  @override
  String tilsimTargetHint(int count) {
    return 'Select up to $count rack tiles, then Use.';
  }

  @override
  String get colorRed => 'Red';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorBlack => 'Black';

  @override
  String get destanGoc => 'Migration Epic';

  @override
  String get destanTureyis => 'Origin Epic';

  @override
  String get destanSatukBugra => 'Epic of Satuk Bughra';

  @override
  String get destanAlpamis => 'Epic of Alpamysh';

  @override
  String get destanKoroglu => 'Epic of Köroğlu';

  @override
  String get destanDedeKorkut => 'Tales of Dede Korkut';

  @override
  String get destanManas => 'Epic of Manas';

  @override
  String get destanSu => 'Epic of Shu';

  @override
  String get destanOguzKagan => 'Epic of Oghuz Khagan';

  @override
  String get destanErgenekon => 'Epic of Ergenekon';

  @override
  String get destanErTostuk => 'Epic of Er Töstük';

  @override
  String get destanYaratilis => 'Creation Epic';

  @override
  String get tilsimDemirciName => 'Smith\'s Charm';

  @override
  String get tilsimDemirciDesc => 'Turns up to 2 tiles into Iron.';

  @override
  String get tilsimSimyaciName => 'Alchemist\'s Charm';

  @override
  String get tilsimSimyaciDesc => 'Turns 1 tile into Gold.';

  @override
  String get tilsimRenkName => 'Color Charm';

  @override
  String tilsimRenkDesc(String color) {
    return 'Paints up to 3 tiles $color.';
  }

  @override
  String get tilsimAynaName => 'Mirror Charm';

  @override
  String get tilsimAynaDesc => 'Adds a copy of the selected tile to the deck.';

  @override
  String get tilsimYakmaName => 'Burning Charm';

  @override
  String get tilsimYakmaDesc => 'Removes up to 2 tiles from the deck for good.';

  @override
  String get tilsimKamName => 'Shaman\'s Charm';

  @override
  String get tilsimKamDesc => 'Creates a random Kut (needs a free slot).';

  @override
  String get tilsimTamgaName => 'Seal Charm';

  @override
  String get tilsimTamgaDesc => 'Stamps a random seal on the selected tile.';

  @override
  String get tilsimYukseltmeName => 'Ascension Charm';

  @override
  String get tilsimYukseltmeDesc => 'Raises up to 2 tiles by 1.';

  @override
  String get voucherEkElName => 'Extra Hand';

  @override
  String get voucherEkElDesc => '+1 hand every round.';

  @override
  String get voucherEkDegistirName => 'Extra Discard';

  @override
  String get voucherEkDegistirDesc => '+1 discard every round.';

  @override
  String get voucherGenisIstakaName => 'Wide Rack';

  @override
  String get voucherGenisIstakaDesc => '+1 rack size.';

  @override
  String get voucherKutYuvasiName => 'Kut Slot';

  @override
  String get voucherKutYuvasiDesc => '+1 Kut slot.';

  @override
  String get voucherHeybeName => 'Saddlebag';

  @override
  String get voucherHeybeDesc => '+1 item slot.';

  @override
  String get voucherPazarlikName => 'Haggling';

  @override
  String get voucherPazarlikDesc => 'Everything in the Bazaar is 25% off.';

  @override
  String get voucherHazineName => 'Treasury';

  @override
  String get voucherHazineDesc => 'Interest cap +5.';

  @override
  String get enhBone => 'Bone: +30 Chips';

  @override
  String get enhIron => 'Iron: ×1.5 Mult while held';

  @override
  String get enhGold => 'Gold: +3 Akçe if held at round end';

  @override
  String get enhCrystal => 'Crystal: ×2 Mult, 1 in 4 shatters';

  @override
  String get enhSkyStone => 'Sky Stone: counts as every color';

  @override
  String get sealCrimson => 'Crimson Seal: triggers twice';

  @override
  String get sealGold => 'Gold Seal: +3 Akçe when counted';

  @override
  String get sealSky => 'Sky Seal: creates a Destan at round end';

  @override
  String get sealPurple => 'Purple Seal: creates a Tılsım when discarded';

  @override
  String get tileAdded => 'Added to your deck';

  @override
  String get kutOdAnaName => 'Od Ana';

  @override
  String get kutOdAnaDesc =>
      '+8 Mult for hands with pairs (Pair, Two Pair, Three Pairs).';

  @override
  String get kutYerSuName => 'Yer-Su';

  @override
  String get kutYerSuDesc => '+1 Mult for each tile held in the rack.';

  @override
  String get kutOtukenName => 'Ötüken';

  @override
  String get kutOtukenDesc => '+1 Mult for every 5 Akçe you hold.';

  @override
  String get kutKokTengriName => 'Kök Tengri';

  @override
  String get kutKokTengriDesc =>
      '+0.5 ×Mult for each hand left after this one.';

  @override
  String get bossYalmavuzName => 'Yalmavuz';

  @override
  String get bossYalmavuzDesc => 'Tiles numbered 11, 12 and 13 do not count.';

  @override
  String get bossAbasiName => 'Abası';

  @override
  String get bossAbasiDesc => 'The rack holds 2 fewer tiles.';

  @override
  String get bossSulmusName => 'Şulmus';

  @override
  String get bossSulmusDesc => 'High Tile and Pair score nothing.';

  @override
  String get bossKaraKamName => 'Kara Kam';

  @override
  String get bossKaraKamDesc => 'Your leftmost Kut does nothing this round.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingSound => 'Sound effects';

  @override
  String get settingMusic => 'Music';

  @override
  String get settingVibration => 'Vibration';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingSpeed => 'Game speed';

  @override
  String get settingSpeedDesc => 'Speed of scoring animations';

  @override
  String get settingColorBlind => 'Color-blind mode';

  @override
  String get settingColorBlindDesc =>
      'High-contrast colors and bigger color symbols';

  @override
  String get languageTr => 'Türkçe';

  @override
  String get languageEn => 'English';

  @override
  String get colorBlindPreview => 'Sample tiles';

  @override
  String get collectionTitle => 'Collection';

  @override
  String collectionKuts(int found, int total) {
    return 'Kuts · $found/$total';
  }

  @override
  String collectionBosses(int found, int total) {
    return 'Bosses · $found/$total';
  }

  @override
  String get collectionLocked => 'Not discovered yet';

  @override
  String get collectionHint => 'Kuts you own during a run are unlocked here.';

  @override
  String get profileRuns => 'Runs started';

  @override
  String get profileWins => 'Runs won';

  @override
  String get profileBestHand => 'Best hand';

  @override
  String get profileHighestFloor => 'Highest floor';

  @override
  String get back => 'Back';

  @override
  String get newRunConfirmTitle => 'Start a new run?';

  @override
  String get newRunConfirmBody => 'Your saved run will be deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmNewRun => 'New run';

  @override
  String savedRunInfo(int floor, int money) {
    return 'Floor $floor · $money Akçe';
  }

  @override
  String get menuHowToPlay => 'How to Play';

  @override
  String get howToTitle => 'How to Play';

  @override
  String get howToGoalTitle => 'Goal';

  @override
  String get howToGoalBody =>
      'Each round, play melds from your rack to reach the target score. You have 4 hands; miss the target and the run is over. Clear all 8 floors from the Underworld to the Sky to reach Tengri.';

  @override
  String get howToTurnTitle => 'How a round works';

  @override
  String get howToTurnBody =>
      '• Tap tiles to select 1–6; the middle shows the hand type and its score.\n• Play: the selected tiles score and new tiles are drawn.\n• Discard: throw the selected tiles away and draw new ones (3 per round).\n• Drag tiles to arrange them, or use Number / Color to sort.';

  @override
  String get howToOkeyTitle => 'Indicator and Okey';

  @override
  String get howToOkeyBody =>
      'At the start of a round an Indicator tile is shown. The tile one above it (same color; 1 after 13) is this round\'s Okey, shown with a star and a gold border. The Okey is wild: it can stand in for any tile in a meld and picks the best value itself. The Fake Okey (with the rune) is a normal tile carrying the Okey\'s value.';

  @override
  String get howToScoreTitle => 'Scoring';

  @override
  String get howToScoreBody =>
      'Score = Chips × Mult.\nChips = the hand\'s base chips + the numbers of the tiles in the meld (a 1 counts as 15). Tiles outside the meld are played but score nothing. Kuts, tile enhancements and seals raise Chips and Mult.';

  @override
  String get howToHandsTitle => 'Hand types';

  @override
  String get howToHandsBody =>
      'Run: same color, consecutive numbers (12-13-1 is fine, 13-1-2 is not). Group: same number, different colors. Values are at level 1; Destans level a hand type up.';

  @override
  String get howToKutTitle => 'Kuts';

  @override
  String get howToKutBody =>
      'Kuts are passive mythic powers (up to 5). They trigger left to right every hand; drag cards to change their order. +Mult before ×Mult usually scores more. Tap a card to see what it does.';

  @override
  String get howToShopTitle => 'Akçe, Bazaar and items';

  @override
  String get howToShopBody =>
      'Winning a round pays Akçe: the round reward, +1 per hand left and interest (+1 per 5 Akçe held, up to 5). In the Bazaar you buy Kuts, Destans, Tılsıms, Packs and Vouchers. A Destan levels a hand type up; a Tılsım changes the tiles you select in your rack (Iron, Gold, color, copy...). A Voucher is a permanent upgrade.';

  @override
  String get howToBossTitle => 'Floors and bosses';

  @override
  String get howToBossBody =>
      'Each floor has three rounds: Small Trial, Big Trial and a Boss. You may skip the Small and Big Trial for a small reward. The Boss can\'t be skipped and adds a restriction (e.g. Kara Kuş: the okey is not wild).';

  @override
  String get howToTipsTitle => 'Tips';

  @override
  String get howToTipsBody =>
      '• Keep run and group starts together; discard lonely tiles.\n• Sky Meld (Group-3 + Run-3) and long runs score a lot.\n• Reaching the target with hands left pays extra Akçe.\n• Saving Akçe earns interest; don\'t spend everything at once.';

  @override
  String get howToHelpTooltip => 'How to play?';

  @override
  String get menuDaily => 'Daily Challenge';

  @override
  String get dailyTitle => 'Daily Challenge';

  @override
  String get dailyIntro =>
      'Today everyone plays with the same tiles, bosses and Bazaar. You get one attempt; climb as high as you can.';

  @override
  String get dailyMenuAvailable => 'Today\'s challenge is ready';

  @override
  String dailyMenuInProgress(int floor) {
    return 'In progress · Floor $floor';
  }

  @override
  String dailyMenuDone(int floor) {
    return 'Done today · Floor $floor';
  }

  @override
  String get dailyStartingKut => 'Starting Kut';

  @override
  String get dailyBonusTitle => 'Today\'s blessing';

  @override
  String dailyBonusMoney(int amount) {
    return 'Start with +$amount Akçe';
  }

  @override
  String get dailyBonusExtraHand => '+1 hand every round';

  @override
  String get dailyBonusExtraDiscard => '+1 discard every round';

  @override
  String get dailyBonusExtraHandSize => '+1 rack size';

  @override
  String get dailyBonusDiscount => 'Everything in the Bazaar is 25% off';

  @override
  String get dailyBonusInterest => 'Interest cap +5';

  @override
  String get dailyStart => 'Start';

  @override
  String get dailyContinue => 'Continue';

  @override
  String get dailyDoneButton => 'New challenge tomorrow';

  @override
  String get dailyResultTitle => 'Your result today';

  @override
  String dailyResultLine(int floor, int score) {
    return 'Floor $floor · $score points';
  }

  @override
  String get dailyResultWon => 'You reached Tengri!';

  @override
  String get dailyResultOngoing => 'in progress';

  @override
  String get dailyShare => 'Share result';

  @override
  String get dailyCopied => 'Result copied to clipboard';

  @override
  String dailyShareText(
    String date,
    int floor,
    int score,
    String won,
    String seed,
  ) {
    return 'Stones of Tengri · Daily $date\nFloor $floor · $score points$won\n$seed';
  }

  @override
  String get dailyShareWon => ' · reached Tengri ★';

  @override
  String get dailyHistory => 'Recent days';

  @override
  String get dailyNoHistory => 'No daily results yet.';

  @override
  String get dailyTag => 'Daily';

  @override
  String get leaderboardTitle => 'Today\'s leaderboard';

  @override
  String get leaderboardUnavailable =>
      'No leaderboard in this version. In the shared browser version it shows everyone who can open the page.';

  @override
  String get leaderboardEmpty => 'No results yet today. Be the first!';

  @override
  String get leaderboardError => 'The leaderboard can\'t be loaded right now.';

  @override
  String get leaderboardRefresh => 'Refresh';

  @override
  String get leaderboardYou => 'You';

  @override
  String get leaderboardSomeone => 'A player';

  @override
  String leaderboardYourRank(int rank, int total) {
    return 'You are #$rank today · $total players';
  }

  @override
  String leaderboardRow(int floor, int score) {
    return 'Floor $floor · $score';
  }

  @override
  String get leaderboardOngoing => 'climbing';
}
