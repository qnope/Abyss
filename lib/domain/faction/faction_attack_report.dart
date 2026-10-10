import '../history/history_entry.dart';
import 'faction_personality.dart';

/// How an attack on the human base ended, from the human's side.
enum AttackOutcome { repelled, damaged, pillaged }

/// An attack of a player on the human base, fought at the end of a turn:
/// who attacked and the human's own report of the fight.
class FactionAttackReport {
  final String attackerId;
  final String attackerName;

  /// `null` when the attacker is not one of the game's factions.
  final FactionPersonality? personality;

  /// The report of the defender, readable on the assault screen.
  final BaseAssaultEntry entry;

  const FactionAttackReport({
    required this.attackerId,
    required this.attackerName,
    required this.personality,
    required this.entry,
  });

  /// Repelled, or a base razed that lost part of its stocks or not.
  AttackOutcome get outcome {
    if (!entry.victory) return AttackOutcome.repelled;
    return entry.pillaged.values.any((int n) => n > 0)
        ? AttackOutcome.pillaged
        : AttackOutcome.damaged;
  }
}
