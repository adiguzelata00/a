import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'ui/game/game_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // `?seed=CODE` (web/debug builds) starts a reproducible round.
  final seed = Uri.base.queryParameters['seed'];
  runApp(
    ProviderScope(
      overrides: [initialSeedCodeProvider.overrideWithValue(seed)],
      child: const TengriApp(),
    ),
  );
}
