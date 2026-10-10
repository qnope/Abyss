part of '../history_entry.dart';

/// History entry recording a reinforcement dispatch to a deeper level.
@HiveType(typeId: 36)
class ReinforcementEntry extends HistoryEntry {
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
  final int targetLevel;

  @HiveField(5)
  final int unitCount;

  ReinforcementEntry({
    required this.turn,
    required this.targetLevel,
    required this.unitCount,
    this.subtitle,
  }) : category = HistoryEntryCategory.reinforcement,
       title = '';
}
