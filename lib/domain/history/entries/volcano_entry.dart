part of '../history_entry.dart';

/// History entry recording a kraken wave on the volcanic kernel.
///
/// Carries the full [FightResult] so the wave can be replayed from the
/// history view, plus the garrison's fate and the kernel level it held.
@HiveType(typeId: 48)
class VolcanoEntry extends HistoryEntry {
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
  final MonsterLair wave;

  @HiveField(6)
  final FightResult fightResult;

  @HiveField(7)
  final int kernelLevel;

  @HiveField(8)
  final Map<UnitType, int> defenders;

  @HiveField(9)
  final Map<UnitType, int> survivorsIntact;

  @HiveField(10)
  final Map<UnitType, int> wounded;

  @HiveField(11)
  final Map<UnitType, int> dead;

  VolcanoEntry({
    required this.turn,
    required this.victory,
    required this.wave,
    required this.fightResult,
    required this.kernelLevel,
    required this.defenders,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
    this.subtitle,
  }) : category = HistoryEntryCategory.volcano,
       title = '';
}
