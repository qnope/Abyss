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

  @HiveField(2)
  @override
  final String title;

  @HiveField(3)
  @override
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
       title = 'Tour $turn terminé';
}
