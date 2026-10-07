part of '../history_entry.dart';

/// History entry recording a raid on the base.
///
/// Carries the full [FightResult] so the raid can be replayed from the
/// history view, plus the wave, the defenders' fate and the resources won
/// or pillaged.
@HiveType(typeId: 39)
class RaidEntry extends HistoryEntry {
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
  final MonsterLair wave;

  @HiveField(6)
  final FightResult fightResult;

  @HiveField(7)
  final Map<ResourceType, int> loot;

  @HiveField(8)
  final Map<ResourceType, int> pillaged;

  @HiveField(9)
  final Map<UnitType, int> defenders;

  @HiveField(10)
  final Map<UnitType, int> survivorsIntact;

  @HiveField(11)
  final Map<UnitType, int> wounded;

  @HiveField(12)
  final Map<UnitType, int> dead;

  @HiveField(13)
  final int rampartLevel;

  RaidEntry({
    required this.turn,
    required this.victory,
    required this.wave,
    required this.fightResult,
    required this.loot,
    required this.pillaged,
    required this.defenders,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
    required this.rampartLevel,
    this.subtitle,
  }) : category = HistoryEntryCategory.raid,
       title = victory ? 'Raid repoussé' : 'Base pillée par un raid';
}
