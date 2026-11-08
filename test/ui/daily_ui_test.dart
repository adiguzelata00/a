import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/app.dart';
import 'package:tengri_taslari/services/save_service.dart';
import 'package:tengri_taslari/services/storage.dart';
import 'package:tengri_taslari/ui/game/game_state.dart';
import 'package:tengri_taslari/ui/game/profile_controller.dart';

import 'game_flow_test.dart' show Harness;

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

Future<void> openDailyAndStart(WidgetTester tester) async {
  await tap(tester, 'menu-daily');
  expect(find.byKey(const Key('daily-screen')), findsOneWidget);
  await tap(tester, 'daily-play');
}

void main() {
  testWidgets('daily challenge starts from the menu with its Kut and bonus', (
    tester,
  ) async {
    final h = Harness(seed: null);
    await pumpApp(tester, h);
    expect(find.text('Bugünün meydan okuması hazır'), findsOneWidget);
    await tap(tester, 'menu-daily');
    expect(find.byKey(const Key('daily-bonus')), findsOneWidget);
    expect(find.text('Başlangıç Kut\'u'.toUpperCase()), findsOneWidget);
    await tap(tester, 'daily-play');
    expect(h.state.screen, GameScreen.roundSelect);
    expect(h.run.isDaily, isTrue);
    expect(h.run.dailyDate, '2026-11-08');
    expect(h.run.seedCode, 'GUN20261108');
    expect(h.run.kuts, hasLength(1));
  });

  testWidgets('daily and normal runs are saved in separate slots', (
    tester,
  ) async {
    final store = MemoryStore();
    final h = Harness(seed: null, store: store);
    await pumpApp(tester, h);
    h.controller.newRun(seedCode: 'NORMAL1');
    await frames(tester);
    h.controller.toMenu();
    await frames(tester);
    await openDailyAndStart(tester);
    expect(store.data.containsKey(SaveService.runKey), isTrue);
    expect(store.data.containsKey(SaveService.dailyKey), isTrue);

    // Restart: both can be continued independently.
    final again = Harness(seed: null, store: store);
    await pumpApp(tester, again);
    expect(again.state.normalRun!.seedCode, 'NORMAL1');
    expect(again.state.dailyRun!.isDaily, isTrue);
    expect(find.textContaining('Devam ediyor'), findsOneWidget);
    await tap(tester, 'menu-continue');
    expect(again.run.seedCode, 'NORMAL1');
    again.controller.toMenu();
    await frames(tester);
    await openDailyAndStart(tester);
    expect(again.run.isDaily, isTrue);
  });

  testWidgets('one attempt per day; result is shared and kept in history', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    final store = MemoryStore();
    final h = Harness(seed: null, target: 1 << 30, store: store);
    await pumpApp(tester, h);
    await openDailyAndStart(tester);
    await tap(tester, 'start-round');
    await h.playOut(tester);
    expect(h.state.screen, GameScreen.runEnd);
    expect(find.textContaining('Günlük Meydan Okuma'), findsOneWidget);
    expect(find.byKey(const Key('new-run')), findsNothing);
    await tap(tester, 'daily-share-end');
    expect(copied, contains('Günlük'));
    expect(copied, contains('Kat 1'));
    expect(copied, contains('GUN20261108'));

    final result = h.container.read(profileProvider).dailyResults['2026-11-08'];
    expect(result!.finished, isTrue);

    await tap(tester, 'end-to-menu');
    expect(find.textContaining('Bugün tamamlandı'), findsOneWidget);
    await tap(tester, 'menu-daily');
    final play = tester.widget<FilledButton>(
      find.byKey(const Key('daily-play')),
    );
    expect(play.onPressed, isNull, reason: 'no second attempt today');
    expect(find.byKey(const Key('daily-result')), findsOneWidget);

    // The next day: a new challenge, yesterday is in the history.
    final tomorrow = Harness(
      seed: null,
      store: store,
      now: DateTime(2026, 11, 9, 9),
    );
    await pumpApp(tester, tomorrow);
    expect(find.text('Bugünün meydan okuması hazır'), findsOneWidget);
    await tap(tester, 'menu-daily');
    expect(find.text('Kat 1 · ${result.score} puan'), findsOneWidget);
    await tap(tester, 'daily-play');
    expect(tomorrow.run.dailyDate, '2026-11-09');
  });
}
