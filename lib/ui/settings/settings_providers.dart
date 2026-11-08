import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Waits for a duration. Overridden in tests to run animations instantly.
typedef Delay = Future<void> Function(Duration duration);

final delayProvider = Provider<Delay>(
  (ref) =>
      (d) => Future<void>.delayed(d),
);
