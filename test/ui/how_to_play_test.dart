import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/app.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/ui/screens/how_to_play_screen.dart';

import 'game_flow_test.dart' show Harness;

Future<void> frames(WidgetTester t) async {
  for (var i = 0; i < 5; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  test('every example in the guide is really that hand type', () {
    final okey = OkeyInfo(
      indicator: const Tile(id: -1, color: TileColor.blue, number: 7),
    );
    for (final e in HowToPlayScreen.examples.entries) {
      var id = 0;
      final tiles = [
        for (final (c, n) in e.value) Tile(id: id++, color: c, number: n),
      ];
      final r = const HandEvaluator().evaluate(
        tiles,
        okey,
        Balance.newHandLevels(),
      )!;
      expect(r.type, e.key, reason: e.key.name);
      expect(r.counted, hasLength(tiles.length), reason: e.key.name);
    }
  });

  testWidgets('main menu opens the guide', (tester) async {
    final h = Harness(seed: null);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: const TengriApp(),
      ),
    );
    await frames(tester);
    await tester.tap(find.byKey(const Key('menu-how-to')));
    await frames(tester);
    expect(find.byKey(const Key('how-to-play')), findsOneWidget);
    expect(find.text('Gösterge ve Okey'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Gök Per'), 300);
    expect(find.text('Gök Per'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the table help button opens the guide', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await h.startRound(tester);
    await tester.tap(find.byKey(const Key('hud-help')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('how-to-play')), findsOneWidget);
  });

  testWidgets('short phone with a large system font: table fits', (
    tester,
  ) async {
    final h = Harness();
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await h.pump(tester, size: const Size(720, 1180), ratio: 2);
    expect(tester.takeException(), isNull);
    await h.startRound(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(h.rackTile(0));
    await tester.tap(h.rackTile(1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('play-button')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
