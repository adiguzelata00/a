import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Every sound the game can play. Real assets are added later under
/// `assets/audio/<name>.ogg`; the enum name is the asset name.
enum SoundId {
  tileTap,
  tilePlace,
  tileDraw,
  chips,
  mult,
  xMult,
  kutTrigger,
  money,
  handScored,
  roundWon,
  roundLost,
}

/// Placeholder audio system. Phase 2 has no audio assets yet, so the default
/// implementation only records what would be played (useful in tests and
/// debug logs). Swap in a real implementation without touching game code.
abstract class AudioService {
  void play(SoundId id, {double pitch = 1.0});
}

class PlaceholderAudioService implements AudioService {
  PlaceholderAudioService({this.log = false});

  final bool log;
  final List<SoundId> history = [];

  @override
  void play(SoundId id, {double pitch = 1.0}) {
    history.add(id);
    if (history.length > 200) history.removeAt(0);
    if (log) debugPrint('[audio] ${id.name} pitch=$pitch');
  }
}

final audioServiceProvider = Provider<AudioService>(
  (ref) => PlaceholderAudioService(),
);
