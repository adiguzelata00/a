import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/monetization_service.dart';
import 'services/storage.dart';
import 'ui/game/game_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Device storage is loaded once at start; reads are synchronous after.
  KeyValueStore store;
  try {
    store = await SharedPrefsStore.open();
  } catch (_) {
    store = MemoryStore(); // e.g. storage blocked in a browser
  }

  // `?seed=CODE` (web/debug builds) starts a reproducible run.
  final seed = Uri.base.queryParameters['seed'];
  final container = ProviderContainer(
    overrides: [
      storageProvider.overrideWithValue(store),
      initialSeedCodeProvider.overrideWithValue(seed),
    ],
  );
  runApp(
    UncontrolledProviderScope(container: container, child: const TengriApp()),
  );

  // Ads (Android/iOS): consent form where required, then the SDK. After the
  // first frame so the form has a screen to show on; play never waits.
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => container.read(monetizationServiceProvider).initialize(),
  );
}
