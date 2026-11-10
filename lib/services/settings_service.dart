import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage.dart';

/// Player settings ("Ayarlar").
class Settings {
  const Settings({
    this.sound = true,
    this.music = true,
    this.vibration = true,
    this.languageCode = 'tr',
    this.gameSpeed = 1,
    this.colorBlind = false,
  });

  final bool sound;
  final bool music;
  final bool vibration;

  /// 'tr' (default) or 'en'.
  final String languageCode;

  /// Animation speed: 1, 2 or 4.
  final int gameSpeed;

  /// High-contrast tile colors and bigger color symbols.
  final bool colorBlind;

  static const speeds = [1, 2, 4];
  static const languages = ['tr', 'en'];

  Settings copyWith({
    bool? sound,
    bool? music,
    bool? vibration,
    String? languageCode,
    int? gameSpeed,
    bool? colorBlind,
  }) => Settings(
    sound: sound ?? this.sound,
    music: music ?? this.music,
    vibration: vibration ?? this.vibration,
    languageCode: languageCode ?? this.languageCode,
    gameSpeed: gameSpeed ?? this.gameSpeed,
    colorBlind: colorBlind ?? this.colorBlind,
  );

  Map<String, Object> toJson() => {
    'sound': sound,
    'music': music,
    'vibration': vibration,
    'lang': languageCode,
    'speed': gameSpeed,
    'colorBlind': colorBlind,
  };

  factory Settings.fromJson(Map<String, dynamic> j) {
    const d = Settings();
    final lang = j['lang'] as String?;
    final speed = j['speed'] as int?;
    return Settings(
      sound: j['sound'] as bool? ?? d.sound,
      music: j['music'] as bool? ?? d.music,
      vibration: j['vibration'] as bool? ?? d.vibration,
      languageCode: languages.contains(lang) ? lang! : d.languageCode,
      gameSpeed: speeds.contains(speed) ? speed! : d.gameSpeed,
      colorBlind: j['colorBlind'] as bool? ?? d.colorBlind,
    );
  }
}

/// Loads settings from storage and saves every change.
class SettingsController extends Notifier<Settings> {
  static const key = 'settings_v1';

  @override
  Settings build() {
    final raw = ref.read(storageProvider).getString(key);
    if (raw == null) return const Settings();
    try {
      return Settings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const Settings();
    }
  }

  void update(Settings Function(Settings s) change) {
    state = change(state);
    ref.read(storageProvider).setString(key, jsonEncode(state.toJson()));
  }

  void cycleSpeed() => update((s) {
    final i = Settings.speeds.indexOf(s.gameSpeed);
    return s.copyWith(
      gameSpeed: Settings.speeds[(i + 1) % Settings.speeds.length],
    );
  });
}

final settingsProvider = NotifierProvider<SettingsController, Settings>(
  SettingsController.new,
);
