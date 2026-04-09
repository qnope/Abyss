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

  @HiveField(2)
  @override
  final String title;

  @HiveField(3)
  @override
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
       title = _buildCombatTitle(victory, lair.level);
}

String _buildCombatTitle(bool victory, int lairLevel) {
  final outcome = victory ? 'Victoire' : 'Défaite';
  return '$outcome vs Tanière niv $lairLevel';
}
