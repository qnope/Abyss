part of '../history_entry.dart';

/// History entry recording a building construction or upgrade.
@HiveType(typeId: 19)
class BuildingEntry extends HistoryEntry {
  @HiveField(0)
  @override
  final int turn;

  @HiveField(1)
  @override
  final HistoryEntryCategory category;

  @HiveField(2)
  @override
  final String title;

  @HiveField(3)
  @override
  final String? subtitle;

  @HiveField(4)
  final BuildingType buildingType;

  @HiveField(5)
  final int newLevel;

  BuildingEntry({
    required this.turn,
    required this.buildingType,
    required this.newLevel,
    this.subtitle,
  }) : category = HistoryEntryCategory.building,
       title = '${_buildingLabel(buildingType)} niv $newLevel';
}

String _buildingLabel(BuildingType type) => switch (type) {
  BuildingType.headquarters => 'Quartier Général',
  BuildingType.algaeFarm => 'Ferme d\'algues',
  BuildingType.coralMine => 'Mine de corail',
  BuildingType.oreExtractor => 'Extracteur de minerai',
  BuildingType.solarPanel => 'Panneau solaire',
  BuildingType.laboratory => 'Laboratoire',
  BuildingType.barracks => 'Caserne',
};
