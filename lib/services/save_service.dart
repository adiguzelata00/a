import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import 'storage.dart';

/// Saves and loads the current run and the player profile as JSON.
class SaveService {
  SaveService(this._store);

  static const runKey = 'run_v1';
  static const dailyKey = 'daily_run_v1';
  static const profileKey = 'profile_v1';

  final KeyValueStore _store;
  final Map<String, String?> _lastJson = {};

  static String _key(bool daily) => daily ? dailyKey : runKey;

  bool hasSavedRun({bool daily = false}) =>
      _store.getString(_key(daily)) != null;

  /// Loads the saved normal run (or the daily run when [daily]), or null
  /// (missing or unreadable save).
  RunState? loadRun({
    required RunRules rules,
    required RunCatalog catalog,
    bool daily = false,
  }) {
    final key = _key(daily);
    final raw = _store.getString(key);
    if (raw == null) return null;
    try {
      _lastJson[key] = raw;
      return RunState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
        rules: rules,
        catalog: catalog,
      );
    } catch (e) {
      // A broken or outdated save must never block the game.
      debugPrint('[save] discarding unreadable run: $e');
      clearRun(daily: daily);
      return null;
    }
  }

  /// Saves [run] if it changed since the last save. Runs are only saved
  /// between rounds; finished (lost) runs are removed.
  /// Daily runs go to their own slot, so they never replace a normal run.
  void saveRun(RunState run) {
    if (run.phase == RunPhase.round) return;
    if (run.phase == RunPhase.lost) {
      clearRun(daily: run.isDaily);
      return;
    }
    final key = _key(run.isDaily);
    final json = jsonEncode(run.toJson());
    if (json == _lastJson[key]) return;
    _lastJson[key] = json;
    _store.setString(key, json);
  }

  void clearRun({bool daily = false}) {
    final key = _key(daily);
    if (_lastJson.containsKey(key) && _lastJson[key] == null) return;
    _lastJson[key] = null;
    _store.remove(key);
  }

  Profile loadProfile() {
    final raw = _store.getString(profileKey);
    if (raw == null) return Profile();
    try {
      return Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return Profile();
    }
  }

  void saveProfile(Profile profile) =>
      _store.setString(profileKey, jsonEncode(profile.toJson()));
}

final saveServiceProvider = Provider<SaveService>(
  (ref) => SaveService(ref.watch(storageProvider)),
);
