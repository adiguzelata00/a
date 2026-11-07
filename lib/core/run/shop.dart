import '../scoring/kut.dart';
import '../tiles/tile.dart';
import 'items.dart';

/// Something for sale in the shop ("Pazar").
sealed class ShopOffer {
  const ShopOffer(this.price);
  final int price;
}

class KutOffer extends ShopOffer {
  const KutOffer(this.kut, super.price);
  final KutDefinition kut;
}

class ConsumableOffer extends ShopOffer {
  const ConsumableOffer(this.item, super.price);
  final ConsumableInstance item;
}

class PackOffer extends ShopOffer {
  const PackOffer(this.kind, super.price);
  final PackKind kind;
}

class VoucherOffer extends ShopOffer {
  const VoucherOffer(this.voucher, super.price);
  final VoucherDefinition voucher;
}

/// Current shop. `null` entries are sold out.
class Shop {
  Shop({required this.items, required this.packs});

  final List<ShopOffer?> items;
  final List<PackOffer?> packs;
  int rerolls = 0;
  bool freeRerollUsed = false;
}

/// One option inside an opened pack.
sealed class PackChoice {
  const PackChoice();
}

class KutChoice extends PackChoice {
  const KutChoice(this.kut);
  final KutDefinition kut;
}

class ConsumableChoice extends PackChoice {
  const ConsumableChoice(this.item);
  final ConsumableInstance item;
}

/// A tile template; it gets a real id when added to the deck.
class TileChoice extends PackChoice {
  const TileChoice(this.tile);
  final Tile tile;
}

/// An opened pack waiting for the player's choice.
class PackOpening {
  const PackOpening({required this.kind, required this.choices});
  final PackKind kind;
  final List<PackChoice> choices;
}
