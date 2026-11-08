import '../rng/seeded_rng.dart';
import '../scoring/kut.dart';
import 'items.dart';
import 'run_config.dart';
import 'run_state.dart';

/// The daily challenge's twist on top of the normal rules.
enum DailyBonus {
  /// Extra starting Akçe.
  money,
  extraHand,
  extraDiscard,
  extraHandSize,
  discount,
  interestCap,
}

/// "Günlük Meydan Okuma": everyone gets the same seed, starting Kut and
/// bonus on a given day.
///
/// RULE DECISION: the day follows the device's local date, so a day starts
/// at local midnight (Turkey-wide the same day).
class DailyChallenge {
  const DailyChallenge({
    required this.date,
    required this.seedCode,
    required this.kutId,
    required this.bonus,
  });

  /// Builds the challenge of [day] (time of day is ignored).
  factory DailyChallenge.forDay(DateTime day, RunCatalog catalog) {
    final date = dateKey(day);
    final seedCode = 'GUN${date.replaceAll('-', '')}';
    final rng = SeededRng.fromCode(seedCode).fork('daily');
    // Starting Kut: common or rare (legendaries would decide the day).
    final pool = [
      for (final k in catalog.kuts)
        if (k.rarity != Rarity.legendary) k,
    ];
    return DailyChallenge(
      date: date,
      seedCode: seedCode,
      kutId: rng.pick(pool).id,
      bonus: rng.pick(DailyBonus.values),
    );
  }

  /// yyyy-MM-dd of [day].
  static String dateKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  final String date;
  final String seedCode;
  final String kutId;
  final DailyBonus bonus;

  /// Starts the run of this challenge. [bonusMoney] is the Akçe given by
  /// [DailyBonus.money].
  RunState start({
    required RunRules rules,
    required RunCatalog catalog,
    required int bonusMoney,
  }) {
    final run = RunState(seedCode: seedCode, rules: rules, catalog: catalog)
      ..dailyDate = date;
    run.addKut(catalog.kut(kutId));
    switch (bonus) {
      case DailyBonus.money:
        run.money += bonusMoney;
      case DailyBonus.extraHand:
        run.vouchers.add(VoucherEffect.extraHand);
      case DailyBonus.extraDiscard:
        run.vouchers.add(VoucherEffect.extraDiscard);
      case DailyBonus.extraHandSize:
        run.vouchers.add(VoucherEffect.extraHandSize);
      case DailyBonus.discount:
        run.vouchers.add(VoucherEffect.discount);
      case DailyBonus.interestCap:
        run.vouchers.add(VoucherEffect.interestCap);
    }
    // Vouchers granted by the day are not offered in its shops again.
    final v = run.floorVoucher;
    if (v != null && run.vouchers.contains(v.effect)) run.floorVoucher = null;
    return run;
  }
}

/// Result of a daily challenge (kept in the profile).
class DailyResult {
  const DailyResult({
    required this.floor,
    required this.won,
    required this.score,
    required this.finished,
  });

  /// Highest floor reached.
  final int floor;
  final bool won;

  /// Total score of all hands.
  final int score;

  /// The run is over (lost, or abandoned).
  final bool finished;

  factory DailyResult.of(RunState run) => DailyResult(
    floor: run.floor,
    won: run.phase == RunPhase.won || run.endless,
    score: run.stats.totalScore,
    finished: run.phase == RunPhase.lost,
  );

  Map<String, Object> toJson() => {
    'floor': floor,
    'won': won,
    'score': score,
    'finished': finished,
  };

  factory DailyResult.fromJson(Map<String, dynamic> j) => DailyResult(
    floor: j['floor'] as int,
    won: j['won'] as bool,
    score: j['score'] as int,
    finished: j['finished'] as bool? ?? true,
  );
}
