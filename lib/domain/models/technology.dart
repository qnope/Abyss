enum TechBranch { architecture, armament, lifeSciences, energy, central }

enum TechTier { t1, t2, t3 }

class Technology {
  final int id;
  final String techId;
  final String name;
  final TechBranch branch;
  final TechTier tier;
  final bool isCompleted;
  final double completionPercentage;
  final DateTime? startTime;
  final DateTime? endTime;
  final int pointsRequired;
  final int pointsInvested;
  final List<String> prerequisites;

  const Technology({
    required this.id,
    required this.techId,
    required this.name,
    required this.branch,
    required this.tier,
    this.isCompleted = false,
    this.completionPercentage = 0.0,
    this.startTime,
    this.endTime,
    required this.pointsRequired,
    this.pointsInvested = 0,
    this.prerequisites = const [],
  });

  Technology copyWith({
    int? id,
    String? techId,
    String? name,
    TechBranch? branch,
    TechTier? tier,
    bool? isCompleted,
    double? completionPercentage,
    DateTime? startTime,
    DateTime? endTime,
    int? pointsRequired,
    int? pointsInvested,
    List<String>? prerequisites,
  }) =>
      Technology(
        id: id ?? this.id,
        techId: techId ?? this.techId,
        name: name ?? this.name,
        branch: branch ?? this.branch,
        tier: tier ?? this.tier,
        isCompleted: isCompleted ?? this.isCompleted,
        completionPercentage: completionPercentage ?? this.completionPercentage,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        pointsRequired: pointsRequired ?? this.pointsRequired,
        pointsInvested: pointsInvested ?? this.pointsInvested,
        prerequisites: prerequisites ?? this.prerequisites,
      );
}
