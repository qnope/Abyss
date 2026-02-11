enum UnitClass { torpedo, swarm, leviathan }

enum UnitTier { t1, t2, t3 }

enum UnitType {
  // Torpedoes (class: torpedo)
  raie,
  espadon,
  fantome,
  // Swarms (class: swarm)
  alevin,
  piranha,
  meduse,
  // Leviathans (class: leviathan)
  nautile,
  kraken,
  behemoth,
}

extension UnitTypeProperties on UnitType {
  UnitClass get unitClass {
    switch (this) {
      case UnitType.raie:
      case UnitType.espadon:
      case UnitType.fantome:
        return UnitClass.torpedo;
      case UnitType.alevin:
      case UnitType.piranha:
      case UnitType.meduse:
        return UnitClass.swarm;
      case UnitType.nautile:
      case UnitType.kraken:
      case UnitType.behemoth:
        return UnitClass.leviathan;
    }
  }

  UnitTier get tier {
    switch (this) {
      case UnitType.raie:
      case UnitType.alevin:
      case UnitType.nautile:
        return UnitTier.t1;
      case UnitType.espadon:
      case UnitType.piranha:
      case UnitType.kraken:
        return UnitTier.t2;
      case UnitType.fantome:
      case UnitType.meduse:
      case UnitType.behemoth:
        return UnitTier.t3;
    }
  }
}

enum TroopStatus { idle, moving, fighting, returning }

class Troop {
  final int id;
  final int colonyId;
  final UnitType unitType;
  final int count;
  final int healthPerUnit;
  final TroopStatus status;
  final double? targetX;
  final double? targetY;
  final DateTime? etaArrival;
  final double morale;
  final DateTime trainedAt;

  const Troop({
    required this.id,
    required this.colonyId,
    required this.unitType,
    required this.count,
    required this.healthPerUnit,
    this.status = TroopStatus.idle,
    this.targetX,
    this.targetY,
    this.etaArrival,
    this.morale = 1.0,
    required this.trainedAt,
  });

  Troop copyWith({
    int? id,
    int? colonyId,
    UnitType? unitType,
    int? count,
    int? healthPerUnit,
    TroopStatus? status,
    double? targetX,
    double? targetY,
    DateTime? etaArrival,
    double? morale,
    DateTime? trainedAt,
  }) =>
      Troop(
        id: id ?? this.id,
        colonyId: colonyId ?? this.colonyId,
        unitType: unitType ?? this.unitType,
        count: count ?? this.count,
        healthPerUnit: healthPerUnit ?? this.healthPerUnit,
        status: status ?? this.status,
        targetX: targetX ?? this.targetX,
        targetY: targetY ?? this.targetY,
        etaArrival: etaArrival ?? this.etaArrival,
        morale: morale ?? this.morale,
        trainedAt: trainedAt ?? this.trainedAt,
      );
}
