import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import 'storage.dart';

/// Saves and loads the current run and the player profile as JSON.
class SaveService {
  SaveService(this._store);

  static const runKey = 'run_v1';
  static const profileKey = 'profile_v1';

  final KeyValueStore _store;
  String? _lastRunJson;

  bool get hasSavedRun => _store.getString(runKey) != null;

  /// Loads the saved run, or null (missing or unreadable save).
  RunState? loadRun({required RunRules rules, required RunCatalog catalog}) {
    final raw = _store.getString(runKey);
    if (raw == null) return null;
    try {
      _lastRunJson = raw;
      return RunState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
        rules: rules,
        catalog: catalog,
      );
    } catch (e) {
      // A broken or outdated save must never block the game.
      debugPrint('[save] discarding unreadable run: $e');
      clearRun();
      return null;
    }
  }

  /// Saves [run] if it changed since the last save. Runs are only saved
  /// between rounds; finished (lost) runs are removed.
  void saveRun(RunState run) {
    if (run.phase == RunPhase.round) return;
    if (run.phase == RunPhase.lost) {
      clearRun();
      return;
    }
    final json = jsonEncode(run.toJson());
    if (json == _lastRunJson) return;
    _lastRunJson = json;
    _store.setString(runKey, json);
  }

  void clearRun() {
    _lastRunJson = null;
    _store.remove(runKey);
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
