enum BuildingType {
  biomassFarm,
  mineralMine,
  energyPlant,
  tradingPost,
  shipyard,
  launchBay,
  sonicTurret,
  habitat,
  laboratory,
  warehouse,
}

enum BuildingCategory { production, military, utility }

class BuildingModule {
  final int id;
  final int colonyId;
  final BuildingType type;
  final int level;
  final DateTime? constructionEndTime;
  final int damageLevel;
  final double productionRate;
  final bool isActive;
  final DateTime builtAt;

  const BuildingModule({
    required this.id,
    required this.colonyId,
    required this.type,
    this.level = 1,
    this.constructionEndTime,
    this.damageLevel = 0,
    this.productionRate = 1.0,
    this.isActive = true,
    required this.builtAt,
  });

  bool get isUnderConstruction =>
      constructionEndTime != null &&
      constructionEndTime!.isAfter(DateTime.now());

  BuildingCategory get category {
    switch (type) {
      case BuildingType.biomassFarm:
      case BuildingType.mineralMine:
      case BuildingType.energyPlant:
      case BuildingType.tradingPost:
        return BuildingCategory.production;
      case BuildingType.shipyard:
      case BuildingType.launchBay:
      case BuildingType.sonicTurret:
        return BuildingCategory.military;
      case BuildingType.habitat:
      case BuildingType.laboratory:
      case BuildingType.warehouse:
        return BuildingCategory.utility;
    }
  }

  BuildingModule copyWith({
    int? id,
    int? colonyId,
    BuildingType? type,
    int? level,
    DateTime? constructionEndTime,
    int? damageLevel,
    double? productionRate,
    bool? isActive,
    DateTime? builtAt,
  }) =>
      BuildingModule(
        id: id ?? this.id,
        colonyId: colonyId ?? this.colonyId,
        type: type ?? this.type,
        level: level ?? this.level,
        constructionEndTime: constructionEndTime ?? this.constructionEndTime,
        damageLevel: damageLevel ?? this.damageLevel,
        productionRate: productionRate ?? this.productionRate,
        isActive: isActive ?? this.isActive,
        builtAt: builtAt ?? this.builtAt,
      );
}
