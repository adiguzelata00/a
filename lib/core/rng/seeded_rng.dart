/// Deterministic, platform-independent pseudo random number generator.
///
/// Algorithm: xoshiro128** (32-bit state words) seeded via splitmix32.
/// Every run starts from a single 32-bit seed; sub-systems (deck shuffle,
/// shop, boss selection ...) use [fork] so that consuming randomness in one
/// system never changes the results of another. This keeps "same seed ->
/// same run" true even when UI code calls e.g. the shop more often.
class SeededRng {
  SeededRng(int seed) : _seed = seed & _mask {
    var s = _seed;
    int next() {
      s = (s + 0x9E3779B9) & _mask;
      return _mix32(s);
    }

    _a = next();
    _b = next();
    _c = next();
    _d = next();
    // xoshiro must never have an all-zero state.
    if ((_a | _b | _c | _d) == 0) _a = 1;
  }

  /// Creates an RNG from a human readable seed code (e.g. "TENGRI42").
  factory SeededRng.fromCode(String code) => SeededRng(seedFromCode(code));

  /// Restores an RNG from [state] (see [state] getter).
  SeededRng.fromState(List<int> state)
    : assert(state.length == 5),
      _seed = state[0] & _mask {
    _a = state[1] & _mask;
    _b = state[2] & _mask;
    _c = state[3] & _mask;
    _d = state[4] & _mask;
  }

  static const int _mask = 0xFFFFFFFF;

  final int _seed;
  int _a = 0;
  int _b = 0;
  int _c = 0;
  int _d = 0;

  /// The seed this generator was created from.
  int get seed => _seed;

  /// Serializable state (seed + 4 state words).
  List<int> get state => [_seed, _a, _b, _c, _d];

  /// Returns a new independent generator derived from this generator's
  /// *seed* (not its current state) and [label].
  SeededRng fork(String label) => SeededRng(_mix32(_seed ^ fnv1a32(label)));

  /// Uniform 32-bit unsigned integer.
  int nextUint32() {
    final result = (_rotl((_b * 5) & _mask, 7) * 9) & _mask;
    final t = (_b << 9) & _mask;
    _c ^= _a;
    _d ^= _b;
    _b ^= _c;
    _a ^= _d;
    _c ^= t;
    _d = _rotl(_d, 11);
    return result;
  }

  /// Uniform integer in `[0, max)`. Unbiased (rejection sampling).
  int nextInt(int max) {
    if (max <= 0 || max > 0x100000000) {
      throw ArgumentError.value(max, 'max', 'must be in 1..2^32');
    }
    const range = 0x100000000;
    final limit = range - (range % max);
    while (true) {
      final r = nextUint32();
      if (r < limit) return r % max;
    }
  }

  /// Uniform integer in `[min, maxInclusive]`.
  int nextIntInRange(int min, int maxInclusive) =>
      min + nextInt(maxInclusive - min + 1);

  /// Uniform double in `[0, 1)`.
  double nextDouble() => nextUint32() / 0x100000000;

  /// Returns true with probability [p].
  bool chance(double p) => nextDouble() < p;

  /// In-place Fisher-Yates shuffle.
  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }

  /// Picks a uniformly random element of [list].
  T pick<T>(List<T> list) {
    if (list.isEmpty) throw StateError('Cannot pick from an empty list');
    return list[nextInt(list.length)];
  }

  static int _rotl(int x, int k) => ((x << k) | (x >> (32 - k))) & _mask;

  static int _mix32(int z) {
    var x = z & _mask;
    x = ((x ^ (x >> 16)) * 0x85EBCA6B) & _mask;
    x = ((x ^ (x >> 13)) * 0xC2B2AE35) & _mask;
    return (x ^ (x >> 16)) & _mask;
  }
}

/// 32-bit FNV-1a hash over the UTF-16 code units of [input].
int fnv1a32(String input) {
  var hash = 0x811C9DC5;
  for (final unit in input.codeUnits) {
    hash ^= unit & 0xFF;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
    hash ^= unit >> 8;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

/// Normalizes a seed code (trim + upper case) and hashes it to a 32-bit seed.
int seedFromCode(String code) => fnv1a32(code.trim().toUpperCase());

/// Alphabet for generated seed codes (no ambiguous characters like 0/O, 1/I).
const String seedCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

/// Generates a random 8-character seed code using [entropy] as source.
String generateSeedCode(SeededRng entropy, {int length = 8}) {
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write(seedCodeAlphabet[entropy.nextInt(seedCodeAlphabet.length)]);
  }
  return buffer.toString();
}
