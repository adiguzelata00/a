import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Animation speed multiplier (1×, 2×, 4×).
class GameSpeedNotifier extends Notifier<int> {
  static const speeds = [1, 2, 4];

  @override
  int build() => 1;

  void cycle() => state = speeds[(speeds.indexOf(state) + 1) % speeds.length];
}

final gameSpeedProvider = NotifierProvider<GameSpeedNotifier, int>(
  GameSpeedNotifier.new,
);

/// Waits for a duration. Overridden in tests to run animations instantly.
typedef Delay = Future<void> Function(Duration duration);

final delayProvider = Provider<Delay>(
  (ref) =>
      (d) => Future<void>.delayed(d),
);
