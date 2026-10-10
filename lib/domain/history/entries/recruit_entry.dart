part of '../history_entry.dart';

/// History entry recording the recruitment of a batch of units.
@HiveType(typeId: 21)
class RecruitEntry extends HistoryEntry {
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
  final UnitType unitType;

  @HiveField(5)
  final int quantity;

  RecruitEntry({
    required this.turn,
    required this.unitType,
    required this.quantity,
    this.subtitle,
  }) : category = HistoryEntryCategory.recruit,
       title = '';
}
