part of '../history_entry.dart';

/// History entry recording a treasure collection at a grid coordinate.
@HiveType(typeId: 23)
class CollectEntry extends HistoryEntry {
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
  final int targetX;

  @HiveField(5)
  final int targetY;

  @HiveField(6)
  final Map<ResourceType, int> gains;

  CollectEntry({
    required this.turn,
    required this.targetX,
    required this.targetY,
    required this.gains,
    this.subtitle,
  }) : category = HistoryEntryCategory.collect,
       title = '';
}
