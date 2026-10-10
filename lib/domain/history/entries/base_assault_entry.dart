part of '../history_entry.dart';

/// History entry recording an attack on a player's base, written for the
/// attacker and for the [defending] player alike: each one reads the same
/// fight from its own side.
///
/// [victory] is the attacker's. [units] are those of the entry's owner:
/// the army sent, or the defenders (the base's units) it fielded.
@HiveType(typeId: 57)
class BaseAssaultEntry extends HistoryEntry {
  @HiveField(0)
  @override
  final int turn;

  @HiveField(1)
  @override
  final HistoryEntryCategory category;

  @HiveField(2)
  final bool victory;

  /// Whether the owner of the entry was the one attacked.
  @HiveField(3)
  final bool defending;

  /// Name of the other player.
  @HiveField(4)
  final String opponentName;

  @HiveField(5)
  final FightResult fightResult;

  @HiveField(6)
  final Map<UnitType, int> units;

  @HiveField(7)
  final Map<UnitType, int> survivorsIntact;

  @HiveField(8)
  final Map<UnitType, int> wounded;

  @HiveField(9)
  final Map<UnitType, int> dead;

  @HiveField(10)
  final int rampartBefore;

  @HiveField(11)
  final int rampartAfter;

  @HiveField(12)
  final int headquartersBefore;

  @HiveField(13)
  final int headquartersAfter;

  /// Taken from the defender's stocks.
  @HiveField(14)
  final Map<ResourceType, int> pillaged;

  /// What the attacker's storage could hold of [pillaged].
  @HiveField(15)
  final Map<ResourceType, int> loot;

  /// Code of the Faille or Cheminée attacked, `null` for an attack on a
  /// base.
  @HiveField(16)
  final String? postName;

  BaseAssaultEntry({
    required this.turn,
    required this.victory,
    required this.defending,
    required this.opponentName,
    required this.fightResult,
    required this.units,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
    required this.rampartBefore,
    required this.rampartAfter,
    required this.headquartersBefore,
    required this.headquartersAfter,
    required this.pillaged,
    required this.loot,
    this.postName,
  }) : category = HistoryEntryCategory.assault;
}
