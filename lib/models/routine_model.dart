class RoutineModel {
  final String id;
  final String title;
  final String description;
  final int expReward;
  final int streak;
  final String status;
  final DateTime dueDate;
  final DateTime? lastCompletedDate;

  const RoutineModel({
    required this.id,
    required this.title,
    this.description = '',
    this.expReward = 0,
    this.streak = 0,
    this.status = 'Pending',
    required this.dueDate,
    this.lastCompletedDate,
  });
}