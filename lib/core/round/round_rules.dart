import '../hands/hand_type.dart';

/// Rule modifiers of a round. Normal rounds use [RoundRules.normal];
/// boss rounds get their restrictions from boss definitions in `lib/data`.
class RoundRules {
  const RoundRules({
    this.singleColorPerHand = false,
    this.firstHandScoresZero = false,
    this.stealTileAfterHand = false,
    this.shuffleAndHideAfterHand = false,
    this.runScoreFactor = 1.0,
    this.noDiscards = false,
    this.maxTilesPerPlay,
    this.okeyIsWild = true,
    this.faceTilesDontCount = false,
    this.handSizeDelta = 0,
    this.firstKutDisabled = false,
    this.zeroScoreHands = const {},
  });

  static const RoundRules normal = RoundRules();

  /// Tepegöz: in every hand only one (randomly chosen) color is counted.
  final bool singleColorPerHand;

  /// Erlik Han: the first hand of the round scores nothing.
  final bool firstHandScoresZero;

  /// Al Karısı: after each hand a random rack tile is stolen.
  final bool stealTileAfterHand;

  /// Yel Ana: after each hand the rack is shuffled and turned face down.
  final bool shuffleAndHideAfterHand;

  /// Şahmeran: final score factor for hands containing a run (0.5).
  final double runScoreFactor;

  /// Albastı: no discards.
  final bool noDiscards;

  /// Demirkıyak: maximum tiles per play (null = default limit).
  final int? maxTilesPerPlay;

  /// Kara Kuş: okey is not a joker this round.
  final bool okeyIsWild;

  /// Yalmavuz: counted tiles numbered 11-13 do not score.
  final bool faceTilesDontCount;

  /// Abası: rack size change (negative = fewer tiles).
  final int handSizeDelta;

  /// Kara Kam: the leftmost Kut does nothing this round.
  final bool firstKutDisabled;

  /// Şulmus: these hand types score nothing.
  final Set<HandType> zeroScoreHands;
}
