class ShopItemModel {
  final String id;
  final String name;
  final int price;
  final String category;
  final String item;

  const ShopItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.item,
  });
}

class PurchaseModel {
  final String id;
  final String itemId;
  final String userId;
  final int price;
  final DateTime purchasedAt;

  const PurchaseModel({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.price,
    required this.purchasedAt,
  });
}