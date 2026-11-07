import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'ui/table/table_screen.dart';
import 'ui/theme/app_theme.dart';

class TengriApp extends StatelessWidget {
  const TengriApp({super.key, this.locale = const Locale('tr')});

  /// App language. Turkish is the default; the language setting arrives in
  /// Phase 5 (null would follow the device locale).
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Phase 3 adds the menu / run flow; Phase 2 opens the table directly.
      home: const TableScreen(),
    );
  }
}
