part of '../history_entry.dart';

/// History entry recording the resolution of a turn.
///
/// Carries the per-resource production recap, the list of buildings that
/// were deactivated due to missing upkeep, and any units lost to starvation.
@HiveType(typeId: 25)
class TurnEndEntry extends HistoryEntry {
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
  final List<TurnResourceChange> changes;

  @HiveField(5)
  final List<BuildingType> deactivatedBuildings;

  @HiveField(6)
  final Map<UnitType, int> lostUnits;

  TurnEndEntry({
    required this.turn,
    required this.changes,
    required this.deactivatedBuildings,
    required this.lostUnits,
    this.subtitle,
  }) : category = HistoryEntryCategory.turnEnd,
       title = '';
}
