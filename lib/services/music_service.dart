import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Background music: one seamless loop (placeholder synthesized by
/// `tool/gen_placeholder_sounds.py`, asset `audio/music_steppe.wav`).
abstract class MusicService {
  /// Starts the loop if music is enabled. Call after a user gesture
  /// (browsers block audio before the first interaction).
  void start();
  void stop();
  set enabled(bool value);
}

class LoopMusicService implements MusicService {
  LoopMusicService({this.volume = 0.35});

  static const asset = 'audio/music_steppe.wav';
  final double volume;
  AudioPlayer? _player;
  bool _enabled = true;
  bool _playing = false;

  @override
  set enabled(bool value) {
    _enabled = value;
    value ? start() : stop();
  }

  @override
  void start() {
    if (!_enabled || _playing) return;
    _playing = true;
    unawaited(_play());
  }

  Future<void> _play() async {
    try {
      final p = _player ??= AudioPlayer()..setReleaseMode(ReleaseMode.loop);
      await p.play(AssetSource(asset), volume: volume);
    } catch (e) {
      _playing = false;
      if (kDebugMode) debugPrint('[music] failed: $e');
    }
  }

  @override
  void stop() {
    _playing = false;
    unawaited(_player?.stop());
  }

  void dispose() => unawaited(_player?.dispose());
}

/// Does nothing (tests).
class SilentMusicService implements MusicService {
  int starts = 0;
  bool isEnabled = true;

  @override
  void start() {
    if (isEnabled) starts++;
  }

  @override
  void stop() {}

  @override
  set enabled(bool value) => isEnabled = value;
}

final musicServiceProvider = Provider<MusicService>((ref) {
  final service = LoopMusicService();
  ref.onDispose(service.dispose);
  return service;
});
