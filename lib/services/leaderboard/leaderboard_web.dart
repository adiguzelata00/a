import 'dart:convert';
import 'dart:js_interop';

import 'package:tengri_taslari/core/core.dart';

import 'leaderboard_service.dart';

/// `window.tengriLeaderboard`, defined by the published page (it talks to
/// the claude.ai artifact's shared database). Absent anywhere else.
@JS('tengriLeaderboard')
external _Bridge? get _bridge;

extension type _Bridge(JSObject _) implements JSObject {
  external JSPromise<JSBoolean> available();
  external JSPromise<JSBoolean> submit(JSString date, JSString json);
  external JSPromise<JSAny?> top(JSString date);
}

LeaderboardService createPlatformLeaderboard() => WebLeaderboardService();

class WebLeaderboardService implements LeaderboardService {
  @override
  Future<bool> isAvailable() async {
    final b = _bridge;
    if (b == null) return false;
    try {
      return (await b.available().toDart).toDart;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> submit(String date, DailyResult result) async {
    final b = _bridge;
    if (b == null) return false;
    try {
      final ok = await b
          .submit(date.toJS, jsonEncode(result.toJson()).toJS)
          .toDart;
      return ok.toDart;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<LeaderboardEntry>?> top(String date) async {
    final b = _bridge;
    if (b == null) return null;
    try {
      final raw = await b.top(date.toJS).toDart;
      if (raw == null || !raw.isA<JSString>()) return null;
      final list = jsonDecode((raw as JSString).toDart) as List;
      // Shared data is untrusted: coerce every field.
      return [
        for (final e in list.whereType<Map>())
          LeaderboardEntry(
            name: e['name'] is String ? e['name'] as String : '',
            isMe: e['me'] == true,
            floor: (e['floor'] as num?)?.toInt() ?? 0,
            score: (e['score'] as num?)?.toInt() ?? 0,
            won: e['won'] == true,
            finished: e['finished'] == true,
          ),
      ];
    } catch (_) {
      return null;
    }
  }
}
