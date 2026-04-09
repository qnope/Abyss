part of '../history_entry.dart';

/// History entry recording an exploration order at a grid coordinate.
@HiveType(typeId: 22)
class ExploreEntry extends HistoryEntry {
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

  ExploreEntry({
    required this.turn,
    required this.targetX,
    required this.targetY,
    this.subtitle,
  }) : category = HistoryEntryCategory.explore,
       title = 'Exploration ($targetX, $targetY)';
}
