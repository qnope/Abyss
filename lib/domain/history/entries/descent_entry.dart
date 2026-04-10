part of '../history_entry.dart';

/// History entry recording a descent to a deeper level.
@HiveType(typeId: 35)
class DescentEntry extends HistoryEntry {
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
  final int targetLevel;

  @HiveField(5)
  final int unitCount;

  DescentEntry({
    required this.turn,
    required this.targetLevel,
    required this.unitCount,
    this.subtitle,
  }) : category = HistoryEntryCategory.descent,
       title = 'Descente au Niveau $targetLevel';
}
