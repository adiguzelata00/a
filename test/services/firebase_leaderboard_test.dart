import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/services/leaderboard/firebase_leaderboard.dart';
import 'package:tengri_taslari/services/storage.dart';

const result = DailyResult(floor: 5, won: false, score: 1234, finished: true);

/// Fake Identity Toolkit + Firestore, recording every request.
class FakeFirebase {
  final requests = <http.Request>[];
  final docs = <String, Map<String, dynamic>>{};
  int signUps = 0;
  int refreshes = 0;
  bool offline = false;

  late final client = MockClient((req) async {
    requests.add(req);
    if (offline) throw http.ClientException('offline');
    final u = req.url;
    if (u.path.endsWith('accounts:signUp')) {
      signUps++;
      return http.Response(
        jsonEncode({
          'idToken': 'id-$signUps',
          'refreshToken': 'refresh-me',
          'localId': 'uid-me',
          'expiresIn': '3600',
        }),
        200,
      );
    }
    if (u.host == 'securetoken.googleapis.com') {
      refreshes++;
      if (req.bodyFields['refresh_token'] != 'refresh-me') {
        return http.Response('{}', 400);
      }
      return http.Response(
        jsonEncode({
          'id_token': 'id-r$refreshes',
          'refresh_token': 'refresh-me',
          'user_id': 'uid-me',
          'expires_in': '3600',
        }),
        200,
      );
    }
    if (!(req.headers['Authorization'] ?? '').startsWith('Bearer id-')) {
      return http.Response('{}', 403);
    }
    final path = u.path.split('/documents/').last;
    if (req.method == 'PATCH') {
      docs[path] = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response('{}', 200);
    }
    if (req.method == 'GET') {
      // Raw UTF-8 bytes, as Firestore sends them.
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'documents': [
              for (final e in docs.entries)
                if (e.key.startsWith('$path/'))
                  {
                    'name': 'projects/p/databases/(default)/documents/${e.key}',
                    ...e.value,
                  },
            ],
          }),
        ),
        200,
      );
    }
    return http.Response('{}', 404);
  });
}

FirebaseLeaderboardService service(
  FakeFirebase fb,
  KeyValueStore store, {
  String name = 'Ata',
}) => FirebaseLeaderboardService(
  projectId: 'p',
  apiKey: 'k',
  store: store,
  playerName: () => name,
  client: fb.client,
);

Map<String, dynamic> scoreDoc(String name, int floor, int score) => {
  'fields': {
    'name': {'stringValue': name},
    'floor': {'integerValue': '$floor'},
    'score': {'integerValue': '$score'},
    'won': {'booleanValue': false},
    'finished': {'booleanValue': true},
  },
};

void main() {
  test('submit signs in anonymously and writes the player row', () async {
    final fb = FakeFirebase();
    final store = MemoryStore();
    final s = service(fb, store, name: '  Kağan   Han  ');
    expect(await s.submit('2026-11-10', result), isTrue);
    expect(fb.signUps, 1);
    final doc = fb.docs['daily/2026-11-10/scores/uid-me']!;
    final f = doc['fields'] as Map<String, dynamic>;
    expect(f['name'], {'stringValue': 'Kağan Han'});
    expect(f['floor'], {'integerValue': '5'});
    expect(f['score'], {'integerValue': '1234'});
    expect(f['finished'], {'booleanValue': true});
    expect(f.keys, contains('updatedAt'));
    // The refresh token is kept so the player keeps the same id.
    expect(store.getString(FirebaseLeaderboardService.authKey), isNotNull);

    // The token is reused while valid.
    await s.submit('2026-11-10', result);
    expect(fb.signUps, 1);
    expect(fb.refreshes, 0);
  });

  test('a restarted app refreshes the saved token instead of a new '
      'account', () async {
    final fb = FakeFirebase();
    final store = MemoryStore();
    await service(fb, store).submit('2026-11-10', result);
    await service(fb, store).submit('2026-11-11', result);
    expect(fb.signUps, 1);
    expect(fb.refreshes, 1);
    expect(fb.docs.keys, contains('daily/2026-11-11/scores/uid-me'));
  });

  test('a bad saved token falls back to a new account', () async {
    final fb = FakeFirebase();
    final store = MemoryStore();
    await store.setString(
      FirebaseLeaderboardService.authKey,
      jsonEncode({'refreshToken': 'revoked', 'uid': 'old'}),
    );
    expect(await service(fb, store).submit('2026-11-10', result), isTrue);
    expect(fb.refreshes, 1);
    expect(fb.signUps, 1);
  });

  test('top reads the day and marks this player', () async {
    final fb = FakeFirebase();
    final store = MemoryStore();
    final s = service(fb, store);
    await s.submit('2026-11-10', result);
    fb.docs['daily/2026-11-10/scores/other'] = scoreDoc('Kağan Börü', 7, 900);
    fb.docs['daily/2026-11-09/scores/old'] = scoreDoc('Dün', 8, 9999);
    fb.docs['daily/2026-11-10/scores/bad'] = {'fields': 'junk'};

    final rows = (await s.top('2026-11-10'))!;
    expect(rows, hasLength(2));
    final me = rows.singleWhere((e) => e.isMe);
    expect((me.name, me.floor, me.score), ('Ata', 5, 1234));
    final other = rows.singleWhere((e) => !e.isMe);
    expect((other.name, other.floor, other.score), ('Kağan Börü', 7, 900));
  });

  test('offline: submit and top fail quietly', () async {
    final fb = FakeFirebase()..offline = true;
    final s = service(fb, MemoryStore());
    expect(await s.submit('2026-11-10', result), isFalse);
    expect(await s.top('2026-11-10'), isNull);
  });

  test('names are trimmed and shortened', () {
    expect(FirebaseLeaderboardService.cleanName('  a  b '), 'a b');
    expect(
      FirebaseLeaderboardService.cleanName('x' * 30),
      'x' * FirebaseLeaderboardService.maxNameLength,
    );
  });
}
