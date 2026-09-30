import 'package:pocketbase/pocketbase.dart';

import '../models/player_model.dart';
import '../models/shop_models.dart';
import 'auth_service.dart';
import 'player_service.dart';

class ShopService {
  ShopService({PocketBase? client}) : pb = client ?? AuthService.client;

  final PocketBase pb;

  String get _userId {
    final userId = pb.authStore.record?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('User must be authenticated.');
    }
    return userId;
  }

  Future<List<ShopItemModel>> fetchItems() async {
    final records = await pb.collection('shop').getFullList(sort: 'category,name');
    return records.map(_itemFromRecord).toList();
  }

  Future<PurchaseModel> purchaseItem(String itemId, String userId) async {
    if (userId.isEmpty || userId != _userId) {
      throw StateError('User must be authenticated as the purchaser.');
    }

    final itemRecord = await pb.collection('shop').getOne(itemId);
    final item = _itemFromRecord(itemRecord);
    if (item.price < 0) {
      throw StateError('Shop item has an invalid price.');
    }

    final playerRecord = await pb.collection('users').getOne(userId);
    final player = PlayerService.fromRecord(playerRecord);
    if (player.coins < item.price) {
      throw StateError(
        'Insufficient coins: ${player.coins} available, ${item.price} required.',
      );
    }

    final updatedPlayer = PlayerModel(
      level: player.level,
      currentExp: player.currentExp,
      expToNextLevel: player.expToNextLevel,
      hp: player.hp,
      coins: player.coins - item.price,
      amnestyPasses: player.amnestyPasses,
      amnestyWeekStart: player.amnestyWeekStart,
    );
    final updatedUserRecord = await pb.collection('users').update(
      userId,
      body: PlayerService.toBody(updatedPlayer),
    );
    try {
      final purchaseRecord = await pb.collection('purchases').create(
        body: {'user': userId, 'item': item.id, 'price': item.price},
      );
      pb.authStore.save(pb.authStore.token, updatedUserRecord);
      return _purchaseFromRecord(purchaseRecord);
    } catch (error) {
      await pb.collection('users').update(
        userId,
        body: PlayerService.toBody(player),
      );
      throw StateError('Purchase failed. Coins were restored: $error');
    }
  }

  ShopItemModel _itemFromRecord(RecordModel record) {
    return ShopItemModel(
      id: record.id,
      name: record.data['name'] as String? ?? '',
      price: (record.data['price'] as num?)?.toInt() ?? 0,
      category: record.data['category'] as String? ?? '',
      item: record.data['item'] as String? ?? '',
    );
  }

  PurchaseModel _purchaseFromRecord(RecordModel record) {
    return PurchaseModel(
      id: record.id,
      itemId: record.data['item'] as String? ?? '',
      userId: record.data['user'] as String? ?? '',
      price: (record.data['price'] as num?)?.toInt() ?? 0,
      purchasedAt: DateTime.tryParse(record.get<String>('created')) ??
          DateTime.now().toUtc(),
    );
  }

}