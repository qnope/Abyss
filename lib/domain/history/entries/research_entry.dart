part of '../history_entry.dart';

/// History entry recording a tech branch unlock or a tech research.
@HiveType(typeId: 20)
class ResearchEntry extends HistoryEntry {
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
  final TechBranch branch;

  @HiveField(5)
  final bool isUnlock;

  @HiveField(6)
  final int? newLevel;

  ResearchEntry({
    required this.turn,
    required this.branch,
    required this.isUnlock,
    this.newLevel,
    this.subtitle,
  }) : category = HistoryEntryCategory.research,
       title = '';
}
