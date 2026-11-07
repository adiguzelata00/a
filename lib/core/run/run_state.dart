import '../hands/hand_type.dart';
import '../rng/seeded_rng.dart';
import '../round/round.dart';
import '../round/round_rules.dart';
import '../scoring/kut.dart';
import '../scoring/score_event.dart';
import '../tiles/deck.dart';
import '../tiles/okey.dart';
import '../tiles/tile.dart';
import 'boss.dart';
import 'items.dart';
import 'run_config.dart';
import 'shop.dart';

/// Screens of the run loop.
///
/// roundSelect → round → cashout → shop → roundSelect … → won / lost.
/// packOpen can interrupt roundSelect (skip tags) and shop (bought packs).
enum RunPhase { roundSelect, round, cashout, shop, packOpen, won, lost }

enum RoundSlotStatus { upcoming, current, skipped, done }

enum CashoutKind { roundReward, handsLeft, interest, kut, goldTiles, tileMoney }

class CashoutLine {
  const CashoutLine(this.kind, this.amount, {this.kutId});
  final CashoutKind kind;
  final int amount;
  final String? kutId;
}

/// Summary of the round that just ended (for the result screen).
class RoundSummary {
  const RoundSummary({
    required this.floor,
    required this.roundInFloor,
    required this.score,
    required this.target,
    required this.lines,
    this.savedBy,
  });

  final int floor;
  final int roundInFloor;
  final int score;
  final int target;
  final List<CashoutLine> lines;

  /// Id of the Kut that prevented the loss (Zümrüdüanka).
  final String? savedBy;

  int get total => lines.fold(0, (s, l) => s + l.amount);
}

enum RunError {
  wrongPhase,
  notEnoughMoney,
  noKutSlot,
  noConsumableSlot,
  soldOut,
  invalidTarget,
  cannotSkipBoss,
}

class RunActionException implements Exception {
  RunActionException(this.error);
  final RunError error;
  @override
  String toString() => 'RunActionException(${error.name})';
}

/// Statistics shown at the end of a run.
class RunStats {
  int handsPlayed = 0;
  int discardsUsed = 0;
  int bestHand = 0;
  HandType? bestHandType;
  int totalScore = 0;
  int roundsWon = 0;
  int moneyEarned = 0;
  final Map<HandType, int> handCounts = {};
  final Map<String, int> kutTriggers = {};

  String? get mostUsedKut {
    if (kutTriggers.isEmpty) return null;
    return kutTriggers.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  HandType? get mostPlayedHand {
    if (handCounts.isEmpty) return null;
    return handCounts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}

/// The whole run: 8 floors × (small, big, boss), economy, shop, items.
///
/// Pure Dart and deterministic: every random decision uses a fork of the
/// run seed labelled by where it happens (floor, round, shop visit ...).
class RunState {
  RunState({required this.seedCode, required this.rules, required this.catalog})
    : _rng = SeededRng.fromCode(seedCode),
      deck = RunDeck.standard(),
      levels = HandLevels(rules.handStats),
      money = rules.startingMoney {
    _startFloor();
  }

  final String seedCode;
  final RunRules rules;
  final RunCatalog catalog;
  final SeededRng _rng;

  final RunDeck deck;
  final HandLevels levels;
  int money;
  List<KutInstance> _kuts = [];
  final List<ConsumableInstance> consumables = [];
  final Set<VoucherEffect> vouchers = {};
  final RunStats stats = RunStats();

  int floor = 1;
  int roundInFloor = 0;
  bool endless = false;
  RunPhase phase = RunPhase.roundSelect;

  /// Boss of the current floor.
  late BossDefinition boss;

  /// Skip rewards of the small and big trial of this floor.
  List<SkipTag> floorTags = const [];
  List<RoundSlotStatus> slots = const [];

  /// Voucher offered on this floor (null once bought / none left).
  VoucherDefinition? floorVoucher;

  Round? round;
  RoundSummary? lastSummary;
  Shop? shop;
  PackOpening? pack;
  RunPhase _packReturn = RunPhase.shop;

  final Set<String> _usedBosses = {};
  int _counter = 0;

  // ------------------------------------------------------------ derived

  List<KutInstance> get kuts => List.unmodifiable(round?.kuts ?? _kuts);
  int get kutSlots =>
      rules.kutSlots + (vouchers.contains(VoucherEffect.extraKutSlot) ? 1 : 0);
  int get consumableSlots =>
      rules.consumableSlots +
      (vouchers.contains(VoucherEffect.extraConsumableSlot) ? 1 : 0);
  bool get hasKutSlot => kuts.length < kutSlots;
  bool get hasConsumableSlot => consumables.length < consumableSlots;
  int get interestCap =>
      rules.interestCap +
      (vouchers.contains(VoucherEffect.interestCap)
          ? rules.interestCapPerVoucher
          : 0);

  bool get isBossRound => roundInFloor == 2;
  int get currentTarget => rules.targetFor(floor, roundInFloor);
  int targetOf(int slot) => rules.targetFor(floor, slot);

  /// World of the current floor: 0 Yeraltı (1-2), 1 Yeryüzü (3-5), 2 Gökyüzü.
  int get world => floor <= 2 ? 0 : (floor <= 5 ? 1 : 2);

  RoundConfig get roundConfig => RoundConfig(
    handSize:
        rules.round.handSize +
        (vouchers.contains(VoucherEffect.extraHandSize) ? 1 : 0),
    hands:
        rules.round.hands +
        (vouchers.contains(VoucherEffect.extraHand) ? 1 : 0),
    discards:
        rules.round.discards +
        (vouchers.contains(VoucherEffect.extraDiscard) ? 1 : 0),
    maxTilesPerAction: rules.round.maxTilesPerAction,
  );

  /// Price after the discount voucher.
  int priceOf(int base) {
    if (!vouchers.contains(VoucherEffect.discount)) return base;
    final p = (base * rules.discountFactor).floor();
    return p < 1 ? 1 : p;
  }

  int get rerollCost {
    final s = shop;
    if (s == null) return rules.rerollBaseCost;
    final free =
        !s.freeRerollUsed && kuts.any((k) => k.behavior.firstRerollFree);
    if (free) return 0;
    return rules.rerollBaseCost + s.rerolls * rules.rerollCostStep;
  }

  SeededRng _fork(String label) => _rng.fork(label);
  SeededRng _nextRng(String label) => _rng.fork('$label-${_counter++}');

  void _require(RunPhase p) {
    if (phase != p) throw RunActionException(RunError.wrongPhase);
  }

  // -------------------------------------------------------------- floors

  void _startFloor() {
    final bossRng = _fork('boss-f$floor');
    var pool = [
      for (final b in catalog.bosses)
        if (b.minFloor <= floor && !_usedBosses.contains(b.id)) b,
    ];
    if (pool.isEmpty) {
      _usedBosses.clear();
      pool = [
        for (final b in catalog.bosses)
          if (b.minFloor <= floor) b,
      ];
    }
    boss = bossRng.pick(pool);
    _usedBosses.add(boss.id);

    final tagRng = _fork('tags-f$floor');
    floorTags = [tagRng.pick(SkipTag.values), tagRng.pick(SkipTag.values)];
    slots = [
      RoundSlotStatus.current,
      RoundSlotStatus.upcoming,
      RoundSlotStatus.upcoming,
    ];

    final available = [
      for (final v in catalog.vouchers)
        if (!vouchers.contains(v.effect)) v,
    ];
    floorVoucher = available.isEmpty
        ? null
        : _fork('voucher-f$floor').pick(available);
  }

  void _advanceSlot() {
    if (roundInFloor < 2) {
      roundInFloor++;
      slots = [...slots]..[roundInFloor] = RoundSlotStatus.current;
    } else {
      floor++;
      roundInFloor = 0;
      _startFloor();
    }
  }

  // --------------------------------------------------------- round select

  /// Starts the current round (small, big or boss).
  void startRound() {
    _require(RunPhase.roundSelect);
    round = Round(
      deckTiles: deck.tiles,
      target: currentTarget,
      rng: _fork('round-f$floor-r$roundInFloor'),
      levels: levels,
      config: roundConfig,
      rules: isBossRound ? boss.rules : RoundRules.normal,
      kuts: _kuts,
      isBossRound: isBossRound,
      tuning: rules.tileEffects,
    );
    phase = RunPhase.round;
  }

  /// Skips the current small/big trial and takes its tag.
  void skipRound() {
    _require(RunPhase.roundSelect);
    if (isBossRound) throw RunActionException(RunError.cannotSkipBoss);
    final tag = floorTags[roundInFloor];
    slots = [...slots]..[roundInFloor] = RoundSlotStatus.skipped;
    _advanceSlot();
    switch (tag) {
      case SkipTag.money:
        money += rules.skipMoney;
        stats.moneyEarned += rules.skipMoney;
      case SkipTag.kutPack:
        _openPack(PackKind.kut, returnTo: RunPhase.roundSelect);
      case SkipTag.destanPack:
        _openPack(PackKind.destan, returnTo: RunPhase.roundSelect);
      case SkipTag.tilsimPack:
        _openPack(PackKind.tilsim, returnTo: RunPhase.roundSelect);
    }
  }

  // --------------------------------------------------------------- round

  Round get _round {
    final r = round;
    if (phase != RunPhase.round || r == null) {
      throw RunActionException(RunError.wrongPhase);
    }
    return r;
  }

  /// Plays a hand and records statistics.
  PlayOutcome play(List<int> rackIndices) {
    final r = _round;
    final kutsBefore = r.kuts;
    final out = r.play(rackIndices);
    final score = out.scoring.score;
    stats
      ..handsPlayed += 1
      ..totalScore += score;
    stats.handCounts.update(out.hand.type, (v) => v + 1, ifAbsent: () => 1);
    if (score > stats.bestHand) {
      stats
        ..bestHand = score
        ..bestHandType = out.hand.type;
    }
    for (final e in out.scoring.events) {
      if (e.source == ScoreSourceKind.kut &&
          e.sourceIndex < kutsBefore.length) {
        stats.kutTriggers.update(
          kutsBefore[e.sourceIndex].id,
          (v) => v + 1,
          ifAbsent: () => 1,
        );
      }
    }
    return out;
  }

  /// Discards tiles. Mor Tamga tiles create a Tılsım (if there is room).
  DiscardOutcome discard(List<int> rackIndices) {
    final out = _round.discard(rackIndices);
    stats.discardsUsed++;
    for (final _ in out.purpleSealed) {
      if (!hasConsumableSlot) break;
      consumables.add(_randomTilsim(_nextRng('purple')));
    }
    return out;
  }

  /// Ends the current round after its phase became won or lost.
  void finishRound() {
    final r = _round;
    if (r.phase == RoundPhase.playing) {
      throw RunActionException(RunError.wrongPhase);
    }
    String? savedBy;
    if (r.phase == RoundPhase.lost) {
      final saver = r.kuts
          .where((k) => k.behavior.preventsLoss(k, r.score, r.target))
          .firstOrNull;
      if (saver == null) {
        _kuts = List.of(r.kuts);
        _removeDestroyed(r);
        round = null;
        lastSummary = RoundSummary(
          floor: floor,
          roundInFloor: roundInFloor,
          score: r.score,
          target: r.target,
          lines: const [],
        );
        phase = RunPhase.lost;
        return;
      }
      savedBy = saver.id;
      r.removeKutInstance(saver);
    }

    final info = RoundEndInfo(
      handsLeft: r.handsLeft,
      discardsLeft: r.discardsLeft,
      isBossRound: r.isBossRound,
    );
    final lines = <CashoutLine>[
      CashoutLine(CashoutKind.roundReward, rules.roundRewards[roundInFloor]),
      if (r.handsLeft > 0)
        CashoutLine(
          CashoutKind.handsLeft,
          r.handsLeft * rules.moneyPerHandLeft,
        ),
    ];
    for (final k in r.kuts) {
      final m = k.behavior.roundEndMoney(k, info);
      if (m > 0) lines.add(CashoutLine(CashoutKind.kut, m, kutId: k.id));
    }
    final goldTiles = r.rack
        .where((t) => t.enhancement == Enhancement.gold)
        .length;
    if (goldTiles > 0) {
      lines.add(
        CashoutLine(
          CashoutKind.goldTiles,
          goldTiles * rules.tileEffects.goldTileRoundEndMoney,
        ),
      );
    }
    if (r.moneyEarned > 0) {
      lines.add(CashoutLine(CashoutKind.tileMoney, r.moneyEarned));
    }
    final interest = (money ~/ rules.interestPer).clamp(0, interestCap);
    if (interest > 0) lines.add(CashoutLine(CashoutKind.interest, interest));

    // Gök Tamga: held tiles create the Destan of the last played hand.
    final last = r.lastHandType;
    if (last != null) {
      for (final t in r.rack) {
        if (t.seal == Seal.sky && hasConsumableSlot) {
          consumables.add(ConsumableInstance(catalog.destanFor(last)));
        }
      }
    }

    _kuts = List.of(r.kuts);
    for (final k in _kuts) {
      k.behavior.onRoundEnd(k);
    }
    _removeDestroyed(r);
    stats.roundsWon++;
    slots = [...slots]..[roundInFloor] = RoundSlotStatus.done;
    lastSummary = RoundSummary(
      floor: floor,
      roundInFloor: roundInFloor,
      score: r.score,
      target: r.target,
      lines: lines,
      savedBy: savedBy,
    );
    round = null;
    phase = RunPhase.cashout;
  }

  void _removeDestroyed(Round r) {
    for (final t in r.destroyedTiles) {
      deck.remove(t.id);
    }
  }

  /// Takes the cashout money and moves on (shop, or run won).
  void collectCashout() {
    _require(RunPhase.cashout);
    final total = lastSummary!.total;
    money += total;
    stats.moneyEarned += total;
    final wasFinalBoss = isBossRound && floor == rules.floorCount && !endless;
    if (wasFinalBoss) {
      phase = RunPhase.won;
      return;
    }
    _advanceSlot();
    _openShop();
  }

  /// After winning: keep playing in "Sonsuz Gök" (endless) mode.
  void continueEndless() {
    _require(RunPhase.won);
    endless = true;
    _advanceSlot();
    _openShop();
  }

  // ---------------------------------------------------------------- shop

  void _openShop() {
    final rng = _fork('shop-f$floor-r$roundInFloor');
    shop = Shop(
      items: _shopItems(rng),
      packs: [
        for (var i = 0; i < rules.shopPackSlots; i++)
          PackOffer(rng.pick(PackKind.values), priceOf(rules.packPrice)),
      ],
    );
    phase = RunPhase.shop;
  }

  List<ShopOffer?> _shopItems(SeededRng rng) {
    final items = <ShopOffer?>[];
    final taken = <String>{};
    for (var i = 0; i < rules.shopItemSlots; i++) {
      final kind = _weighted(rng, rules.itemWeights);
      if (kind == 'kut') {
        final k = _randomKut(rng, exclude: taken);
        if (k != null) {
          taken.add(k.id);
          items.add(KutOffer(k, priceOf(k.price)));
          continue;
        }
      }
      final item = kind == 'destan'
          ? ConsumableInstance(rng.pick(catalog.destans))
          : _randomTilsim(rng);
      items.add(ConsumableOffer(item, priceOf(item.definition.price)));
    }
    return items;
  }

  void _pay(int price) {
    if (money < price) throw RunActionException(RunError.notEnoughMoney);
    money -= price;
  }

  /// Buys a Kut or consumable from the item slots.
  void buyItem(int index) {
    _require(RunPhase.shop);
    final offer = shop!.items[index];
    if (offer == null) throw RunActionException(RunError.soldOut);
    switch (offer) {
      case KutOffer(:final kut):
        if (!hasKutSlot) throw RunActionException(RunError.noKutSlot);
        _pay(offer.price);
        _kuts.add(KutInstance(kut));
      case ConsumableOffer(:final item):
        if (!hasConsumableSlot) {
          throw RunActionException(RunError.noConsumableSlot);
        }
        _pay(offer.price);
        consumables.add(item);
      default:
        throw RunActionException(RunError.soldOut);
    }
    shop!.items[index] = null;
  }

  /// Buys and opens a pack.
  void buyPack(int index) {
    _require(RunPhase.shop);
    final offer = shop!.packs[index];
    if (offer == null) throw RunActionException(RunError.soldOut);
    _pay(offer.price);
    shop!.packs[index] = null;
    _openPack(offer.kind, returnTo: RunPhase.shop);
  }

  void buyVoucher() {
    _require(RunPhase.shop);
    final v = floorVoucher;
    if (v == null) throw RunActionException(RunError.soldOut);
    _pay(priceOf(v.price));
    vouchers.add(v.effect);
    floorVoucher = null;
  }

  void reroll() {
    _require(RunPhase.shop);
    final s = shop!;
    final cost = rerollCost;
    _pay(cost);
    if (cost == 0) {
      s.freeRerollUsed = true;
    } else {
      s.rerolls++;
    }
    final rng = _fork(
      'reroll-f$floor-r$roundInFloor-${s.rerolls}-${s.freeRerollUsed}',
    );
    s.items
      ..clear()
      ..addAll(_shopItems(rng));
  }

  void leaveShop() {
    _require(RunPhase.shop);
    shop = null;
    phase = RunPhase.roundSelect;
  }

  /// Sells a Kut (not while a round is being played).
  void sellKut(int index) {
    if (phase == RunPhase.round) throw RunActionException(RunError.wrongPhase);
    final k = _kuts.removeAt(index);
    money += k.definition.sellValue;
  }

  void sellConsumable(int index) {
    final c = consumables.removeAt(index);
    money += c.definition.sellValue;
  }

  /// Adds a Kut if there is a free slot (rewards, debug, tests).
  void addKut(KutDefinition kut) {
    if (!hasKutSlot) throw RunActionException(RunError.noKutSlot);
    final inst = KutInstance(kut);
    round != null ? round!.addKut(inst) : _kuts.add(inst);
  }

  /// Reorders Kuts (trigger order).
  void moveKut(int from, int to) {
    final r = round;
    if (r != null) {
      r.moveKut(from, to);
    } else {
      final k = _kuts.removeAt(from);
      _kuts.insert(to, k);
    }
  }

  // --------------------------------------------------------------- packs

  void _openPack(PackKind kind, {required RunPhase returnTo}) {
    final rng = _nextRng('pack-${kind.name}');
    final choices = <PackChoice>[];
    final taken = <String>{};
    for (var i = 0; i < rules.packChoices; i++) {
      switch (kind) {
        case PackKind.kut:
          final k = _randomKut(rng, exclude: taken);
          if (k != null) {
            taken.add(k.id);
            choices.add(KutChoice(k));
          }
        case PackKind.destan:
          final pool = [
            for (final d in catalog.destans)
              if (!taken.contains(d.id)) d,
          ];
          final d = rng.pick(pool);
          taken.add(d.id);
          choices.add(ConsumableChoice(ConsumableInstance(d)));
        case PackKind.tilsim:
          final pool = [
            for (final d in catalog.tilsims)
              if (!taken.contains(d.id)) d,
          ];
          final d = rng.pick(pool);
          taken.add(d.id);
          choices.add(ConsumableChoice(_tilsimInstance(d, rng)));
        case PackKind.tile:
          choices.add(TileChoice(_randomSpecialTile(rng)));
      }
    }
    pack = PackOpening(kind: kind, choices: choices);
    _packReturn = returnTo;
    phase = RunPhase.packOpen;
  }

  /// Whether pack option [index] can be taken right now.
  bool canChoose(int index) {
    final c = pack?.choices[index];
    return switch (c) {
      KutChoice() => hasKutSlot,
      ConsumableChoice(:final item) =>
        item.definition.kind == ConsumableKind.destan || hasConsumableSlot,
      TileChoice() => true,
      null => false,
    };
  }

  void choosePackOption(int index) {
    _require(RunPhase.packOpen);
    if (!canChoose(index)) {
      throw RunActionException(
        pack!.choices[index] is KutChoice
            ? RunError.noKutSlot
            : RunError.noConsumableSlot,
      );
    }
    switch (pack!.choices[index]) {
      case KutChoice(:final kut):
        _kuts.add(KutInstance(kut));
      case ConsumableChoice(:final item):
        if (item.definition.kind == ConsumableKind.destan) {
          _applyDestan(item.definition);
        } else {
          consumables.add(item);
        }
      case TileChoice(:final tile):
        deck.addCopyOf(tile);
    }
    _closePack();
  }

  void skipPack() {
    _require(RunPhase.packOpen);
    _closePack();
  }

  void _closePack() {
    pack = null;
    phase = _packReturn;
  }

  // --------------------------------------------------------- consumables

  /// Whether consumable [index] can be used with the given rack selection.
  bool canUse(int index, {List<int> rackIndices = const []}) {
    if (index < 0 || index >= consumables.length) return false;
    final def = consumables[index].definition;
    if (phase == RunPhase.packOpen) return false;
    if (def.kind == ConsumableKind.destan) return true;
    if (def.effect == TilsimEffect.createKut) return hasKutSlot;
    final r = round;
    return phase == RunPhase.round &&
        r != null &&
        r.phase == RoundPhase.playing &&
        rackIndices.isNotEmpty &&
        rackIndices.length <= def.maxTargets;
  }

  void useConsumable(int index, {List<int> rackIndices = const []}) {
    if (!canUse(index, rackIndices: rackIndices)) {
      throw RunActionException(RunError.invalidTarget);
    }
    final item = consumables.removeAt(index);
    final def = item.definition;
    if (def.kind == ConsumableKind.destan) {
      _applyDestan(def);
      return;
    }
    final rng = _nextRng('tilsim');
    if (def.effect == TilsimEffect.createKut) {
      final k = _randomKut(rng, exclude: const {});
      if (k != null) {
        final inst = KutInstance(k);
        round != null ? round!.addKut(inst) : _kuts.add(inst);
      }
      return;
    }
    final r = round!;
    final targets = [
      for (final i in (rackIndices.toSet().toList()..sort())) r.rack[i],
    ];
    for (final tile in targets) {
      _applyTilsim(def.effect!, tile, item, r, rng);
    }
  }

  void _applyTilsim(
    TilsimEffect effect,
    Tile tile,
    ConsumableInstance item,
    Round r,
    SeededRng rng,
  ) {
    void update(Tile t) {
      deck.replace(t);
      r.updateRackTile(t);
    }

    switch (effect) {
      case TilsimEffect.iron:
        update(tile.copyWith(enhancement: Enhancement.iron));
      case TilsimEffect.gold:
        update(tile.copyWith(enhancement: Enhancement.gold));
      case TilsimEffect.paint:
        if (!tile.isFakeOkey) update(tile.copyWith(color: item.color));
      case TilsimEffect.copy:
        deck.addCopyOf(tile);
      case TilsimEffect.destroy:
        deck.remove(tile.id);
        r.destroyRackTile(tile.id);
      case TilsimEffect.seal:
        final seals = [
          for (final s in Seal.values)
            if (s != Seal.none) s,
        ];
        update(tile.copyWith(seal: rng.pick(seals)));
      case TilsimEffect.increment:
        if (!tile.isFakeOkey) {
          update(tile.copyWith(number: nextTileNumber(tile.number)));
        }
      case TilsimEffect.createKut:
        break;
    }
  }

  void _applyDestan(ConsumableDefinition def) {
    levels.levelUp(def.hand!);
    for (final k in kuts) {
      k.behavior.onDestanUsed(k);
    }
  }

  // ------------------------------------------------------------- random

  String _weighted(SeededRng rng, Map<String, int> weights) {
    final total = weights.values.fold(0, (a, b) => a + b);
    var roll = rng.nextInt(total);
    for (final e in weights.entries) {
      if (roll < e.value) return e.key;
      roll -= e.value;
    }
    return weights.keys.first;
  }

  /// Random Kut the player does not own, rarity weighted. Null if none left.
  KutDefinition? _randomKut(SeededRng rng, {required Set<String> exclude}) {
    final owned = {for (final k in kuts) k.id, ...exclude};
    final available = [
      for (final k in catalog.kuts)
        if (!owned.contains(k.id)) k,
    ];
    if (available.isEmpty) return null;
    final weights = {
      for (final r in Rarity.values)
        if (available.any((k) => k.rarity == r))
          r.name: rules.rarityWeights[r] ?? 0,
    };
    final rarityName = _weighted(rng, weights);
    final pool = [
      for (final k in available)
        if (k.rarity.name == rarityName) k,
    ];
    return rng.pick(pool);
  }

  ConsumableInstance _randomTilsim(SeededRng rng) =>
      _tilsimInstance(rng.pick(catalog.tilsims), rng);

  ConsumableInstance _tilsimInstance(ConsumableDefinition d, SeededRng rng) =>
      ConsumableInstance(
        d,
        color: d.effect == TilsimEffect.paint
            ? rng.pick(TileColor.values)
            : null,
      );

  Tile _randomSpecialTile(SeededRng rng) {
    final base = Tile(
      id: -1,
      color: rng.pick(TileColor.values),
      number: rng.nextIntInRange(minTileNumber, maxTileNumber),
    );
    if (rng.chance(0.7)) {
      final enh = [
        for (final e in Enhancement.values)
          if (e != Enhancement.none) e,
      ];
      return base.copyWith(enhancement: rng.pick(enh));
    }
    final seals = [
      for (final s in Seal.values)
        if (s != Seal.none) s,
    ];
    return base.copyWith(seal: rng.pick(seals));
  }
}
