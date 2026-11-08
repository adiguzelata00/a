import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';
import 'ui/game/game_root.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/tile_view.dart';

class TengriApp extends ConsumerWidget {
  const TengriApp({super.key, this.locale});

  /// Forced language (tests). Null = the language from the settings
  /// (Turkish by default).
  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps sound / music / vibration in sync with the settings.
    ref.watch(audioSettingsBinding);
    final language = ref.watch(settingsProvider.select((s) => s.languageCode));
    final colorBlind = ref.watch(settingsProvider.select((s) => s.colorBlind));

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: locale ?? Locale(language),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          TileStyle(colorBlind: colorBlind, child: child!),
      home: const GameRoot(),
    );
  }
}
