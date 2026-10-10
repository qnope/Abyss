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

  /// Left empty: the presentation titles the entry in the player's
  /// language. Kept so the Hive layout keeps its field 2.
  @HiveField(2)
  final String title;

  /// Not shown: a French line some older versions saved.
  @HiveField(3)
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
       title = '';
}
