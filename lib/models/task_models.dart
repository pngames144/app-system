class TaskModel {
  final String id;
  final String title;
  final String description;
  final int expReward;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.expReward,
    this.isCompleted = false,

  });
}