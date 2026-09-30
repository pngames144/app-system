class PunishmentModel {
  final String id;
  final String userId;
  final String routineId;
  final String type;
  final String description;
  final int value;
  final String status;

  const PunishmentModel({
    required this.id,
    required this.userId,
    required this.routineId,
    required this.type,
    required this.description,
    required this.value,
    required this.status,
  });
}

class PunishmentDraft {
  final String type;
  final String description;
  final int value;

  const PunishmentDraft({
    required this.type,
    this.description = '',
    this.value = 0,
  });
}