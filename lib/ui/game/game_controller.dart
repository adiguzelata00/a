import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/run_setup.dart' as setup;
import 'package:tengri_taslari/services/audio_service.dart';
import 'package:tengri_taslari/services/haptics_service.dart';
import 'package:tengri_taslari/services/music_service.dart';
import 'package:tengri_taslari/services/save_service.dart';
import 'package:tengri_taslari/services/settings_service.dart';

import '../settings/settings_providers.dart';
import 'game_state.dart';
import 'profile_controller.dart';

/// A hand scoring at least this share of the target counts as a "big hit"
/// (screen shake + strong haptic).
const double bigHitShare = 0.5;

/// Base timings at 1× speed.
abstract final class PlaybackTiming {
  static const intro = Duration(milliseconds: 450);
  static const tileEvent = Duration(milliseconds: 380);
  static const kutEvent = Duration(milliseconds: 520);
  static const minorEvent = Duration(milliseconds: 220);
  static const outro = Duration(milliseconds: 900);
}

/// Owns the [RunState] and drives navigation and the scoring playback.
class GameController extends Notifier<GameState> {
  bool _skipRequested = false;

  /// Run whose end (won) was already recorded in the profile.
  RunState? _recordedWin;

  @override
  GameState build() {
    listenSelf((previous, next) {
      if (previous == null) {
        // First state: save after the widget tree finished building.
        Future.microtask(() {
          if (ref.mounted) _persist(state);
        });
      } else {
        _persist(next);
      }
    });
    final seed = ref.read(initialSeedCodeProvider);
    // A seed passed in (tests, `?seed=`) starts a run right away.
    if (seed != null) return _newRunState(seed);
    // Otherwise show the menu; saved runs (normal and daily) can resume.
    final save = ref.read(saveServiceProvider);
    final load = ref.read(runLoaderProvider);
    return GameState(
      normalRun: load(save, daily: false),
      dailyRun: load(save, daily: true),
    );
  }

  /// Autosave + profile bookkeeping after every change.
  void _persist(GameState s) {
    final save = ref.read(saveServiceProvider);
    final profile = ref.read(profileProvider.notifier);
    for (final run in [s.normalRun, s.dailyRun]) {
      if (run == null) continue;
      save.saveRun(run);
      if (run.isDaily) profile.recordDaily(run);
    }
    final run = s.run;
    if (run == null) return;
    profile.observe(run);
    if (run.phase == RunPhase.won && !identical(_recordedWin, run)) {
      _recordedWin = run;
      profile.runWon();
    }
  }

  static String randomSeedCode() =>
      generateSeedCode(SeededRng(DateTime.now().microsecondsSinceEpoch));

  GameState _newRunState(String seed) => GameState(
    normalRun: ref.read(runFactoryProvider)(seed),
    dailyRun: stateOrNull?.dailyRun,
    showMenu: false,
  );

  AudioService get _audio => ref.read(audioServiceProvider);
  HapticsService get _haptics => ref.read(hapticsServiceProvider);
  RunState get _run => state.run!;

  void _changed() => state = state.copyWith();

  /// Runs a run action; rejected actions become a visible message.
  bool _act(void Function(RunState run) action, {Round? round}) {
    try {
      action(_run);
      state = state.copyWith(round: round ?? _run.round);
      return true;
    } on RunActionException catch (e) {
      state = state.copyWith(error: e.error);
      return false;
    }
  }

  // ---------------------------------------------------------------- menu

  void newRun({String? seedCode}) {
    _skipRequested = false;
    ref.read(profileProvider.notifier).runStarted();
    ref.read(musicServiceProvider).start();
    state = _newRunState(seedCode ?? randomSeedCode());
  }

  void toMenu() => state = state.copyWith(showMenu: true);

  /// Back to the normal run (running or saved).
  void resume() {
    if (state.normalRun == null) return;
    ref.read(musicServiceProvider).start();
    state = state.copyWith(showMenu: false, dailyActive: false);
  }

  /// A finished run can not be continued.
  bool get canResume {
    final p = state.normalRun?.phase;
    return p != null && p != RunPhase.lost;
  }

  // ---------------------------------------------------------------- daily

  /// Today's challenge.
  DailyChallenge get todaysChallenge =>
      DailyChallenge.forDay(ref.read(clockProvider)(), setup.defaultCatalog);

  /// What the daily button should offer today.
  DailyStatus dailyStatus() {
    final today = todaysChallenge.date;
    final run = state.dailyRun;
    if (run != null && run.dailyDate == today && run.phase != RunPhase.lost) {
      return DailyStatus.inProgress;
    }
    final result = ref.read(profileProvider).dailyResults[today];
    if (result != null) return DailyStatus.done;
    return DailyStatus.available;
  }

  /// Starts today's challenge, or continues it. Only one attempt per day.
  void playDaily() {
    final status = dailyStatus();
    if (status == DailyStatus.done) return;
    _skipRequested = false;
    ref.read(musicServiceProvider).start();
    if (status == DailyStatus.inProgress) {
      state = state.copyWith(showMenu: false, dailyActive: true);
      return;
    }
    // A run from an earlier day that was never finished is left behind;
    // its last progress stays in the results.
    final old = state.dailyRun;
    if (old != null && old.phase != RunPhase.lost) {
      ref.read(profileProvider.notifier).recordDaily(old);
    }
    final run = ref.read(dailyFactoryProvider)(todaysChallenge);
    ref.read(profileProvider.notifier).runStarted();
    state = state.copyWith(
      run: run,
      dailyActive: true,
      showMenu: false,
      selectedIds: const <int>{},
    );
  }

  // -------------------------------------------------------- round select

  void startRound() {
    _act((r) => r.startRound());
    state = state.copyWith(selectedIds: const <int>{});
  }

  void skipRound() => _act((r) => r.skipRound());

  // ---------------------------------------------------------------- rack

  /// Selects / deselects a rack tile. Returns false if the limit is reached.
  bool toggleTile(int tileId) {
    final round = state.round;
    if (state.isAnimating ||
        round == null ||
        round.phase != RoundPhase.playing) {
      return false;
    }
    final selected = Set.of(state.selectedIds);
    if (!selected.remove(tileId)) {
      if (selected.length >= round.config.maxTilesPerAction) return false;
      selected.add(tileId);
    }
    _audio.play(SoundId.tileTap);
    _haptics.trigger(HapticKind.select);
    state = state.copyWith(selectedIds: selected);
    return true;
  }

  void clearSelection() => state = state.copyWith(selectedIds: const <int>{});

  void moveTile(int from, int to) {
    if (state.isAnimating || from == to) return;
    state.round!.moveTile(from, to);
    _changed();
  }

  void sortByNumber() {
    if (state.isAnimating) return;
    state.round!.sortRackByNumber();
    _audio.play(SoundId.tilePlace);
    _changed();
  }

  void sortByColor() {
    if (state.isAnimating) return;
    state.round!.sortRackByColor();
    _audio.play(SoundId.tilePlace);
    _changed();
  }

  void reveal(int rackIndex) {
    state.round!.reveal(rackIndex);
    _changed();
  }

  HandPreview? preview() {
    final round = state.round;
    final indices = state.selectedIndices;
    if (round == null ||
        indices.isEmpty ||
        indices.length > round.maxTilesPerPlay) {
      return null;
    }
    return round.preview(indices);
  }

  /// Reorders Kuts (trigger order).
  void moveKut(int from, int to) {
    if (state.isAnimating || from == to) return;
    _act((r) => r.moveKut(from, to));
  }

  // --------------------------------------------------------- consumables

  /// Uses consumable [index] on the selected rack tiles (if it needs any).
  void useConsumable(int index) {
    if (state.isAnimating) return;
    final indices = state.selectedIndices;
    final ok = _act((r) => r.useConsumable(index, rackIndices: indices));
    if (ok) {
      _audio.play(SoundId.kutTrigger);
      _haptics.trigger(HapticKind.play);
      state = state.copyWith(selectedIds: const <int>{});
    }
  }

  void sellConsumable(int index) {
    if (_act((r) => r.sellConsumable(index))) _audio.play(SoundId.money);
  }

  // -------------------------------------------------------------- round

  void discard() {
    if (!state.canDiscard) return;
    _act((r) => r.discard(state.selectedIndices));
    _audio.play(SoundId.tileDraw);
    state = state.copyWith(selectedIds: const <int>{});
  }

  /// Plays the selection and replays the scoring events with delays.
  Future<void> play() async {
    if (!state.canPlay) return;
    final round = state.round!;
    final indices = state.selectedIndices;
    final selected = indices.toSet();
    final rackBefore = round.rack;
    final held = [
      for (var i = 0; i < rackBefore.length; i++)
        if (!selected.contains(i)) rackBefore[i],
    ];
    final kutsBefore = round.kuts;

    final outcome = _run.play(indices);
    _haptics.trigger(HapticKind.play);
    _audio.play(SoundId.tilePlace);
    _skipRequested = false;

    var playback = Playback(
      played: outcome.hand.played,
      held: held,
      hand: outcome.hand,
      events: outcome.scoring.events,
      kuts: kutsBefore,
      handScore: outcome.scoring.score,
      scoreBefore: outcome.scoreBefore,
      scoreAfter: outcome.scoreAfter,
    );
    state = state.copyWith(selectedIds: const <int>{}, playback: playback);

    await _wait(PlaybackTiming.intro);
    var streak = 0;
    for (var i = 0; i < playback.events.length; i++) {
      if (!ref.mounted) return;
      final event = playback.events[i];
      playback = playback.copyWith(step: i);
      state = state.copyWith(playback: playback);
      if (event.kind == ScoreEventKind.chips ||
          event.kind == ScoreEventKind.mult ||
          event.kind == ScoreEventKind.xMult) {
        streak++;
      }
      _soundFor(event, streak);
      await _wait(_durationFor(event));
    }
    if (!ref.mounted) return;

    playback = playback.copyWith(
      step: playback.events.length - 1,
      finished: true,
    );
    final ratio = playback.handScore / round.target;
    final big = ratio >= bigHitShare;
    state = state.copyWith(
      playback: playback,
      shakeCount: big ? state.shakeCount + 1 : null,
      // Bigger hands shake harder (capped).
      shakeStrength: big ? 5 + 6 * ratio.clamp(0.0, 1.5) : null,
    );
    _audio.play(SoundId.handScored);
    if (big) _haptics.trigger(HapticKind.bigScore);
    await _wait(PlaybackTiming.outro);
    if (!ref.mounted) return;

    if (round.phase != RoundPhase.playing) {
      _audio.play(
        round.phase == RoundPhase.won ? SoundId.roundWon : SoundId.roundLost,
      );
      _run.finishRound();
    } else {
      _audio.play(SoundId.tileDraw);
    }
    state = state.copyWith(clearPlayback: true);
  }

  /// Fast-forwards the running playback.
  void skipPlayback() => _skipRequested = true;

  Future<void> _wait(Duration base) async {
    if (_skipRequested) return;
    final speed = ref.read(settingsProvider).gameSpeed;
    await ref.read(delayProvider)(base ~/ speed);
  }

  Duration _durationFor(ScoreEvent e) => switch (e.source) {
    ScoreSourceKind.kut => PlaybackTiming.kutEvent,
    ScoreSourceKind.playedTile || ScoreSourceKind.heldTile =>
      e.kind == ScoreEventKind.retrigger
          ? PlaybackTiming.minorEvent
          : PlaybackTiming.tileEvent,
    _ => PlaybackTiming.tileEvent,
  };

  /// Pitch rises with each consecutive scoring step ([streak]) so a long
  /// chain sounds like it is building up.
  static double pitchFor(int streak) => 1.0 + 0.05 * (streak - 1).clamp(0, 12);

  void _soundFor(ScoreEvent e, int streak) {
    if (e.source == ScoreSourceKind.kut) _audio.play(SoundId.kutTrigger);
    final pitch = pitchFor(streak);
    switch (e.kind) {
      case ScoreEventKind.chips:
        _audio.play(SoundId.chips, pitch: pitch);
      case ScoreEventKind.mult:
        _audio.play(SoundId.mult, pitch: pitch);
      case ScoreEventKind.xMult:
        _audio.play(SoundId.xMult, pitch: pitch);
      case ScoreEventKind.money:
        _audio.play(SoundId.money);
      default:
        break;
    }
  }

  // ------------------------------------------------------- cashout/shop

  void collectCashout() {
    if (_act((r) => r.collectCashout())) _audio.play(SoundId.money);
  }

  void buyItem(int index) {
    if (_act((r) => r.buyItem(index))) _audio.play(SoundId.money);
  }

  void buyPack(int index) {
    if (_act((r) => r.buyPack(index))) _audio.play(SoundId.money);
  }

  void buyVoucher() {
    if (_act((r) => r.buyVoucher())) _audio.play(SoundId.money);
  }

  void reroll() {
    if (_act((r) => r.reroll())) _audio.play(SoundId.tileDraw);
  }

  void sellKut(int index) {
    if (_act((r) => r.sellKut(index))) _audio.play(SoundId.money);
  }

  void leaveShop() => _act((r) => r.leaveShop());

  void choosePackOption(int index) {
    if (_act((r) => r.choosePackOption(index))) _audio.play(SoundId.kutTrigger);
  }

  void skipPack() => _act((r) => r.skipPack());

  void continueEndless() => _act((r) => r.continueEndless());
}

/// Seed code of the first run (null = show the main menu). Overridden in
/// tests and by `?seed=` on web/debug builds.
final initialSeedCodeProvider = Provider<String?>((ref) => null);

/// Creates a run for a seed code. Overridden in tests (e.g. easy targets).
final runFactoryProvider = Provider<RunState Function(String seed)>(
  (ref) => setup.newRun,
);

/// Loads a saved run (null = none). Overridable in tests.
final runLoaderProvider =
    Provider<RunState? Function(SaveService save, {required bool daily})>(
      (ref) =>
          (save, {required daily}) => save.loadRun(
            rules: setup.defaultRunRules,
            catalog: setup.defaultCatalog,
            daily: daily,
          ),
    );

/// Starts the run of a daily challenge. Overridable in tests.
final dailyFactoryProvider = Provider<RunState Function(DailyChallenge c)>(
  (ref) =>
      (c) => c.start(
        rules: setup.defaultRunRules,
        catalog: setup.defaultCatalog,
        bonusMoney: Balance.dailyBonusMoney,
      ),
);

/// Current time (the daily challenge's day). Overridable in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

enum DailyStatus { available, inProgress, done }

final gameControllerProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);
