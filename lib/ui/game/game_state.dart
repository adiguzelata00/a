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

/// Which screen the app shows.
enum GameScreen { menu, roundSelect, table, cashout, shop, pack, runEnd }

/// Immutable snapshot for the UI.
///
/// [run] and [round] are mutable core objects; [version] increments on every
/// change so that Riverpod notices updates. [round] keeps pointing at the
/// last played round after the run moved on, so table widgets that are
/// still animating out never see a missing round.
class GameState {
  const GameState({
    this.normalRun,
    this.dailyRun,
    this.dailyActive = false,
    this.round,
    this.showMenu = true,
    this.version = 0,
    this.selectedIds = const {},
    this.playback,
    this.shakeCount = 0,
    this.shakeStrength = 7,
    this.error,
    this.errorCount = 0,
  });

  /// Saved / running normal run and daily challenge run (separate slots).
  final RunState? normalRun;
  final RunState? dailyRun;

  /// Which slot is being played.
  final bool dailyActive;

  /// The run being played.
  RunState? get run => dailyActive ? dailyRun : normalRun;
  final Round? round;
  final bool showMenu;
  final int version;
  final Set<int> selectedIds;

  final Playback? playback;

  /// Incremented for every big hit; the table shakes when it changes.
  final int shakeCount;

  /// Shake amplitude in logical pixels for the latest big hit.
  final double shakeStrength;

  /// Last rejected action (shown as a message), with a counter so the same
  /// error twice is shown twice.
  final RunError? error;
  final int errorCount;

  GameScreen get screen {
    final r = run;
    if (showMenu || r == null) return GameScreen.menu;
    // Keep the table visible until the last hand finished animating.
    if (playback != null) return GameScreen.table;
    return switch (r.phase) {
      RunPhase.roundSelect => GameScreen.roundSelect,
      RunPhase.round => GameScreen.table,
      RunPhase.cashout => GameScreen.cashout,
      RunPhase.shop => GameScreen.shop,
      RunPhase.packOpen => GameScreen.pack,
      RunPhase.won || RunPhase.lost => GameScreen.runEnd,
    };
  }

  bool get isAnimating => playback != null;

  /// Kuts to display (as scored while animating).
  List<KutInstance> get kuts => playback?.kuts ?? run?.kuts ?? const [];

  /// Tiles currently shown in the rack (held tiles while scoring).
  List<Tile> get visibleRack => playback?.held ?? round?.rack ?? const [];

  /// Score shown in the HUD (old score until the playback finishes).
  int get displayedScore {
    final p = playback;
    if (p == null) return round?.score ?? 0;
    return p.finished ? p.scoreAfter : p.scoreBefore;
  }

  /// Rack indices of the selected tiles (ascending).
  List<int> get selectedIndices {
    final rack = round?.rack ?? const <Tile>[];
    return [
      for (var i = 0; i < rack.length; i++)
        if (selectedIds.contains(rack[i].id)) i,
    ];
  }

  bool get _roundActive =>
      !isAnimating &&
      run?.phase == RunPhase.round &&
      round?.phase == RoundPhase.playing;

  bool get canPlay =>
      _roundActive &&
      round!.handsLeft > 0 &&
      selectedIds.isNotEmpty &&
      selectedIds.length <= round!.maxTilesPerPlay;

  bool get canDiscard =>
      _roundActive &&
      round!.discardsLeft > 0 &&
      selectedIds.isNotEmpty &&
      selectedIds.length <= round!.config.maxTilesPerAction;

  GameState copyWith({
    RunState? run,
    RunState? dailyRun,
    bool? dailyActive,
    Round? round,
    bool? showMenu,
    Set<int>? selectedIds,
    Playback? playback,
    bool clearPlayback = false,
    int? shakeCount,
    double? shakeStrength,
    RunError? error,
  }) => GameState(
    // `run` replaces the slot that is (or becomes) active.
    normalRun: !(dailyActive ?? this.dailyActive) && run != null
        ? run
        : normalRun,
    dailyRun: (dailyActive ?? this.dailyActive) && run != null
        ? run
        : (dailyRun ?? this.dailyRun),
    dailyActive: dailyActive ?? this.dailyActive,
    round: round ?? this.round,
    showMenu: showMenu ?? this.showMenu,
    version: version + 1,
    selectedIds: selectedIds ?? this.selectedIds,
    playback: clearPlayback ? null : (playback ?? this.playback),
    shakeCount: shakeCount ?? this.shakeCount,
    shakeStrength: shakeStrength ?? this.shakeStrength,
    error: error ?? this.error,
    errorCount: error != null ? errorCount + 1 : errorCount,
  );
}
