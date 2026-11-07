import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HapticKind { select, play, bigScore }

/// Short vibrations for tile selection, playing a meld and big scores.
abstract class HapticsService {
  void trigger(HapticKind kind);
}

class SystemHapticsService implements HapticsService {
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
