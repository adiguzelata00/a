import 'package:tengri_taslari/core/core.dart';

/// Scoring animation in progress (replays [ScoringResult.events]).
class Playback {
  const Playback({
    required this.played,
    required this.held,
    required this.hand,
    required this.events,
    required this.kuts,
    required this.handScore,
    required this.scoreBefore,
    required this.scoreAfter,
    this.step = -1,
    this.finished = false,
  });

  /// Tiles that were played (left to right) and held in the rack.
  final List<Tile> played;
  final List<Tile> held;
  final HandResult hand;
  final List<ScoreEvent> events;

  /// Kuts as they were scored (events reference their indices).
  final List<KutInstance> kuts;
  final int handScore;
  final int scoreBefore;
  final int scoreAfter;

  /// Index of the last applied event (-1 = only the tiles are shown).
  final int step;

  /// All events applied, total shown.
  final bool finished;

  ScoreEvent? get current =>
      step >= 0 && step < events.length ? events[step] : null;

  double get chips => current?.chipsAfter ?? 0;
  double get mult => current?.multAfter ?? 0;

  Set<int> get countedIndices => {for (final c in hand.counted) c.playedIndex};

  Playback copyWith({int? step, bool? finished}) => Playback(
    played: played,
    held: held,
    hand: hand,
    events: events,
    kuts: kuts,
    handScore: handScore,
    scoreBefore: scoreBefore,
    scoreAfter: scoreAfter,
    step: step ?? this.step,
    finished: finished ?? this.finished,
  );
}

/// Immutable snapshot of the game table for the UI.
///
/// [round] is a mutable core object; [version] increments on every change
/// so that Riverpod notices updates.
class TableState {
  const TableState({
    required this.round,
    required this.seedCode,
    required this.floor,
    required this.roundInFloor,
    this.version = 0,
    this.selectedIds = const {},
    this.playback,
    this.shakeCount = 0,
  });

  final Round round;
  final String seedCode;
  final int floor;

  /// 0 = small, 1 = big, 2 = boss.
  final int roundInFloor;
  final int version;
  final Set<int> selectedIds;
  final Playback? playback;

  /// Incremented for every big hit; the table shakes when it changes.
  final int shakeCount;

  bool get isAnimating => playback != null;

  /// Tiles currently shown in the rack (held tiles while scoring).
  List<Tile> get visibleRack => playback?.held ?? round.rack;

  /// Score shown in the HUD (old score until the playback finishes).
  int get displayedScore {
    final p = playback;
    if (p == null) return round.score;
    return p.finished ? p.scoreAfter : p.scoreBefore;
  }

  /// Rack indices of the selected tiles (ascending).
  List<int> get selectedIndices {
    final rack = round.rack;
    return [
      for (var i = 0; i < rack.length; i++)
        if (selectedIds.contains(rack[i].id)) i,
    ];
  }

  bool get canPlay =>
      !isAnimating &&
      round.phase == RoundPhase.playing &&
      round.handsLeft > 0 &&
      selectedIds.isNotEmpty &&
      selectedIds.length <= round.maxTilesPerPlay;

  bool get canDiscard =>
      !isAnimating &&
      round.phase == RoundPhase.playing &&
      round.discardsLeft > 0 &&
      selectedIds.isNotEmpty &&
      selectedIds.length <= round.config.maxTilesPerAction;

  /// Round over and nothing is animating any more.
  bool get showResult => !isAnimating && round.phase != RoundPhase.playing;

  TableState copyWith({
    Round? round,
    String? seedCode,
    Set<int>? selectedIds,
    Playback? playback,
    bool clearPlayback = false,
    int? shakeCount,
  }) => TableState(
    round: round ?? this.round,
    seedCode: seedCode ?? this.seedCode,
    floor: floor,
    roundInFloor: roundInFloor,
    version: version + 1,
    selectedIds: selectedIds ?? this.selectedIds,
    playback: clearPlayback ? null : (playback ?? this.playback),
    shakeCount: shakeCount ?? this.shakeCount,
  );
}
