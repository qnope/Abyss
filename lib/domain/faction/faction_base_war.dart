import '../action/announce_attack_action.dart';
import '../action/attack_base_action.dart';
import '../action/attack_base_defence.dart';
import '../action/fight_monster_helpers.dart';
import '../fight/army_planner.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/unit_boost.dart';
import '../game/player.dart';
import '../raid/raid_battle.dart';
import '../script/script_turn.dart';
import '../unit/unit_type.dart';
import 'faction_base_targets.dart';
import 'faction_war.dart';

/// A faction that attacks the weakest base it knows and would beat in
/// [ArmyPlanner.confidence] of its rehearsals: another faction at once,
/// the human at the end of the turn, without warning.
abstract final class FactionBaseWar {
  /// Quarters of the army sent to war: the fewest that still win, so that
  /// a faction does not throw its whole army at a weak base.
  static const int quarters = 4;

  /// Attacks the weakest beatable base; returns whether it attacked. On a
  /// [grudge] slot the human comes first, and a human it cannot beat is
  /// skipped rather than ending the search.
  static bool play(
    ScriptTurn turn,
    ArmyPlanner planner, {
    required bool grudge,
  }) {
    final Player me = turn.player;
    final Map<UnitType, int> army = FactionWar.fightersOn(
      me,
      RaidBattle.baseLevel,
    );
    if (army.isEmpty) return false;
    final UnitBoost boost = FightMonsterHelpers.unitBoostOf(
      me,
      attacking: true,
    );
    final List<Combatant> ours = CombatantBuilder.playerCombatantsFrom(
      army,
      boost: boost,
    );
    for (final BaseTarget t in FactionBaseTargets.weakestFirst(
      turn,
      ours,
      grudge: grudge,
    )) {
      if (!planner.wins(
        army,
        () => BaseDefence.fromIntel(t.intel).side,
        boost: boost,
      )) {
        if (grudge && FactionBaseTargets.isHuman(turn, t.player)) continue;
        return false;
      }
      final Map<UnitType, int> sent = _smallestWinning(army, planner, boost, t);
      if (_strike(turn, t.player, sent)) return true;
    }
    return false;
  }

  static Map<UnitType, int> _smallestWinning(
    Map<UnitType, int> army,
    ArmyPlanner planner,
    UnitBoost boost,
    BaseTarget target,
  ) {
    Map<UnitType, int> part(int k) => <UnitType, int>{
      for (final MapEntry<UnitType, int> e in army.entries)
        e.key: (e.value * k / quarters).ceil(),
    };
    for (int k = 1; k < quarters; k++) {
      if (planner.wins(
        part(k),
        () => BaseDefence.fromIntel(target.intel).side,
        boost: boost,
      )) {
        return part(k);
      }
    }
    return army;
  }

  static bool _strike(ScriptTurn turn, Player target, Map<UnitType, int> army) {
    if (target.id == turn.game.humanPlayerId) {
      return turn.tryPerform(
        AnnounceAttackAction(selectedUnits: army, random: turn.random),
      );
    }
    return turn.tryPerform(
      AttackBaseAction(
        targetPlayerId: target.id,
        selectedUnits: army,
        random: turn.random,
      ),
    );
  }
}
