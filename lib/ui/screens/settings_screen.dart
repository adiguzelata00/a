import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/services/settings_service.dart';

import '../l10n_ext.dart';
import '../theme/palette.dart';
import '../widgets/tile_view.dart';

/// "Ayarlar": sound, music, vibration, language, game speed, color-blind.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Palette.night,
        foregroundColor: Palette.gold,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SwitchListTile(
            key: const Key('setting-sound'),
            title: Text(l10n.settingSound),
            value: s.sound,
            onChanged: (v) => c.update((s) => s.copyWith(sound: v)),
          ),
          SwitchListTile(
            key: const Key('setting-music'),
            title: Text(l10n.settingMusic),
            value: s.music,
            onChanged: (v) => c.update((s) => s.copyWith(music: v)),
          ),
          SwitchListTile(
            key: const Key('setting-vibration'),
            title: Text(l10n.settingVibration),
            value: s.vibration,
            onChanged: (v) => c.update((s) => s.copyWith(vibration: v)),
          ),
          const Divider(),
          _Choice(
            title: l10n.settingLanguage,
            child: SegmentedButton<String>(
              key: const Key('setting-language'),
              segments: [
                ButtonSegment(value: 'tr', label: Text(l10n.languageTr)),
                ButtonSegment(value: 'en', label: Text(l10n.languageEn)),
              ],
              selected: {s.languageCode},
              onSelectionChanged: (v) =>
                  c.update((s) => s.copyWith(languageCode: v.single)),
            ),
          ),
          _Choice(
            title: l10n.settingSpeed,
            subtitle: l10n.settingSpeedDesc,
            child: SegmentedButton<int>(
              key: const Key('setting-speed'),
              segments: [
                for (final v in Settings.speeds)
                  ButtonSegment(value: v, label: Text(l10n.speedLabel(v))),
              ],
              selected: {s.gameSpeed},
              onSelectionChanged: (v) =>
                  c.update((s) => s.copyWith(gameSpeed: v.single)),
            ),
          ),
          const Divider(),
          SwitchListTile(
            key: const Key('setting-colorblind'),
            title: Text(l10n.settingColorBlind),
            subtitle: Text(l10n.settingColorBlindDesc),
            value: s.colorBlind,
            onChanged: (v) => c.update((s) => s.copyWith(colorBlind: v)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.colorBlindPreview,
                  style: const TextStyle(color: Palette.textMuted),
                ),
                const SizedBox(height: 8),
                TileStyle(
                  colorBlind: s.colorBlind,
                  child: Row(
                    children: [
                      for (final color in TileColor.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TileView(
                            tile: Tile(
                              id: -10 - color.index,
                              color: color,
                              number: 7 + color.index,
                            ),
                            okey: null,
                            width: 44,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(color: Palette.textMuted, fontSize: 13),
            ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
