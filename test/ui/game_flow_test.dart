import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/app.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/kuts.dart';
import 'package:tengri_taslari/data/run_setup.dart';
import 'package:tengri_taslari/services/audio_service.dart';
import 'package:tengri_taslari/services/haptics_service.dart';
import 'package:tengri_taslari/ui/game/game_controller.dart';
import 'package:tengri_taslari/ui/game/game_state.dart';
import 'package:tengri_taslari/ui/settings/settings_providers.dart';

class FakeHaptics implements HapticsService {
  final List<HapticKind> calls = [];
  @override
  void trigger(HapticKind kind) => calls.add(kind);
}

class Harness {
  /// [seed] null = start on the main menu.
  /// [target] overrides every round target (e.g. 1 = instant win).
  /// [realDelays]: use Future.delayed (fake time) instead of no delays.
  Harness({
    String? seed = 'TESTSEED',
    int? target,
    int? money,
    bool realDelays = false,
  }) : audio = PlaceholderAudioService(),
       haptics = FakeHaptics() {
    final rules = defaultRunRules.copyWith(
      targetFor: target == null ? null : (f, r) => target,
      startingMoney: money,
    );
    container = ProviderContainer(
      overrides: [
        initialSeedCodeProvider.overrideWithValue(seed),
        runFactoryProvider.overrideWithValue(
          (s) => RunState(seedCode: s, rules: rules, catalog: defaultCatalog),
        ),
        delayProvider.overrideWithValue(
          realDelays ? (d) => Future<void>.delayed(d) : (_) async {},
        ),
        audioServiceProvider.overrideWithValue(audio),
        hapticsServiceProvider.overrideWithValue(haptics),
      ],
    );
  }

  final PlaceholderAudioService audio;
  final FakeHaptics haptics;
  late final ProviderContainer container;

  GameController get controller =>
      container.read(gameControllerProvider.notifier);
  GameState get state => container.read(gameControllerProvider);
  RunState get run => state.run!;
  Round get round => state.round!;

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('tr'),
    Size size = const Size(1080, 2340),
    double ratio = 3,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = ratio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TengriApp(locale: locale),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Finder rackTile(int index) =>
      find.byKey(Key('rack-tile-${round.rack[index].id}'));

  Future<void> startRound(WidgetTester tester) => tap(tester, 'start-round');

  /// Plays single tiles until the round is over.
  Future<void> playOut(WidgetTester tester) async {
    while (state.round?.phase == RoundPhase.playing &&
        state.screen == GameScreen.table) {
      await tester.tap(rackTile(0));
      await tester.pump();
      await tester.tap(find.byKey(const Key('play-button')));
      await tester.pumpAndSettle();
    }
  }
}

void main() {
  group('menu & round select', () {
    testWidgets('main menu starts a new run', (tester) async {
      final h = Harness(seed: null);
      // The menu sky turns forever, so pump fixed frames instead of settling.
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: h.container,
          child: const TengriApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.text("Tengri'nin Taşları"), findsOneWidget);
      expect(find.byKey(const Key('menu-continue')), findsNothing);
      await tester.tap(find.byKey(const Key('menu-new-run')));
      await tester.pumpAndSettle();
      expect(h.state.screen, GameScreen.roundSelect);
      expect(find.byKey(const Key('round-card-0')), findsOneWidget);
    });

    testWidgets('round select shows three trials with the boss', (
      tester,
    ) async {
      final h = Harness();
      await h.pump(tester);
      expect(find.text('Küçük Sınav'), findsOneWidget);
      expect(find.text('Büyük Sınav'), findsOneWidget);
      expect(find.text('${Balance.targetFor(1, 0)}'), findsWidgets);
      expect(find.textContaining('Atlarsan'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('skipping the small trial moves to the big trial', (
      tester,
    ) async {
      final h = Harness();
      await h.pump(tester);
      await h.tap(tester, 'skip-round');
      if (h.state.screen == GameScreen.pack) await h.tap(tester, 'skip-pack');
      expect(h.run.roundInFloor, 1);
      expect(find.text('Atlandı'), findsOneWidget);
    });

    testWidgets('menu button returns to the menu and continue resumes', (
      tester,
    ) async {
      final h = Harness();
      await h.pump(tester);
      // The menu sky turns forever: pump fixed time instead of settling.
      await tester.tap(find.byKey(const Key('to-menu')));
      await tester.pump(const Duration(seconds: 1));
      expect(h.state.screen, GameScreen.menu);
      await tester.tap(find.byKey(const Key('menu-continue')));
      await tester.pumpAndSettle();
      expect(h.state.screen, GameScreen.roundSelect);
    });
  });

  group('table', () {
    testWidgets('renders HUD, Kut slots and a 10-tile rack', (tester) async {
      final h = Harness();
      await h.pump(tester);
      await h.startRound(tester);
      expect(h.state.screen, GameScreen.table);
      expect(find.text('Hedef'), findsOneWidget);
      for (var i = 0; i < 10; i++) {
        expect(h.rackTile(i), findsOneWidget);
      }
      expect(find.text('Oynamak için taş seç'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting tiles shows the preview; max 6', (tester) async {
      final h = Harness();
      await h.pump(tester);
      await h.startRound(tester);
      await tester.tap(h.rackTile(0));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hand-preview')), findsOneWidget);
      expect(find.text('Tek Taş'), findsOneWidget);
      for (var i = 1; i < 8; i++) {
        await tester.tap(h.rackTile(i));
        await tester.pump();
      }
      expect(h.state.selectedIds, hasLength(6));
      expect(h.haptics.calls, contains(HapticKind.select));
    });

    testWidgets('playing a hand animates the score and refills the rack', (
      tester,
    ) async {
      final h = Harness(realDelays: true);
      await h.pump(tester);
      await h.startRound(tester);
      await tester.tap(h.rackTile(0));
      await tester.tap(h.rackTile(1));
      await tester.pump();
      final expected = h.round.simulate(h.state.selectedIndices).score;

      await tester.tap(find.byKey(const Key('play-button')));
      await tester.pump();
      var sawStep = false;
      var sawTotal = false;
      for (var i = 0; i < 200 && h.state.isAnimating; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if ((h.state.playback?.step ?? -1) >= 0) sawStep = true;
        if (find.byKey(const Key('hand-total')).evaluate().isNotEmpty) {
          sawTotal = true;
        }
      }
      await tester.pumpAndSettle();
      expect(sawStep, isTrue);
      expect(sawTotal, isTrue);
      expect(h.round.handsLeft, 3);
      expect(h.round.score, expected);
      expect(h.round.rack, hasLength(10));
      expect(h.audio.history, contains(SoundId.handScored));
      expect(tester.takeException(), isNull);
    });

    testWidgets('discard replaces the selected tiles', (tester) async {
      final h = Harness();
      await h.pump(tester);
      await h.startRound(tester);
      final before = h.round.rack.take(2).toList();
      await tester.tap(h.rackTile(0));
      await tester.tap(h.rackTile(1));
      await tester.pump();
      await h.tap(tester, 'discard-button');
      expect(h.round.discardsLeft, 2);
      expect(h.round.rack.any(before.contains), isFalse);
    });

    testWidgets('sort buttons and drag reorder the rack', (tester) async {
      final h = Harness();
      await h.pump(tester);
      await h.startRound(tester);
      await h.tap(tester, 'sort-color');
      final okey = h.round.okey;
      final colors = [
        for (final t in h.round.rack.where((t) => !okey.isWild(t)))
          okey.faceOf(t).color.index,
      ];
      expect(colors, [...colors]..sort());

      final first = h.round.rack[0];
      final from = tester.getCenter(h.rackTile(0));
      final to = tester.getCenter(h.rackTile(3));
      final gesture = await tester.startGesture(from);
      await tester.pump(const Duration(milliseconds: 50));
      for (var i = 1; i <= 10; i++) {
        await gesture.moveTo(Offset.lerp(from, to, i / 10)!);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(h.round.rack.indexOf(first), 3);
    });

    testWidgets('Kuts can be reordered by dragging', (tester) async {
      final h = Harness();
      h.run.addKut(kutById('umay_ana'));
      h.run.addKut(kutById('bozkurt'));
      await h.pump(tester);
      final from = tester.getCenter(find.byKey(const Key('kut-card-0')));
      final to = tester.getCenter(find.byKey(const Key('kut-card-1')));
      final gesture = await tester.startGesture(from);
      await tester.pump(const Duration(milliseconds: 50));
      for (var i = 1; i <= 10; i++) {
        await gesture.moveTo(Offset.lerp(from, to, i / 10)!);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(h.run.kuts.map((k) => k.id), ['bozkurt', 'umay_ana']);
    });

    testWidgets('boss round shows the boss restriction', (tester) async {
      final h = Harness(target: 1);
      await h.pump(tester);
      h.run.skipRound();
      if (h.run.phase == RunPhase.packOpen) h.run.skipPack();
      h.run.skipRound();
      if (h.run.phase == RunPhase.packOpen) h.run.skipPack();
      h.controller.startRound();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('boss-banner')), findsOneWidget);
    });
  });

  group('run loop', () {
    testWidgets('win → cashout → shop → next trial', (tester) async {
      final h = Harness(target: 1, money: 20);
      await h.pump(tester);
      await h.startRound(tester);
      await h.playOut(tester);
      expect(h.state.screen, GameScreen.cashout);
      expect(find.byKey(const Key('cashout-title')), findsOneWidget);
      expect(find.text('Tur ödülü'), findsOneWidget);
      final before = h.run.money;
      final total = h.run.lastSummary!.total;

      await h.tap(tester, 'collect');
      expect(h.run.money, before + total);
      expect(h.state.screen, GameScreen.shop);
      expect(find.text('Pazar'), findsOneWidget);

      // Buy the first item if affordable.
      final offer = h.run.shop!.items[0]!;
      final money = h.run.money;
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('shop-item-0')),
          matching: find.byType(FilledButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(h.run.money, money - offer.price);
      expect(h.run.shop!.items[0], isNull);

      await h.tap(tester, 'leave-shop');
      expect(h.state.screen, GameScreen.roundSelect);
      expect(h.run.roundInFloor, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('buying a pack opens it; choosing returns to the shop', (
      tester,
    ) async {
      final h = Harness(target: 1, money: 30);
      await h.pump(tester);
      await h.startRound(tester);
      await h.playOut(tester);
      await h.tap(tester, 'collect');
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('shop-pack-0')),
          matching: find.byType(FilledButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(h.state.screen, GameScreen.pack);
      final idx = [0, 1, 2].firstWhere(h.run.canChoose);
      await tester.tap(
        find.descendant(
          of: find.byKey(Key('pack-choice-$idx')),
          matching: find.byType(FilledButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(h.state.screen, GameScreen.shop);
    });

    testWidgets('not enough money shows a message', (tester) async {
      final h = Harness(target: 1);
      await h.pump(tester);
      await h.startRound(tester);
      await h.playOut(tester);
      await h.tap(tester, 'collect');
      h.run.money = 0;
      h.controller.reroll();
      await tester.pump();
      expect(find.text('Yeterli Akçe yok'), findsOneWidget);
    });

    testWidgets('losing shows the run end screen with stats', (tester) async {
      final h = Harness(target: 1 << 30);
      await h.pump(tester);
      await h.startRound(tester);
      await h.playOut(tester);
      expect(h.state.screen, GameScreen.runEnd);
      expect(find.text('Koşu bitti'), findsOneWidget);
      expect(find.text('Oynanan el'), findsOneWidget);
      await h.tap(tester, 'new-run');
      expect(h.state.screen, GameScreen.roundSelect);
      expect(h.run.stats.handsPlayed, 0);
    });

    testWidgets('a Destan can be used from the item sheet', (tester) async {
      final h = Harness();
      h.run.consumables.add(
        ConsumableInstance(defaultCatalog.destanFor(HandType.pair)),
      );
      await h.pump(tester);
      await h.tap(tester, 'consumable-0');
      expect(find.text('Türeyiş Destanı'), findsWidgets);
      await h.tap(tester, 'use-consumable');
      expect(h.run.levels.levelOf(HandType.pair), 2);
      expect(h.run.consumables, isEmpty);
    });

    testWidgets('a Tılsım uses the selected rack tiles', (tester) async {
      final h = Harness();
      h.run.consumables.add(
        ConsumableInstance(
          defaultCatalog.tilsims.firstWhere(
            (t) => t.effect == TilsimEffect.iron,
          ),
        ),
      );
      await h.pump(tester);
      await h.startRound(tester);
      final id = h.round.rack[0].id;
      await tester.tap(h.rackTile(0));
      await tester.pump();
      await h.tap(tester, 'consumable-0');
      await h.tap(tester, 'use-consumable');
      expect(h.run.deck.byId(id)!.enhancement, Enhancement.iron);
    });
  });

  testWidgets('English locale', (tester) async {
    final h = Harness();
    await h.pump(tester, locale: const Locale('en'));
    await h.startRound(tester);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
  });

  testWidgets('small phone (360×640 dp) lays out every screen', (tester) async {
    final h = Harness(target: 1, money: 30);
    await h.pump(tester, size: const Size(720, 1280), ratio: 2);
    expect(tester.takeException(), isNull);
    await h.startRound(tester);
    expect(tester.takeException(), isNull);
    await h.playOut(tester);
    expect(tester.takeException(), isNull);
    await h.tap(tester, 'collect');
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('shop-pack-0')),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('shop-pack-0')),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
