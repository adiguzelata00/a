/// What happened in a scoring step.
enum ScoreEventKind {
  /// Hand type determined; [ScoreEvent.amount] = base chips, mult in multAfter.
  handBase,

  /// + chips ("Puan").
  chips,

  /// + mult ("Çarpan").
  mult,

  /// × mult.
  xMult,

  /// + money ("Akçe").
  money,

  /// The source triggers again (Kızıl Tamga, Kam Davulu ...).
  retrigger,

  /// A counted tile did not score (e.g. Tepegöz color restriction).
  tileDebuffed,

  /// A crystal tile shattered and will be removed from the deck.
  tileBroken,

  /// A boss rule changed the final score (amount = factor applied).
  bossPenalty,
}

/// Who caused a scoring step.
enum ScoreSourceKind { hand, playedTile, heldTile, kut, boss }

/// One step of the scoring sequence, used by the UI to replay animations
/// ("taş zıplar, +15 çıkar, Kut kartı titrer ...").
class ScoreEvent {
  const ScoreEvent({
    required this.kind,
    required this.source,
    required this.sourceIndex,
    required this.amount,
    required this.chipsAfter,
    required this.multAfter,
  });

  final ScoreEventKind kind;
  final ScoreSourceKind source;

  /// Index in the played list / held list / Kut row (or -1).
  final int sourceIndex;
  final num amount;

  /// Running totals after this step.
  final double chipsAfter;
  final double multAfter;

  @override
  String toString() =>
      '${source.name}[$sourceIndex] ${kind.name} $amount -> ${chipsAfter.toStringAsFixed(1)} × ${multAfter.toStringAsFixed(2)}';
}
