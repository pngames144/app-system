import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:my_app/services/punishment_service.dart';
import 'package:my_app/services/shop_service.dart';

void main() {
  const runLiveTests = bool.fromEnvironment('LIVE_PB_TESTS');

  test('purchase and amnesty workflows complete against local PocketBase', () async {
    final pb = PocketBase('http://127.0.0.1:8090');
    final auth = await pb.collection('users').authWithPassword(
          'test.user@app-system.local',
          'TestPassword123!',
        );
    final userId = auth.record.id;

    final shopItems = await pb.collection('shop').getList(
          page: 1,
          perPage: 1,
          filter: 'item = "integration-test-item"',
        );
    expect(shopItems.items, hasLength(1));

    final purchase = await ShopService(client: pb).purchaseItem(
      shopItems.items.first.id,
      userId,
    );
    expect(purchase.price, 25);
    final afterPurchase = await pb.collection('users').getOne(userId);
    expect(afterPurchase.data['coins'], 75);
    await ShopService(client: pb).purchaseItem(shopItems.items.first.id, userId);
    await ShopService(client: pb).purchaseItem(shopItems.items.first.id, userId);
    await ShopService(client: pb).purchaseItem(shopItems.items.first.id, userId);
    expect(
      () => ShopService(client: pb).purchaseItem(
        shopItems.items.first.id,
        userId,
      ),
      throwsA(isA<StateError>()),
    );
    final afterInsufficientFunds = await pb.collection('users').getOne(userId);
    expect(afterInsufficientFunds.data['coins'], 0);

    final routine = await pb.collection('routines').create(
      body: {
        'user': userId,
        'title': 'Live amnesty routine',
        'description': 'Integration test',
        'expReward': 1,
        'streak': 0,
        'status': 'Pending',
        'dueDate': DateTime.now().toUtc().add(const Duration(days: 1)).toIso8601String(),
      },
    );
    final punishment = await pb.collection('punishments').create(
      body: {
        'user': userId,
        'routine': routine.id,
        'type': 'hp',
        'description': 'Integration test',
        'value': 0,
        'status': 'Pending',
      },
    );

    await PunishmentService(client: pb).useAmnestyPass(punishment.id, userId);

    final updatedUser = await pb.collection('users').getOne(userId);
    final updatedPunishment = await pb.collection('punishments').getOne(punishment.id);
    final events = await pb.collection('event_logs').getList(
          page: 1,
          perPage: 1,
          filter: 'punishment = "${punishment.id}" && eventType = "amnesty_pass_used"',
        );
    expect(updatedUser.data['amnestyPasses'], 1);
    expect(updatedPunishment.data['status'], 'Pending');
    expect(events.items, hasLength(1));
  }, skip: runLiveTests ? null : 'Requires a running local PocketBase and seeded test item.');
}