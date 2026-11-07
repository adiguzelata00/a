import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/app.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/services/audio_service.dart';
import 'package:tengri_taslari/services/haptics_service.dart';
import 'package:tengri_taslari/ui/settings/settings_providers.dart';
import 'package:tengri_taslari/ui/table/table_controller.dart';

class FakeHaptics implements HapticsService {
  final List<HapticKind> calls = [];
  @override
  void trigger(HapticKind kind) => calls.add(kind);
}

class Harness {
  /// [realDelays]: use Future.delayed (fake-async time in widget tests)
  /// instead of skipping all playback delays.
  Harness({bool realDelays = false})
    : audio = PlaceholderAudioService(),
      haptics = FakeHaptics() {
    container = ProviderContainer(
      overrides: [
        initialSeedCodeProvider.overrideWithValue('TESTSEED'),
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

  TableController get controller =>
      container.read(tableControllerProvider.notifier);
  Round get round => container.read(tableControllerProvider).round;

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('tr'),
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TengriApp(locale: locale),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder rackTile(int index) =>
      find.byKey(Key('rack-tile-${round.rack[index].id}'));
}

void main() {
  testWidgets('table renders HUD, Kut cards and a 10-tile rack', (
    tester,
  ) async {
    final h = Harness();
    await h.pump(tester);
    expect(find.text('Hedef'), findsOneWidget);
    expect(find.text('300'), findsWidgets);
    expect(find.text('Umay Ana'), findsOneWidget);
    expect(find.text('Bozkurt'), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      expect(h.rackTile(i), findsOneWidget);
    }
    expect(find.text('Oynamak için taş seç'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting tiles shows the hand preview and enables buttons', (
    tester,
  ) async {
    final h = Harness();
    await h.pump(tester);
    final play = find.byKey(const Key('play-button'));
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(of: play, matching: find.byType(FilledButton)),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(h.rackTile(0));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hand-preview')), findsOneWidget);
    expect(find.text('Tek Taş'), findsOneWidget);
    expect(h.container.read(tableControllerProvider).selectedIds, hasLength(1));
    expect(h.haptics.calls, contains(HapticKind.select));

    // Tap again to deselect.
    await tester.tap(h.rackTile(0));
    await tester.pumpAndSettle();
    expect(h.container.read(tableControllerProvider).selectedIds, isEmpty);
  });

  testWidgets('at most 6 tiles can be selected', (tester) async {
    final h = Harness();
    await h.pump(tester);
    for (var i = 0; i < 8; i++) {
      await tester.tap(h.rackTile(i));
      await tester.pump();
    }
    expect(h.container.read(tableControllerProvider).selectedIds, hasLength(6));
  });

  testWidgets('playing a hand animates the score and refills the rack', (
    tester,
  ) async {
    final h = Harness(realDelays: true);
    await h.pump(tester);
    await tester.tap(h.rackTile(0));
    await tester.tap(h.rackTile(1));
    await tester.pump();
    final expected = h.round
        .simulate(h.container.read(tableControllerProvider).selectedIndices)
        .score;

    await tester.tap(find.byKey(const Key('play-button')));
    await tester.pump();
    // Playback is running: hand total appears before it is cleared.
    var sawTotal = false;
    var sawStep = false;
    for (
      var i = 0;
      i < 200 && h.container.read(tableControllerProvider).isAnimating;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
      if ((h.container.read(tableControllerProvider).playback?.step ?? -1) >=
          0) {
        sawStep = true;
      }
      if (find.byKey(const Key('hand-total')).evaluate().isNotEmpty) {
        sawTotal = true;
      }
    }
    await tester.pumpAndSettle();
    expect(sawStep, isTrue);
    expect(sawTotal, isTrue);

    final state = h.container.read(tableControllerProvider);
    expect(state.isAnimating, isFalse);
    expect(state.round.handsLeft, 3);
    expect(state.round.score, expected);
    expect(state.round.rack, hasLength(10));
    expect(h.audio.history, contains(SoundId.handScored));
    expect(tester.takeException(), isNull);
  });

  testWidgets('discard replaces the selected tiles', (tester) async {
    final h = Harness();
    await h.pump(tester);
    final before = h.round.rack.take(2).toList();
    await tester.tap(h.rackTile(0));
    await tester.tap(h.rackTile(1));
    await tester.pump();
    await tester.tap(find.byKey(const Key('discard-button')));
    await tester.pumpAndSettle();
    expect(h.round.discardsLeft, 2);
    expect(h.round.rack.any(before.contains), isFalse);
    expect(h.round.rack, hasLength(10));
  });

  testWidgets('sort buttons reorder the rack', (tester) async {
    final h = Harness();
    await h.pump(tester);
    await tester.tap(find.byKey(const Key('sort-color')));
    await tester.pumpAndSettle();
    final okey = h.round.okey;
    final colors = [
      for (final t in h.round.rack.where((t) => !okey.isWild(t)))
        okey.faceOf(t).color.index,
    ];
    expect(colors, [...colors]..sort());

    await tester.tap(find.byKey(const Key('sort-number')));
    await tester.pumpAndSettle();
    final numbers = [
      for (final t in h.round.rack.where((t) => !okey.isWild(t)))
        okey.faceOf(t).number == 1 ? 14 : okey.faceOf(t).number,
    ];
    expect(numbers, [...numbers]..sort());
  });

  testWidgets('dragging a tile onto another position reorders the rack', (
    tester,
  ) async {
    final h = Harness();
    await h.pump(tester);
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
    expect(h.round.rack, hasLength(10));
  });

  testWidgets('round end overlay appears and restarts the round', (
    tester,
  ) async {
    final h = Harness();
    await h.pump(tester);
    // Play single tiles until the round is over (win or lose).
    while (h.round.phase == RoundPhase.playing) {
      await tester.tap(h.rackTile(0));
      await tester.pump();
      await tester.tap(find.byKey(const Key('play-button')));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key('round-end')), findsOneWidget);
    await tester.tap(find.byKey(const Key('new-round-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('round-end')), findsNothing);
    expect(h.round.handsLeft, 4);
    expect(h.round.score, 0);
  });

  testWidgets('English locale', (tester) async {
    final h = Harness();
    await h.pump(tester, locale: const Locale('en'));
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
  });

  testWidgets('small phone (360×640 dp) lays out without overflow', (
    tester,
  ) async {
    final h = Harness();
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: h.container,
        child: const TengriApp(locale: Locale('tr')),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
