enum QuestType { daily, discovery }

class Quest {
  final int id;
  final String questId;
  final String name;
  final QuestType questType;
  final String description;
  final double progressPercentage;
  final bool isCompleted;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int rewardXp;
  final int rewardCredits;
  final bool isActive;

  const Quest({
    required this.id,
    required this.questId,
    required this.name,
    required this.questType,
    required this.description,
    this.progressPercentage = 0.0,
    this.isCompleted = false,
    this.startedAt,
    this.completedAt,
    this.rewardXp = 0,
    this.rewardCredits = 0,
    this.isActive = true,
  });

  Quest copyWith({
    int? id,
    String? questId,
    String? name,
    QuestType? questType,
    String? description,
    double? progressPercentage,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
    int? rewardXp,
    int? rewardCredits,
    bool? isActive,
  }) =>
      Quest(
        id: id ?? this.id,
        questId: questId ?? this.questId,
        name: name ?? this.name,
        questType: questType ?? this.questType,
        description: description ?? this.description,
        progressPercentage: progressPercentage ?? this.progressPercentage,
        isCompleted: isCompleted ?? this.isCompleted,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        rewardXp: rewardXp ?? this.rewardXp,
        rewardCredits: rewardCredits ?? this.rewardCredits,
        isActive: isActive ?? this.isActive,
      );
}
