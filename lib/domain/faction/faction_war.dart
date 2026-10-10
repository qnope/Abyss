import '../action/announce_attack_action.dart';
import '../action/attack_base_action.dart';
import '../action/attack_base_defence.dart';
import '../action/fight_monster_helpers.dart';
import '../fight/army_planner.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/unit_boost.dart';
import '../game/player.dart';
import '../map/grid_position.dart';
import '../raid/raid_battle.dart';
import '../script/script_turn.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import 'faction_personality.dart';

/// When and whom a faction attacks. One conservative rule that every
/// personality shares until its own war brain exists (step 11).
///
/// Once in a while, on a slot of its own, a faction looks at the bases its
/// fog has shown. If its fighters would beat the defence of the weakest of
/// them in at least [planner]'s confidence of its rehearsals, it attacks:
/// another faction at once, the human with an announcement two turns
/// ahead. It never has two attacks of its own pending.
///
/// The defence is read from the target itself, for want of spies (step
/// 10): a base whose army changed in the meantime can still surprise the
/// attacker.
abstract final class FactionWar {
  /// Turns between two slots of a faction.
  static const int cadence = 6;

  /// Rehearses the fight before committing: 85 % of 8 rehearsals won.
  static const ArmyPlanner planner = ArmyPlanner();

  /// Units that never leave: they do not fight in a base war.
  static const Set<UnitType> _stayHome = <UnitType>{
    UnitType.scout,
    UnitType.abyssAdmiral,
  };

  /// Whether the faction of [personality] may attack on [turn]; the
  /// personalities are spread over the cadence so they do not all strike
  /// at once.
  static bool isDue(int turn, FactionPersonality personality) =>
      (turn + personality.index) % cadence == 0;

  static void play(ScriptTurn turn, FactionPersonality personality) {
    if (!isDue(turn.number, personality)) return;
    final Player me = turn.player;
    if (turn.game.humanPlayer.raidState.hasAttackFrom(me.id)) return;
    final Map<UnitType, int> army = _fighters(me);
    if (army.isEmpty) return;
    final UnitBoost boost = FightMonsterHelpers.unitBoostOf(
      me,
      attacking: true,
    );
    final List<Combatant> ours = CombatantBuilder.playerCombatantsFrom(
      army,
      boost: boost,
    );
    for (final _Target t in _weakestFirst(turn, ours)) {
      if (!planner.wins(
        army,
        () => BaseDefence.of(t.player).side,
        boost: boost,
      )) {
        return;
      }
      if (_strike(turn, t.player, army)) return;
    }
  }

  static Map<UnitType, int> _fighters(Player me) => <UnitType, int>{
    for (final MapEntry<UnitType, Unit> e
        in me.unitsOnLevel(RaidBattle.baseLevel).entries)
      if (!_stayHome.contains(e.key) && e.value.count > 0) e.key: e.value.count,
  };

  /// The bases of the fog of [turn]'s player, the weakest defence first.
  static List<_Target> _weakestFirst(ScriptTurn turn, List<Combatant> ours) {
    final Set<GridPosition> seen =
        turn.player.revealedCellsOnLevel(RaidBattle.baseLevel).toSet();
    final List<_Target> targets = <_Target>[
      for (final Player p in turn.game.players.values)
        if (p.id != turn.player.id &&
            !p.hasFallen &&
            seen.contains(GridPosition(x: p.baseX, y: p.baseY)))
          _Target(p, ours),
    ];
    targets.sort((a, b) {
      final int byStrength = a.strength.compareTo(b.strength);
      return byStrength != 0 ? byStrength : a.player.id.compareTo(b.player.id);
    });
    return targets;
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

class _Target {
  final Player player;

  /// How hard the defence hits back at the attacking army.
  final double strength;

  _Target(this.player, List<Combatant> ours)
    : strength = ArmyPlanner.strength(BaseDefence.of(player).side, ours);
}
