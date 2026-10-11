import 'dart:math';

import '../action/announce_attack_action.dart';
import '../action/attack_base_action.dart';
import '../action/attack_base_defence.dart';
import '../action/fight_monster_helpers.dart';
import '../action/recruit_unit_action.dart';
import '../fight/army_planner.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/unit_boost.dart';
import '../game/player.dart';
import '../map/grid_position.dart';
import '../raid/raid_battle.dart';
import '../script/script_turn.dart';
import '../script/strategies/assault_moves.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import 'faction_personality.dart';
import 'base_intel.dart';
import 'faction_kernel_war.dart';
import 'faction_post_war.dart';
import 'faction_traits.dart';

/// When and whom a faction attacks. One conservative rule that every
/// personality shares until its own war brain exists (step 11).
///
/// Once in a while, on a slot of its own, a faction looks at the bases its
/// fog has shown. If its fighters would beat the defence of the weakest of
/// them in at least [planner]'s confidence of its rehearsals, it attacks:
/// another faction at once, the human with an announcement two turns
/// ahead. It never has two attacks of its own pending.
///
/// When no base is worth attacking it looks at the posts of the others
/// ([FactionPostWar]).
///
/// The defence is read from the target itself, for want of spies (step
/// 10): a base whose army changed in the meantime can still surprise the
/// attacker.
abstract final class FactionWar {
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
      (turn + personality.index) % FactionTraits.of(personality).cadence == 0;

  /// Bases a faction sends a Scout to in one slot.
  static const int spiesPerSlot = 2;

  static int _distance(Player a, Player b) =>
      max((a.baseX - b.baseX).abs(), (a.baseY - b.baseY).abs());

  static void play(ScriptTurn turn, FactionPersonality personality) {
    if (!isDue(turn.number, personality)) return;
    if (turn.game.humanPlayer.raidState.hasAttackFrom(turn.player.id)) return;
    _keepAScout(turn.player, turn);
    final FactionTraits traits = FactionTraits.of(personality);
    final ArmyPlanner planner = traits.planner;
    if (traits.kernelFirst && FactionKernelWar.play(turn, planner)) return;
    final bool attacked =
        traits.postsFirst
            ? FactionPostWar.play(turn, planner) || _raidBases(turn, planner)
            : _raidBases(turn, planner) || FactionPostWar.play(turn, planner);
    if (!attacked && !traits.kernelFirst) FactionKernelWar.play(turn, planner);
  }

  /// A faction spies before it strikes: it keeps a Scout at home for the
  /// slot, whatever the exploration left.
  static void _keepAScout(Player me, ScriptTurn turn) {
    final int scouts =
        me.unitsOnLevel(RaidBattle.baseLevel)[UnitType.scout]?.count ?? 0;
    if (scouts > 0) return;
    turn.tryPerform(RecruitUnitAction(unitType: UnitType.scout, quantity: 1));
  }

  /// Attacks the weakest beatable base; returns whether it attacked.
  static bool _raidBases(ScriptTurn turn, ArmyPlanner planner) {
    final Player me = turn.player;
    final Map<UnitType, int> army = fightersOn(me, RaidBattle.baseLevel);
    if (army.isEmpty) return false;
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
        () => BaseDefence.fromIntel(t.intel).side,
        boost: boost,
      )) {
        return false;
      }
      if (_strike(turn, t.player, army)) return true;
    }
    return false;
  }

  /// The units of [level] that [me] sends to war.
  static Map<UnitType, int> fightersOn(Player me, int level) => <UnitType, int>{
    for (final MapEntry<UnitType, Unit> e in me.unitsOnLevel(level).entries)
      if (!_stayHome.contains(e.key) && e.value.count > 0) e.key: e.value.count,
  };

  /// The bases of the fog of [turn]'s player that a scout has reported on
  /// (a fresh report, or the one a Scout brings back now), the weakest
  /// defence first. It spies at most [spiesPerSlot] bases a slot, the
  /// nearest first.
  static List<_Target> _weakestFirst(ScriptTurn turn, List<Combatant> ours) {
    final Player me = turn.player;
    final Set<GridPosition> seen =
        me.revealedCellsOnLevel(RaidBattle.baseLevel).toSet();
    final List<Player> known = <Player>[
      for (final Player p in turn.game.players.values)
        if (p.id != me.id &&
            !p.hasFallen &&
            seen.contains(GridPosition(x: p.baseX, y: p.baseY)))
          p,
    ]..sort((a, b) => _distance(me, a).compareTo(_distance(me, b)));
    final List<_Target> targets = <_Target>[];
    int spies = 0;
    for (final Player p in known) {
      BaseIntel? intel = me.intel[p.id];
      if (intel == null || !intel.isFresh(turn.number)) {
        if (spies >= spiesPerSlot || !turn.spyOn(p.id)) continue;
        spies++;
        intel = me.intel[p.id];
      }
      targets.add(_Target(p, intel!, ours));
    }
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

  /// What the scouts reported of the base.
  final BaseIntel intel;

  /// How hard the defence the report shows hits back at the army.
  final double strength;

  _Target(this.player, this.intel, List<Combatant> ours)
    : strength = ArmyPlanner.strength(BaseDefence.fromIntel(intel).side, ours);
}
