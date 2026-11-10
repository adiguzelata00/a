import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tengri_taslari/core/core.dart';

import '../storage.dart';
import 'leaderboard_service.dart';

/// Daily leaderboard on Firebase, through its REST APIs (no native plugin,
/// so builds need no google-services files):
///
/// * Identity Toolkit: anonymous sign-in; the refresh token is kept in
///   device storage so the player keeps the same id.
/// * Firestore: one document per player per day at
///   `daily/<date>/scores/<uid>` = {name, floor, score, won, finished,
///   updatedAt}. The security rules (`firebase/firestore.rules`) let signed-in
///   players read a day and write only their own document.
class FirebaseLeaderboardService implements LeaderboardService {
  FirebaseLeaderboardService({
    required this.projectId,
    required this.apiKey,
    required this.store,
    required this.playerName,
    http.Client? client,
    DateTime Function()? clock,
  }) : _client = client ?? http.Client(),
       _clock = clock ?? DateTime.now;

  static const authKey = 'firebase_auth_v1';
  static const maxNameLength = 20;

  final String projectId;
  final String apiKey;
  final KeyValueStore store;

  /// Name shown to other players (from the settings).
  final String Function() playerName;
  final http.Client _client;
  final DateTime Function() _clock;

  String? _idToken;
  String? _uid;
  DateTime _expires = DateTime.fromMillisecondsSinceEpoch(0);

  String get _docs =>
      'https://firestore.googleapis.com/v1/projects/$projectId'
      '/databases/(default)/documents';

  @override
  Future<bool> isAvailable() async => true;

  // ---------------------------------------------------------------- auth

  Future<bool> _ensureSignedIn() async {
    if (_idToken != null && _clock().isBefore(_expires)) return true;
    final saved = _readSaved();
    final refresh = saved?['refreshToken'] as String?;
    if (refresh != null && await _refresh(refresh)) return true;
    return _signUp();
  }

  Map<String, dynamic>? _readSaved() {
    final raw = store.getString(authKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void _remember(String idToken, String refresh, String uid, int expiresIn) {
    _idToken = idToken;
    _uid = uid;
    // Renew a minute early.
    _expires = _clock().add(Duration(seconds: expiresIn - 60));
    store.setString(authKey, jsonEncode({'refreshToken': refresh, 'uid': uid}));
  }

  Future<bool> _signUp() async {
    final res = await _client.post(
      Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'returnSecureToken': true}),
    );
    if (res.statusCode != 200) return false;
    final j = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    _remember(
      j['idToken'] as String,
      j['refreshToken'] as String,
      j['localId'] as String,
      int.tryParse('${j['expiresIn']}') ?? 3600,
    );
    return true;
  }

  Future<bool> _refresh(String refreshToken) async {
    final res = await _client.post(
      Uri.parse('https://securetoken.googleapis.com/v1/token?key=$apiKey'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
    );
    if (res.statusCode != 200) return false;
    final j = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    _remember(
      j['id_token'] as String,
      j['refresh_token'] as String,
      j['user_id'] as String,
      int.tryParse('${j['expires_in']}') ?? 3600,
    );
    return true;
  }

  Map<String, String> get _authHeaders => {
    'Authorization': 'Bearer $_idToken',
    'Content-Type': 'application/json',
  };

  // -------------------------------------------------------------- scores

  /// Trims and shortens a display name.
  static String cleanName(String name) {
    final n = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    return n.length <= maxNameLength ? n : n.substring(0, maxNameLength);
  }

  @override
  Future<bool> submit(String date, DailyResult result) async {
    try {
      if (!await _ensureSignedIn()) return false;
      final res = await _client.patch(
        Uri.parse('$_docs/daily/$date/scores/$_uid'),
        headers: _authHeaders,
        body: jsonEncode({
          'fields': {
            'name': {'stringValue': cleanName(playerName())},
            'floor': {'integerValue': '${result.floor}'},
            'score': {'integerValue': '${result.score}'},
            'won': {'booleanValue': result.won},
            'finished': {'booleanValue': result.finished},
            'updatedAt': {'timestampValue': _clock().toUtc().toIso8601String()},
          },
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false; // offline: the result is resent on the next change
    }
  }

  @override
  Future<List<LeaderboardEntry>?> top(String date) async {
    try {
      if (!await _ensureSignedIn()) return null;
      final entries = <LeaderboardEntry>[];
      String? pageToken;
      do {
        final query = {'pageSize': '300', 'pageToken': ?pageToken};
        final uri = Uri.parse('$_docs/daily/$date/scores')
            .replace(queryParameters: query);
        final res = await _client.get(uri, headers: _authHeaders);
        if (res.statusCode != 200) return null;
        final j =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        for (final d in (j['documents'] as List? ?? const [])) {
          final e = _entryFrom(d as Map<String, dynamic>);
          if (e != null) entries.add(e);
        }
        pageToken = j['nextPageToken'] as String?;
      } while (pageToken != null && entries.length < 1000);
      return entries;
    } catch (_) {
      return null;
    }
  }

  /// Parses one Firestore document; shared data is untrusted, so every
  /// field is coerced.
  LeaderboardEntry? _entryFrom(Map<String, dynamic> doc) {
    final name = doc['name'];
    final f = doc['fields'];
    if (name is! String || f is! Map) return null;
    int intField(String k) =>
        int.tryParse('${(f[k] as Map?)?['integerValue'] ?? 0}') ?? 0;
    bool boolField(String k) => (f[k] as Map?)?['booleanValue'] == true;
    final display = (f['name'] as Map?)?['stringValue'];
    return LeaderboardEntry(
      name: display is String ? cleanName(display) : '',
      isMe: name.split('/').last == _uid,
      floor: intField('floor'),
      score: intField('score'),
      won: boolField('won'),
      finished: boolField('finished'),
    );
  }
}
