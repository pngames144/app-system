import 'package:pocketbase/pocketbase.dart';

import '../models/routine_model.dart';
import '../models/punishment_model.dart';
import 'auth_service.dart';

class RoutineService {
  RoutineService({PocketBase? client}) : pb = client ?? AuthService.client;

  final PocketBase pb;

  String get _userId {
    final userId = pb.authStore.record?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('User must be authenticated.');
    }
    return userId;
  }

  Future<List<RoutineModel>> fetchRoutines() async {
    final records = await pb.collection('routines').getFullList(
          filter: 'user = "$_userId"',
          sort: 'dueDate,-created',
        );
    return records.map(_fromRecord).toList();
  }

  Future<RoutineModel> createRoutine(
    RoutineModel routine, {
    PunishmentDraft? punishment,
  }) async {
    final record = await pb.collection('routines').create(
      body: {
        'user': _userId,
        'title': routine.title,
        'description': routine.description,
        'expReward': routine.expReward,
        'streak': 0,
        'status': 'Pending',
        'dueDate': routine.dueDate.toUtc().toIso8601String(),
      },
    );
    if (punishment != null) {
      await pb.collection('punishments').create(
        body: {
          'user': _userId,
          'routine': record.id,
          'type': punishment.type,
          'description': punishment.description,
          'value': punishment.value,
          'status': 'Pending',
        },
      );
    }
    return _fromRecord(record);
  }

  Future<RoutineModel> completeRoutine(String routineId) async {
    final routineRecord = await pb.collection('routines').getFirstListItem(
          'id = "$routineId" && user = "$_userId"',
        );
    final routine = _fromRecord(routineRecord);
    final now = DateTime.now().toUtc();
    final today = _dateOnly(now);

    if (routine.status == 'Completed' &&
        routine.lastCompletedDate != null &&
        _dateOnly(routine.lastCompletedDate!.toUtc()) == today) {
      throw StateError('Routine has already been completed today.');
    }

    final streak = nextStreak(
      previousStreak: routine.streak,
      lastCompletedDate: routine.lastCompletedDate,
      today: now,
    );
    final record = await pb.collection('routines').update(
      routineId,
      body: {
        'status': 'Completed',
        'streak': streak,
        'lastCompletedDate': now.toIso8601String(),
        'dueDate': DateTime.utc(now.year, now.month, now.day + 1)
            .toIso8601String(),
      },
    );
    return _fromRecord(record);
  }

  static int nextStreak({
    required int previousStreak,
    required DateTime? lastCompletedDate,
    required DateTime today,
  }) {
    if (lastCompletedDate == null) return 1;
    final previousDay = DateTime.utc(today.year, today.month, today.day - 1);
    final lastDay = DateTime.utc(
      lastCompletedDate.toUtc().year,
      lastCompletedDate.toUtc().month,
      lastCompletedDate.toUtc().day,
    );
    return lastDay == previousDay ? previousStreak + 1 : 1;
  }

  RoutineModel _fromRecord(RecordModel record) {
    final dueDate = DateTime.tryParse(record.data['dueDate'] as String? ?? '') ??
        DateTime.now().toUtc();
    final lastCompleted = DateTime.tryParse(
      record.data['lastCompletedDate'] as String? ?? '',
    );
    return RoutineModel(
      id: record.id,
      title: record.data['title'] as String? ?? '',
      description: record.data['description'] as String? ?? '',
      expReward: (record.data['expReward'] as num?)?.toInt() ?? 0,
      streak: (record.data['streak'] as num?)?.toInt() ?? 0,
      status: record.data['status'] as String? ?? 'Pending',
      dueDate: dueDate,
      lastCompletedDate: lastCompleted,
    );
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);
}