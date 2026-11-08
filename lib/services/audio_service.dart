import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'haptics_service.dart';
import 'music_service.dart';
import 'settings_service.dart';

/// Every sound the game can play. The asset is
/// `assets/audio/<enum name in snake_case>.wav` (placeholders synthesized by
/// `tool/gen_placeholder_sounds.py`; replace with real recordings later).
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
  roundLost;

  String get assetPath {
    final snake = name.replaceAllMapped(
      RegExp('[A-Z]'),
      (m) => '_${m[0]!.toLowerCase()}',
    );
    return 'audio/$snake.wav';
  }
}

abstract class AudioService {
  /// Plays [id]; [pitch] > 1 plays it higher (and shorter).
  void play(SoundId id, {double pitch = 1.0});

  /// Sound effects on/off (settings screen in Phase 5).
  bool get enabled;
  set enabled(bool value);
}

/// Records what would be played; used in tests.
class PlaceholderAudioService implements AudioService {
  PlaceholderAudioService({this.log = false});

  final bool log;
  final List<SoundId> history = [];
  final List<double> pitches = [];

  @override
  bool enabled = true;

  @override
  void play(SoundId id, {double pitch = 1.0}) {
    if (!enabled) return;
    history.add(id);
    pitches.add(pitch);
    if (history.length > 500) {
      history.removeAt(0);
      pitches.removeAt(0);
    }
    if (log) debugPrint('[audio] ${id.name} pitch=$pitch');
  }
}

/// Plays the WAV assets with a small round-robin pool per sound so fast
/// repeats (chip count-up) overlap instead of cutting each other off.
class AssetAudioService implements AudioService {
  AssetAudioService({this.voices = 3, this.volume = 0.8});

  final int voices;
  final double volume;
  final Map<SoundId, List<AudioPlayer>> _pool = {};
  final Map<SoundId, int> _next = {};

  @override
  bool enabled = true;

  List<AudioPlayer> _players(SoundId id) => _pool.putIfAbsent(
    id,
    () => List.generate(
      voices,
      (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
    ),
  );

  @override
  void play(SoundId id, {double pitch = 1.0}) {
    if (!enabled) return;
    final players = _players(id);
    final i = _next[id] ?? 0;
    _next[id] = (i + 1) % players.length;
    unawaited(_play(players[i], id, pitch));
  }

  Future<void> _play(AudioPlayer p, SoundId id, double pitch) async {
    try {
      await p.stop();
      await p.setPlaybackRate(pitch);
      await p.play(AssetSource(id.assetPath), volume: volume);
    } catch (e) {
      // Audio must never break the game (e.g. browsers blocking autoplay).
      if (kDebugMode) debugPrint('[audio] ${id.name} failed: $e');
    }
  }

  void dispose() {
    for (final list in _pool.values) {
      for (final p in list) {
        unawaited(p.dispose());
      }
    }
    _pool.clear();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AssetAudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// Keeps the sound / music / vibration services in sync with the settings.
/// Watched once by the app root.
final audioSettingsBinding = Provider<void>((ref) {
  ref.listen(
    settingsProvider.select((s) => s.sound),
    (_, on) => ref.read(audioServiceProvider).enabled = on,
    fireImmediately: true,
  );
  ref.listen(
    settingsProvider.select((s) => s.music),
    (_, on) => ref.read(musicServiceProvider).enabled = on,
    fireImmediately: true,
  );
  ref.listen(
    settingsProvider.select((s) => s.vibration),
    (_, on) => ref.read(hapticsServiceProvider).enabled = on,
    fireImmediately: true,
  );
});
