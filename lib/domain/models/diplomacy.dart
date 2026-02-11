enum RelationType { neutral, friendly, hostile, allied, atWar }

enum PactType { nonAggression, trade, mutualDefense, alliance }

class DiplomacyRelation {
  final int id;
  final int colony1Id;
  final int colony2Id;
  final RelationType relationType;
  final int disposition;
  final double trustLevel;
  final DateTime lastInteraction;
  final PactType? pactType;
  final DateTime? pactExpiryTime;
  final bool treatyViolated;

  const DiplomacyRelation({
    required this.id,
    required this.colony1Id,
    required this.colony2Id,
    this.relationType = RelationType.neutral,
    this.disposition = 0,
    this.trustLevel = 0.5,
    required this.lastInteraction,
    this.pactType,
    this.pactExpiryTime,
    this.treatyViolated = false,
  });

  DiplomacyRelation copyWith({
    int? id,
    int? colony1Id,
    int? colony2Id,
    RelationType? relationType,
    int? disposition,
    double? trustLevel,
    DateTime? lastInteraction,
    PactType? pactType,
    DateTime? pactExpiryTime,
    bool? treatyViolated,
  }) =>
      DiplomacyRelation(
        id: id ?? this.id,
        colony1Id: colony1Id ?? this.colony1Id,
        colony2Id: colony2Id ?? this.colony2Id,
        relationType: relationType ?? this.relationType,
        disposition: disposition ?? this.disposition,
        trustLevel: trustLevel ?? this.trustLevel,
        lastInteraction: lastInteraction ?? this.lastInteraction,
        pactType: pactType ?? this.pactType,
        pactExpiryTime: pactExpiryTime ?? this.pactExpiryTime,
        treatyViolated: treatyViolated ?? this.treatyViolated,
      );
}
