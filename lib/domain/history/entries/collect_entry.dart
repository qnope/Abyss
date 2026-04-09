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

  @HiveField(2)
  @override
  final String title;

  @HiveField(3)
  @override
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
       title = 'Trésor collecté ($targetX, $targetY)';
}
