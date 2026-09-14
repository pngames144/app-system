import 'package:pocketbase/pocketbase.dart';

import '../models/player_model.dart';
import 'auth_service.dart';

class PlayerService {
  PlayerService({PocketBase? client}) : pb = client ?? AuthService.client;

  final PocketBase pb;

  String get _userId {
    final userId = pb.authStore.record?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('User must be authenticated.');
    }
    return userId;
  }

  Future<PlayerModel> getStats() async {
    final record = await pb.collection('users').getOne(_userId);
    pb.authStore.save(pb.authStore.token, record);
    return _fromRecord(record);
  }

  Future<PlayerModel> updateStats(PlayerModel stats) async {
    final record = await pb.collection('users').update(
      _userId,
      body: _toBody(stats),
    );
    pb.authStore.save(pb.authStore.token, record);
    return _fromRecord(record);
  }

  static Map<String, dynamic> toBody(PlayerModel stats) {
    return {
      'level': stats.level,
      'currentExp': stats.currentExp,
      'expToNextLevel': stats.expToNextLevel,
      'hp': stats.hp,
      'coins': stats.coins,
    };
  }

  static PlayerModel fromRecord(RecordModel record) {
    int value(String field, int fallback) {
      return (record.data[field] as num?)?.toInt() ?? fallback;
    }

    return PlayerModel(
      level: value('level', 1),
      currentExp: value('currentExp', 0),
      expToNextLevel: value('expToNextLevel', 100),
      hp: value('hp', 100),
      coins: value('coins', 0),
    );
  }

  Map<String, dynamic> _toBody(PlayerModel stats) {
    return toBody(stats);
  }

  PlayerModel _fromRecord(RecordModel record) {
    return fromRecord(record);
  }
}