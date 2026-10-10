import 'dart:math';

import '../action/action.dart';
import '../action/announce_attack_action.dart';
import '../action/attack_base_action.dart';
import '../action/attack_transition_base_action.dart';
import '../action/attack_volcanic_kernel_action.dart';
import '../action/choose_event_action.dart';
import '../action/collect_treasure_action.dart';
import '../action/descend_action.dart';
import '../action/explore_action.dart';
import '../action/fight_monster_action.dart';
import '../action/recruit_unit_action.dart';
import '../action/research_tech_action.dart';
import '../action/garrison_kernel_action.dart';
import '../action/send_reinforcements_action.dart';
import '../action/unlock_branch_action.dart';
import '../action/upgrade_building_action.dart';
import '../tech/tech_option.dart';
import '../unit/unit_type.dart';
import 'seeded_random.dart';

/// Writes a player action in the JSON scenario format `ActionCodec`
/// reads, such as `{"do": "recruit", "unit": "guardian", "count": 5}`.
///
/// An action that rolls dice also carries the `seed` of its generator
/// when it is a [SeededRandom], so that a replay rolls the same dice.
abstract final class ActionEncoder {
  /// `null` for an action that is not a player move (ending the turn).
  /// An attack on [humanId] names its target `human`, whose id changes
  /// from one game to the next.
  static Map<String, Object?>? encode(Action action, {String? humanId}) {
    return switch (action) {
      UpgradeBuildingAction a => {
        'do': 'upgrade',
        'building': a.buildingType.name,
      },
      UnlockBranchAction a => {'do': 'unlock', 'branch': a.branch.name},
      ResearchTechAction a => {
        'do': 'research',
        'branch': a.branch.name,
        if (a.option != TechOption.a) 'option': a.option.name,
      },
      RecruitUnitAction a => {
        'do': 'recruit',
        'unit': a.unitType.name,
        'count': a.quantity,
      },
      ExploreAction a => _at('explore', a.targetX, a.targetY, a.level),
      CollectTreasureAction a => _at(
        'collect',
        a.targetX,
        a.targetY,
        a.level,
        random: a.random,
      ),
      FightMonsterAction a => _at(
        'fight',
        a.targetX,
        a.targetY,
        a.level,
        units: a.selectedUnits,
        random: a.random,
      ),
      AttackTransitionBaseAction a => _at(
        'attackBase',
        a.targetX,
        a.targetY,
        a.level,
        units: a.selectedUnits,
        random: a.random,
      ),
      AttackBaseAction a => {
        'do': 'attackPlayer',
        'target': a.targetPlayerId == humanId
            ? AttackBaseAction.human
            : a.targetPlayerId,
        'units': _unitsOf(a.selectedUnits),
        if (a.random is SeededRandom) 'seed': (a.random! as SeededRandom).seed,
      },
      AnnounceAttackAction a => {
        'do': 'announceAttack',
        'units': _unitsOf(a.selectedUnits),
        if (a.random is SeededRandom) 'seed': (a.random! as SeededRandom).seed,
      },
      AttackVolcanicKernelAction a => _at(
        'attackKernel',
        a.targetX,
        a.targetY,
        a.level,
        units: a.selectedUnits,
        random: a.random,
      ),
      DescendAction a => _at(
        'descend',
        a.transitionX,
        a.transitionY,
        a.fromLevel,
        units: a.selectedUnits,
        random: a.random,
      ),
      SendReinforcementsAction a => _at(
        'reinforce',
        a.transitionX,
        a.transitionY,
        a.fromLevel,
        units: a.selectedUnits,
      ),
      GarrisonKernelAction a => {
        'do': a.withdraw ? 'withdraw' : 'garrison',
        'units': _unitsOf(a.selectedUnits),
      },
      ChooseEventAction a => {'do': 'event', 'accept': a.accept},
      _ => null,
    };
  }

  static Map<String, int> _unitsOf(Map<UnitType, int> units) =>
      <String, int>{
        for (final MapEntry<UnitType, int> e in units.entries)
          if (e.value > 0) e.key.name: e.value,
      };

  /// Whether replaying [action] rolls the same dice as playing it did.
  static bool isExact(Action action) => switch (action) {
    CollectTreasureAction a => a.random is SeededRandom,
    FightMonsterAction a => a.random is SeededRandom,
    AttackTransitionBaseAction a => a.random is SeededRandom,
    AttackBaseAction a => a.random is SeededRandom,
    AnnounceAttackAction a => a.random is SeededRandom,
    AttackVolcanicKernelAction a => a.random is SeededRandom,
    DescendAction a => a.random is SeededRandom,
    _ => true,
  };

  static Map<String, Object?> _at(
    String verb,
    int x,
    int y,
    int level, {
    Map<UnitType, int>? units,
    Random? random,
  }) {
    return <String, Object?>{
      'do': verb,
      'x': x,
      'y': y,
      if (level != 1) 'level': level,
      if (units != null) 'units': _unitsOf(units),
      if (random is SeededRandom) 'seed': random.seed,
    };
  }
}
