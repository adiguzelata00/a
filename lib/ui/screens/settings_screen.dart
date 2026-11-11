import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/services/leaderboard/firebase_leaderboard.dart';
import 'package:tengri_taslari/services/monetization_service.dart';
import 'package:tengri_taslari/services/settings_service.dart';

import '../l10n_ext.dart';
import '../theme/palette.dart';
import '../widgets/tile_view.dart';

/// "Ayarlar": sound, music, vibration, language, game speed, color-blind,
/// leaderboard name.
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
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
          const Divider(),
          _Choice(
            title: l10n.settingPlayerName,
            subtitle: l10n.settingPlayerNameDesc,
            child: _NameField(
              initial: s.playerName,
              onChanged: (v) => c.update(
                (s) => s.copyWith(
                  playerName: FirebaseLeaderboardService.cleanName(v),
                ),
              ),
            ),
          ),
          const _PrivacyOptions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// "Reklam gizlilik seçenekleri": only where the consent rules require a
/// way back to the ad consent form (e.g. in the EEA).
class _PrivacyOptions extends ConsumerStatefulWidget {
  const _PrivacyOptions();

  @override
  ConsumerState<_PrivacyOptions> createState() => _PrivacyOptionsState();
}

class _PrivacyOptionsState extends ConsumerState<_PrivacyOptions> {
  late final Future<bool> _required = ref
      .read(monetizationServiceProvider)
      .privacyOptionsRequired();

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _required,
    builder: (context, snap) {
      if (snap.data != true) return const SizedBox.shrink();
      final l10n = context.l10n;
      return ListTile(
        key: const Key('setting-privacy'),
        leading: const Icon(Icons.privacy_tip_outlined, color: Palette.gold),
        title: Text(l10n.settingPrivacyOptions),
        subtitle: Text(l10n.settingPrivacyOptionsDesc),
        onTap: () => ref.read(monetizationServiceProvider).showPrivacyOptions(),
      );
    },
  );
}

class _NameField extends StatefulWidget {
  const _NameField({required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    key: const Key('setting-name'),
    controller: _controller,
    maxLength: FirebaseLeaderboardService.maxNameLength,
    inputFormatters: [
      LengthLimitingTextInputFormatter(
        FirebaseLeaderboardService.maxNameLength,
      ),
    ],
    textCapitalization: TextCapitalization.words,
    decoration: InputDecoration(
      hintText: context.l10n.leaderboardSomeone,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
    onChanged: widget.onChanged,
  );
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
