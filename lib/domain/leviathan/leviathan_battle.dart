import 'dart:math';

import '../action/attack_base_defence.dart';
import '../action/attack_base_result.dart';
import '../action/base_damage.dart';
import '../action/post_assault_settlement.dart';
import '../faction/faction_attack_report.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/transition_base.dart';
import '../unit/unit_type.dart';
import 'leviathan_force.dart';

/// Fights the guardians that come back to the human's Faille, held by
/// the units of the level it opens onto, without rampart, as against a
/// faction. A lost fight costs the Faille like a post taken
/// ([PostTakeover]), but the guardians hold it again, for anyone to take
/// back with an admiral.
abstract final class LeviathanBattle {
  /// Fights at the end of [turn]; the report is also kept in the human's
  /// history, so the end of the turn and a replay report the same fight.
  static FactionAttackReport fight(
    Game game,
    TransitionBase post, {
    required int turn,
    Random? random,
  }) {
    final Player human = game.humanPlayer;
    final BaseDefence defence = BaseDefence.post(human, post.targetLevel);
    final FightResult fight = FightEngine(
      random: random,
    ).resolve(playerSide: LeviathanForce.of(game), monsterSide: defence.side);
    final DefenceOutcome outcome = defence.settle(human, random: random);
    final BaseAssaultEntry entry = PostAssaultSettlement.settle(
      turn: turn,
      post: post,
      attacker: null,
      attackerName: LeviathanForce.attackerName,
      owner: human,
      result: AttackBaseResult.success(
        victory: fight.isVictory,
        fight: fight,
        sent: const <UnitType, int>{},
        survivorsIntact: const <UnitType, int>{},
        wounded: const <UnitType, int>{},
        dead: const <UnitType, int>{},
        defence: outcome,
        damage: BaseDamage.none(human),
      ),
    );
    return FactionAttackReport(
      attackerId: LeviathanForce.attackerName,
      attackerName: LeviathanForce.attackerName,
      personality: null,
      entry: entry,
    );
  }
}
