import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../game/game_controller.dart';
import '../l10n_ext.dart';
import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../widgets/cards.dart';
import '../widgets/kut_row.dart';
import '../widgets/world_background.dart';
import 'run_header.dart';

/// "Pazar": Kuts and items, packs, a voucher and reroll.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final run = state.run!;
    final shop = run.shop;
    final l10n = context.l10n;
    final controller = ref.read(gameControllerProvider.notifier);
    if (shop == null) return const Scaffold();

    final voucher = run.floorVoucher;
    final rerollCost = run.rerollCost;

    return Scaffold(
      body: WorldBackground(
        world: run.world,
        child: SafeArea(
          child: Column(
            children: [
              RunHeader(title: l10n.shopTitle),
              const KutRow(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    SectionLabel(l10n.consumablesTitle),
                    const Spacer(),
                    const ConsumableBar(cardWidth: 40),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  children: [
                    SectionLabel(l10n.itemsTitle),
                    const SizedBox(height: 6),
                    for (var i = 0; i < shop.items.length; i++)
                      _OfferRow(
                        key: Key('shop-item-$i'),
                        offer: shop.items[i],
                        money: run.money,
                        onBuy: () => controller.buyItem(i),
                      ),
                    const SizedBox(height: 10),
                    SectionLabel(l10n.packsTitle),
                    const SizedBox(height: 6),
                    for (var i = 0; i < shop.packs.length; i++)
                      _OfferRow(
                        key: Key('shop-pack-$i'),
                        offer: shop.packs[i],
                        money: run.money,
                        onBuy: () => controller.buyPack(i),
                        packChoices: run.rules.packChoices,
                      ),
                    const SizedBox(height: 10),
                    SectionLabel(l10n.voucherTitle),
                    const SizedBox(height: 6),
                    _OfferRow(
                      key: const Key('shop-voucher'),
                      offer: voucher == null
                          ? null
                          : VoucherOffer(voucher, run.priceOf(voucher.price)),
                      money: run.money,
                      onBuy: controller.buyVoucher,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('reroll'),
                        onPressed: run.money >= rerollCost
                            ? controller.reroll
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Palette.gold,
                          side: const BorderSide(color: Palette.goldDark),
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: Text(
                          rerollCost == 0
                              ? l10n.rerollFree
                              : l10n.reroll(rerollCost),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        key: const Key('leave-shop'),
                        onPressed: controller.leaveShop,
                        style: FilledButton.styleFrom(
                          backgroundColor: Palette.blue,
                          foregroundColor: Palette.cream,
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(color: Palette.gold),
                          textStyle: const TextStyle(
                            fontFamily: appFontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: Text(l10n.leaveShop),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One shop offer: art, name, description, price + buy.
class _OfferRow extends StatelessWidget {
  const _OfferRow({
    super.key,
    required this.offer,
    required this.money,
    required this.onBuy,
    this.packChoices = 3,
  });

  final ShopOffer? offer;
  final int money;
  final VoidCallback onBuy;
  final int packChoices;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final o = offer;
    const artWidth = 56.0;
    final (Widget art, String title, String desc) = switch (o) {
      KutOffer(:final kut) => (
        KutCard(definition: kut, width: artWidth),
        '${l10n.kutName(kut.id)} · ${l10n.rarityName(kut.rarity)}',
        l10n.kutDescription(kut.id),
      ),
      ConsumableOffer(:final item) => (
        ConsumableCard(item: item, width: artWidth),
        l10n.consumableName(item),
        l10n.consumableDescription(item),
      ),
      PackOffer(:final kind) => (
        _PackArt(kind: kind, width: artWidth),
        l10n.packName(kind),
        l10n.packDesc(packChoices),
      ),
      VoucherOffer(:final voucher) => (
        _VoucherArt(width: artWidth),
        l10n.voucherName(voucher.id),
        l10n.voucherDescription(voucher.id),
      ),
      null => (EmptySlot(width: artWidth, label: ''), l10n.soldOut, ''),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Palette.night.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.goldDark.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          art,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: o == null ? Palette.textMuted : Palette.cream,
                  ),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Palette.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (o != null) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: money >= o.price ? onBuy : null,
              style: FilledButton.styleFrom(
                backgroundColor: Palette.gold,
                foregroundColor: Palette.night,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                l10n.price(o.price),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PackArt extends StatelessWidget {
  const _PackArt({required this.kind, required this.width});
  final PackKind kind;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = switch (kind) {
      PackKind.kut => Palette.nightLighter,
      PackKind.destan => const Color(0xFFC9AE73),
      PackKind.tilsim => const Color(0xFF1F5C5A),
      PackKind.tile => Palette.woodLight,
    };
    return Container(
      width: width,
      height: width * 1.3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(width * 0.45),
          bottom: const Radius.circular(10),
        ),
        border: Border.all(color: Palette.gold, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.auto_awesome, color: Palette.gold, size: width * 0.4),
    );
  }
}

class _VoucherArt extends StatelessWidget {
  const _VoucherArt({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: width * 1.3,
    decoration: BoxDecoration(
      color: Palette.cream,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Palette.goldDark, width: 2),
    ),
    alignment: Alignment.center,
    child: Icon(Icons.verified, color: Palette.goldDark, size: width * 0.5),
  );
}
