import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
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
  runApp(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(store),
        initialSeedCodeProvider.overrideWithValue(seed),
      ],
      child: const TengriApp(),
    ),
  );
}
