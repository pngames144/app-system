import 'package:pocketbase/pocketbase.dart';

import '../models/punishment_model.dart';
import 'auth_service.dart';

class PunishmentService {
  PunishmentService({PocketBase? client}) : pb = client ?? AuthService.client;

  final PocketBase pb;

  String get _userId {
    final userId = pb.authStore.record?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('User must be authenticated.');
    }
    return userId;
  }

  Future<PunishmentModel> createForRoutine(
    String routineId,
    PunishmentDraft draft,
  ) async {
    final record = await pb.collection('punishments').create(
      body: {
        'user': _userId,
        'routine': routineId,
        'type': draft.type,
        'description': draft.description,
        'value': draft.value,
        'status': 'Pending',
      },
    );
    return _fromRecord(record);
  }

  Future<List<PunishmentModel>> fetchPunishments() async {
    final records = await pb.collection('punishments').getFullList(
          filter: 'user = "$_userId"',
          sort: '-created',
        );
    return records.map(_fromRecord).toList();
  }

  Future<void> useAmnestyPass(String punishmentId, String userId) async {
    if (userId.isEmpty || userId != _userId) {
      throw StateError('User must be authenticated as the punishment owner.');
    }

    final punishment = await pb.collection('punishments').getFirstListItem(
          'id = "$punishmentId" && user = "$userId"',
        );
    if ((punishment.data['status'] as String? ?? 'Pending') != 'Pending') {
      throw StateError('This punishment is no longer pending.');
    }

    final user = await pb.collection('users').getOne(userId);
    final passes = (user.data['amnestyPasses'] as num?)?.toInt() ?? 0;
    final storedWeek = DateTime.tryParse(
      user.data['amnestyWeekStart'] as String? ?? '',
    );
    final currentWeek = _startOfWeek(DateTime.now().toUtc());
    final effectivePasses = storedWeek == null ||
            _startOfWeek(storedWeek.toUtc()) != currentWeek
        ? 2
        : passes;
    if (effectivePasses <= 0) {
      throw StateError('No amnesty passes are available this week.');
    }

    await pb.collection('users').update(
      userId,
      body: {
        'amnestyPasses': effectivePasses - 1,
        'amnestyWeekStart': currentWeek.toIso8601String(),
      },
    );

    try {
      await pb.collection('event_logs').create(
        body: {
          'user': userId,
          'eventType': 'amnesty_pass_used',
          'punishment': punishmentId,
          'details': 'Amnesty pass used instead of applying a punishment.',
        },
      );
    } catch (error) {
      await pb.collection('users').update(
        userId,
        body: {
          'amnestyPasses': passes,
          'amnestyWeekStart': storedWeek?.toUtc().toIso8601String(),
        },
      );
      throw StateError('Could not use the amnesty pass. Changes were rolled back: $error');
    }
  }

  PunishmentModel _fromRecord(RecordModel record) {
    return PunishmentModel(
      id: record.id,
      userId: record.data['user'] as String? ?? '',
      routineId: record.data['routine'] as String? ?? '',
      type: record.data['type'] as String? ?? '',
      description: record.data['description'] as String? ?? '',
      value: (record.data['value'] as num?)?.toInt() ?? 0,
      status: record.data['status'] as String? ?? 'Pending',
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

}