import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HapticKind { select, play, bigScore }

/// Short vibrations for tile selection, playing a meld and big scores.
abstract class HapticsService {
  void trigger(HapticKind kind);
  bool get enabled;
  set enabled(bool value);
}

class SystemHapticsService implements HapticsService {
  @override
  bool enabled = true;

  @override
  void trigger(HapticKind kind) {
    if (!enabled) return;
    switch (kind) {
      case HapticKind.select:
        HapticFeedback.selectionClick();
      case HapticKind.play:
        HapticFeedback.lightImpact();
      case HapticKind.bigScore:
        HapticFeedback.heavyImpact();
    }
  }
}

final hapticsServiceProvider = Provider<HapticsService>(
  (ref) => SystemHapticsService(),
);
