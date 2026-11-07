import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/kuts.dart';
import 'package:tengri_taslari/services/audio_service.dart';
import 'package:tengri_taslari/services/haptics_service.dart';

import '../settings/settings_providers.dart';
import 'table_state.dart';

/// Phase 2 demo: a single round with a fixed target and two starter Kuts so
/// Kut triggers can be seen. Phase 3 replaces this with the run loop.
const List<String> demoKutIds = ['umay_ana', 'bozkurt'];

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

/// Owns the current [Round] and drives the scoring playback.
class TableController extends Notifier<TableState> {
  bool _skipRequested = false;

  @override
  TableState build() =>
      _createState(ref.read(initialSeedCodeProvider) ?? _randomSeedCode());

  static String _randomSeedCode() =>
      generateSeedCode(SeededRng(DateTime.now().microsecondsSinceEpoch));

  TableState _createState(String seedCode) {
    const floor = 1;
    const roundInFloor = 0;
    final round = Round(
      deckTiles: RunDeck.standard().tiles,
      target: Balance.targetFor(floor, roundInFloor),
      rng: SeededRng.fromCode(seedCode).fork('floor$floor-round$roundInFloor'),
      levels: Balance.newHandLevels(),
      config: Balance.round,
      kuts: [for (final id in demoKutIds) KutInstance(kutById(id))],
      tuning: Balance.tileEffects,
    );
    return TableState(
      round: round,
      seedCode: seedCode,
      floor: floor,
      roundInFloor: roundInFloor,
    );
  }

  AudioService get _audio => ref.read(audioServiceProvider);
  HapticsService get _haptics => ref.read(hapticsServiceProvider);

  /// Starts a new round. [seedCode] = null picks a random seed.
  void newRound({String? seedCode}) {
    _skipRequested = false;
    state = _createState(seedCode ?? _randomSeedCode());
  }

  // ---------------------------------------------------------------- rack

  /// Selects / deselects a rack tile. Returns false if the limit is reached.
  bool toggleTile(int tileId) {
    if (state.isAnimating || state.round.phase != RoundPhase.playing) {
      return false;
    }
    final selected = Set.of(state.selectedIds);
    if (!selected.remove(tileId)) {
      if (selected.length >= state.round.config.maxTilesPerAction) return false;
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
    state.round.moveTile(from, to);
    state = state.copyWith();
  }

  void sortByNumber() {
    if (state.isAnimating) return;
    state.round.sortRackByNumber();
    _audio.play(SoundId.tilePlace);
    state = state.copyWith();
  }

  void sortByColor() {
    if (state.isAnimating) return;
    state.round.sortRackByColor();
    _audio.play(SoundId.tilePlace);
    state = state.copyWith();
  }

  void reveal(int rackIndex) {
    state.round.reveal(rackIndex);
    state = state.copyWith();
  }

  HandPreview? preview() {
    final indices = state.selectedIndices;
    if (indices.isEmpty || indices.length > state.round.maxTilesPerPlay) {
      return null;
    }
    return state.round.preview(indices);
  }

  // ------------------------------------------------------------- actions

  void discard() {
    if (!state.canDiscard) return;
    state.round.discard(state.selectedIndices);
    _audio.play(SoundId.tileDraw);
    state = state.copyWith(selectedIds: const <int>{});
  }

  /// Plays the selection and replays the scoring events with delays.
  Future<void> play() async {
    if (!state.canPlay) return;
    final round = state.round;
    final indices = state.selectedIndices;
    final selected = indices.toSet();
    final rackBefore = round.rack;
    final held = [
      for (var i = 0; i < rackBefore.length; i++)
        if (!selected.contains(i)) rackBefore[i],
    ];
    final kutsBefore = round.kuts;

    final outcome = round.play(indices);
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
    for (var i = 0; i < playback.events.length; i++) {
      if (!ref.mounted) return;
      final event = playback.events[i];
      playback = playback.copyWith(step: i);
      state = state.copyWith(playback: playback);
      _soundFor(event);
      await _wait(_durationFor(event));
    }
    if (!ref.mounted) return;

    playback = playback.copyWith(
      step: playback.events.length - 1,
      finished: true,
    );
    final big = playback.handScore >= round.target * bigHitShare;
    state = state.copyWith(
      playback: playback,
      shakeCount: big ? state.shakeCount + 1 : null,
    );
    _audio.play(SoundId.handScored);
    if (big) _haptics.trigger(HapticKind.bigScore);
    await _wait(PlaybackTiming.outro);
    if (!ref.mounted) return;

    state = state.copyWith(clearPlayback: true);
    if (round.phase == RoundPhase.won) _audio.play(SoundId.roundWon);
    if (round.phase == RoundPhase.lost) _audio.play(SoundId.roundLost);
  }

  /// Fast-forwards the running playback.
  void skipPlayback() => _skipRequested = true;

  Future<void> _wait(Duration base) async {
    if (_skipRequested) return;
    final speed = ref.read(gameSpeedProvider);
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

  void _soundFor(ScoreEvent e) {
    if (e.source == ScoreSourceKind.kut) _audio.play(SoundId.kutTrigger);
    switch (e.kind) {
      case ScoreEventKind.chips:
        _audio.play(SoundId.chips);
      case ScoreEventKind.mult:
        _audio.play(SoundId.mult);
      case ScoreEventKind.xMult:
        _audio.play(SoundId.xMult);
      case ScoreEventKind.money:
        _audio.play(SoundId.money);
      default:
        break;
    }
  }
}

/// Seed code of the first round (null = random). Overridden in tests and,
/// later, by "continue run" / daily challenge.
final initialSeedCodeProvider = Provider<String?>((ref) => null);

final tableControllerProvider = NotifierProvider<TableController, TableState>(
  TableController.new,
);
