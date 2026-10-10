part of '../history_entry.dart';

/// History entry recording a combat against a monster lair.
///
/// Carries the full [FightResult] so the combat can be replayed from the
/// history view, plus summarised loot and unit outcomes.
@HiveType(typeId: 24)
class CombatEntry extends HistoryEntry {
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
  final bool victory;

  @HiveField(5)
  final int targetX;

  @HiveField(6)
  final int targetY;

  @HiveField(7)
  final MonsterLair lair;

  @HiveField(8)
  final FightResult fightResult;

  @HiveField(9)
  final Map<ResourceType, int> loot;

  @HiveField(10)
  final Map<UnitType, int> sent;

  @HiveField(11)
  final Map<UnitType, int> survivorsIntact;

  @HiveField(12)
  final Map<UnitType, int> wounded;

  @HiveField(13)
  final Map<UnitType, int> dead;

  CombatEntry({
    required this.turn,
    required this.victory,
    required this.targetX,
    required this.targetY,
    required this.lair,
    required this.fightResult,
    required this.loot,
    required this.sent,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
    this.subtitle,
  }) : category = HistoryEntryCategory.combat,
       title = '';
}
