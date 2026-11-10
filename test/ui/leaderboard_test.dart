import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/app.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/services/leaderboard/leaderboard_service.dart';
import 'package:tengri_taslari/services/settings_service.dart';
import 'package:tengri_taslari/ui/game/game_state.dart';

import 'game_flow_test.dart' show Harness;

/// In-memory "server": rows per (player, date), like the shared database.
class FakeServer {
  final Map<String, Map<String, DailyResult>> rows = {};
}

class FakeLeaderboard implements LeaderboardService {
  FakeLeaderboard(this.server, this.player);
  final FakeServer server;
  final String player;
  final List<String> submitted = [];

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> submit(String date, DailyResult result) async {
    submitted.add(date);
    (server.rows[player] ??= {})[date] = result;
    return true;
  }

  @override
  Future<List<LeaderboardEntry>?> top(String date) async => [
    for (final e in server.rows.entries)
      if (e.value[date] case final r?)
        LeaderboardEntry(
          name: e.key,
          isMe: e.key == player,
          floor: r.floor,
          score: r.score,
          won: r.won,
          finished: r.finished,
        ),
  ];
}

Future<void> frames(WidgetTester t) async {
  for (var i = 0; i < 5; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
}

Future<void> pumpApp(WidgetTester tester, Harness h) async {
  await tester.pumpWidget(const SizedBox());
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: h.container, child: const TengriApp()),
  );
  await frames(tester);
}

Future<void> tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await frames(tester);
}

LeaderboardEntry entry(int floor, int score, {bool won = false}) =>
    LeaderboardEntry(
      name: 'x',
      isMe: false,
      floor: floor,
      score: score,
      won: won,
      finished: true,
    );

void main() {
  test('ranking: winners first, then floor, then score', () {
    final list = [
      entry(5, 900),
      entry(8, 100, won: true),
      entry(5, 1200),
      entry(7, 50),
    ]..sort(LeaderboardEntry.compare);
    expect(
      [for (final e in list) (e.floor, e.score)],
      [(8, 100), (7, 50), (5, 1200), (5, 900)],
    );
  });

  testWidgets('without a backend the daily screen explains it', (tester) async {
    final h = Harness(seed: null);
    await pumpApp(tester, h);
    await tap(tester, 'menu-daily');
    await tester.ensureVisible(find.byKey(const Key('leaderboard')));
    expect(find.textContaining('Çevrimiçi sıralama'), findsOneWidget);
  });

  testWidgets('daily results are submitted and ranked with other players', (
    tester,
  ) async {
    final server = FakeServer();
    server.rows['Ayşe'] = {
      '2026-11-08': const DailyResult(
        floor: 4,
        won: false,
        score: 9000,
        finished: true,
      ),
    };
    server.rows['Mehmet'] = {
      '2026-11-07': const DailyResult(
        floor: 8,
        won: true,
        score: 50000,
        finished: true,
      ),
    };
    final board = FakeLeaderboard(server, 'me');
    final h = Harness(seed: null, target: 1 << 30, leaderboard: board);
    await pumpApp(tester, h);
    await tap(tester, 'menu-daily');
    await tester.ensureVisible(find.byKey(const Key('leaderboard')));
    expect(find.text('Ayşe'), findsOneWidget);
    expect(find.text('Mehmet'), findsNothing, reason: 'another day');

    await tap(tester, 'daily-play');
    expect(board.submitted, contains('2026-11-08'));
    await tap(tester, 'start-round');
    await h.playOut(tester);
    expect(h.state.screen, GameScreen.runEnd);
    expect(server.rows['me']!['2026-11-08']!.finished, isTrue);

    // Run end shows the ranking: Ayşe (floor 4) above me (floor 1).
    await tester.ensureVisible(find.byKey(const Key('leaderboard')));
    expect(find.text('Sen'), findsOneWidget);
    expect(find.text('Bugün 2. sıradasın · 2 oyuncu'), findsOneWidget);
    // No player name yet: the board says where to set one.
    expect(find.byKey(const Key('leaderboard-name-hint')), findsOneWidget);
  });

  testWidgets('the player name is set in Settings and kept', (tester) async {
    final h = Harness(seed: null);
    await pumpApp(tester, h);
    await tap(tester, 'menu-settings');
    await tester.ensureVisible(find.byKey(const Key('setting-name')));
    await tester.enterText(
      find.byKey(const Key('setting-name')),
      '  Tomris   Hatun ',
    );
    await frames(tester);
    expect(h.container.read(settingsProvider).playerName, 'Tomris Hatun');
    expect(h.store.getString(SettingsController.key), contains('Tomris'));
  });
}
