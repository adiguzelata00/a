import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/app.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/kuts.dart';
import 'package:tengri_taslari/services/save_service.dart';
import 'package:tengri_taslari/services/storage.dart';
import 'package:tengri_taslari/ui/game/game_state.dart';
import 'package:tengri_taslari/ui/game/profile_controller.dart';

import 'game_flow_test.dart' show Harness;

/// Pumps the app without forcing a language (settings decide) and with
/// fixed frames (the menu animates forever).
Future<void> pumpApp(WidgetTester tester, Harness h) async {
  // Unmount any previous app so a "restart" starts from a clean tree.
  await tester.pumpWidget(const SizedBox());
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: h.container, child: const TengriApp()),
  );
  await tester.pump(const Duration(seconds: 1));
}

Future<void> tapAndWait(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  // Several frames: pushed routes are built offstage in their first frame.
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets('the run is saved automatically and continues after restart', (
    tester,
  ) async {
    final store = MemoryStore();
    final first = Harness(target: 1, money: 20, store: store);
    await pumpApp(tester, first);
    expect(store.data.containsKey(SaveService.runKey), isTrue);

    await tapAndWait(tester, 'start-round');
    await first.playOut(tester);
    await tapAndWait(tester, 'collect');
    expect(first.run.phase, RunPhase.shop);
    final money = first.run.money;
    final saved = jsonDecode(store.data[SaveService.runKey]!) as Map;
    expect(saved['phase'], 'shop');

    // "Restart the app": a new container with the same storage, no seed.
    final second = Harness(seed: null, store: store);
    await pumpApp(tester, second);
    expect(second.state.screen, GameScreen.menu);
    expect(find.byKey(const Key('menu-continue')), findsOneWidget);
    expect(find.textContaining('$money Akçe'), findsOneWidget);
    await tapAndWait(tester, 'menu-continue');
    expect(second.state.screen, GameScreen.shop);
    expect(second.run.money, money);
    expect(second.music.starts, greaterThan(0));
  });

  testWidgets('closing mid-round resumes at the start of that round', (
    tester,
  ) async {
    final store = MemoryStore();
    final first = Harness(target: 1 << 30, store: store);
    await pumpApp(tester, first);
    await tapAndWait(tester, 'start-round');
    final rack = first.round.rack;
    await tester.tap(first.rackTile(0));
    await tester.pump();
    await tapAndWait(tester, 'discard-button');
    expect(first.round.discardsLeft, 2);

    final second = Harness(seed: null, store: store);
    await pumpApp(tester, second);
    await tapAndWait(tester, 'menu-continue');
    expect(second.state.screen, GameScreen.roundSelect);
    await tapAndWait(tester, 'start-round');
    expect(second.round.rack, rack, reason: 'same seed, same tiles');
    expect(second.round.discardsLeft, 3);
  });

  testWidgets('a lost run deletes the save; menu offers no continue', (
    tester,
  ) async {
    final store = MemoryStore();
    final h = Harness(target: 1 << 30, store: store);
    await pumpApp(tester, h);
    await tapAndWait(tester, 'start-round');
    await h.playOut(tester);
    expect(h.state.screen, GameScreen.runEnd);
    expect(store.data.containsKey(SaveService.runKey), isFalse);

    final again = Harness(seed: null, store: store);
    await pumpApp(tester, again);
    expect(find.byKey(const Key('menu-continue')), findsNothing);
  });

  testWidgets('starting a new run over a saved one asks first', (tester) async {
    final store = MemoryStore();
    final first = Harness(store: store);
    await pumpApp(tester, first);
    final second = Harness(seed: null, store: store);
    await pumpApp(tester, second);
    await tapAndWait(tester, 'menu-new-run');
    expect(find.byKey(const Key('confirm-new-run')), findsOneWidget);
    await tapAndWait(tester, 'confirm-new-run');
    expect(second.state.screen, GameScreen.roundSelect);
    expect(second.run.seedCode, isNot('TESTSEED'));
  });

  testWidgets('settings are saved, applied and survive a restart', (
    tester,
  ) async {
    final store = MemoryStore();
    final h = Harness(seed: null, store: store);
    await pumpApp(tester, h);
    await tapAndWait(tester, 'menu-settings');
    expect(find.text('Ayarlar'), findsWidgets);

    await tapAndWait(tester, 'setting-sound');
    expect(h.audio.enabled, isFalse);
    await tapAndWait(tester, 'setting-vibration');
    expect(h.haptics.enabled, isFalse);
    await tapAndWait(tester, 'setting-colorblind');

    // Switch to English: the screen title changes right away.
    await tester.tap(find.text('English'));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('Settings'), findsWidgets);

    final again = Harness(seed: null, store: store);
    await pumpApp(tester, again);
    expect(again.audio.enabled, isFalse);
    expect(again.haptics.enabled, isFalse);
    expect(find.text('New Run'), findsOneWidget);
  });

  testWidgets('collection shows discovered Kuts and profile records', (
    tester,
  ) async {
    final store = MemoryStore();
    final h = Harness(store: store);
    h.run.addKut(kutById('asena'));
    await pumpApp(tester, h);
    // Any state change triggers the save + profile bookkeeping.
    h.controller.toMenu();
    await tester.pump(const Duration(seconds: 1));
    expect(h.container.read(profileProvider).discoveredKuts, contains('asena'));

    await tapAndWait(tester, 'menu-collection');
    expect(find.text('Asena'), findsOneWidget);
    expect(find.text('Henüz açılmadı'), findsWidgets);
    expect(find.textContaining(' · 1/'), findsOneWidget);
  });
}
