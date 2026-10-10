import '../../action/announce_attack_action.dart';
import '../../action/attack_base_action.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';

/// Moves against the base of another player.
extension AssaultMoves on ScriptTurn {
  /// Sends [army] of the base level against the base of player
  /// [targetId]; returns whether the attack was made. The caller picks a
  /// target it knows and an army worth sending.
  bool attackBase(String targetId, Map<UnitType, int> army) => tryPerform(
    AttackBaseAction(
      targetPlayerId: targetId,
      selectedUnits: army,
      random: random,
    ),
  );

  /// Announces an attack with [army] on the human player, two turns
  /// ahead; returns whether it was announced. Only another player than the
  /// human can announce.
  bool announceAttack(Map<UnitType, int> army) => tryPerform(
    AnnounceAttackAction(selectedUnits: army, random: random),
  );
}
