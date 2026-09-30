import 'package:pocketbase/pocketbase.dart';

import '../models/player_model.dart';
import '../models/task_models.dart';
import 'auth_service.dart';
import 'player_service.dart';

class TaskService {
  TaskService({PocketBase? client}) : pb = client ?? AuthService.client;

  final PocketBase pb;
  final Set<String> _completingTaskIds = <String>{};

  String get _userId {
    final userId = pb.authStore.record?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('User must be authenticated.');
    }
    return userId;
  }

  Future<List<TaskModel>> fetchTasks() async {
    final records = await pb.collection('tasks').getFullList(
          filter: 'user = "$_userId"',
          sort: '-created',
        );

    return records.map(_fromRecord).toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final record = await pb.collection('tasks').create(
      body: {
        'user': _userId,
        'title': task.title,
        'description': task.description,
        'expReward': task.expReward,
        'isCompleted': task.isCompleted,
      },
    );

    return _fromRecord(record);
  }

  Future<void> deleteTask(String id) {
    return pb.collection('tasks').delete(id);
  }

  Future<PlayerModel> completeTask(String taskId, String userId) async {
    if (userId.isEmpty || pb.authStore.record?.id != userId) {
      throw StateError('User must be authenticated as the task owner.');
    }

    if (!_completingTaskIds.add(taskId)) {
      throw StateError('Task completion is already in progress.');
    }

    try {
      final taskRecord = await pb.collection('tasks').getFirstListItem(
        'id = "$taskId" && user = "$userId"',
      );
      final task = _fromRecord(taskRecord);
      if (task.isCompleted) {
        throw StateError('Task has already been completed.');
      }

      final playerRecord = await pb.collection('users').getOne(userId);
      final stats = PlayerService.fromRecord(playerRecord);
      final updatedStats = PlayerModel(
        level: stats.level,
        currentExp: stats.currentExp + task.expReward,
        expToNextLevel: stats.expToNextLevel,
        hp: stats.hp,
        coins: stats.coins + task.expReward,
        amnestyPasses: stats.amnestyPasses,
        amnestyWeekStart: stats.amnestyWeekStart,
      );
      if (updatedStats.currentExp >= updatedStats.expToNextLevel) {
        updatedStats.level++;
        updatedStats.currentExp = 0;
        updatedStats.expToNextLevel =
            (updatedStats.expToNextLevel * 1.2).round();
      }

      final updatedUserRecord = await pb.collection('users').update(
        userId,
        body: PlayerService.toBody(updatedStats),
      );
      try {
        await pb.collection('tasks').update(taskId, body: {'isCompleted': true});
      } catch (error) {
        await pb.collection('users').update(
          userId,
          body: PlayerService.toBody(stats),
        );
        throw StateError('Could not complete task. Player stats were restored: $error');
      }
      pb.authStore.save(pb.authStore.token, updatedUserRecord);
      return updatedStats;
    } finally {
      _completingTaskIds.remove(taskId);
    }
  }

  TaskModel _fromRecord(RecordModel record) {
    return TaskModel(
      id: record.id,
      title: record.data['title'] as String? ?? '',
      description: record.data['description'] as String? ?? '',
      expReward: (record.data['expReward'] as num?)?.toInt() ?? 0,
      isCompleted: record.data['isCompleted'] as bool? ?? false,
    );
  }
}