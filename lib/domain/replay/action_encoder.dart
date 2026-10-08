import 'dart:math';

import '../action/action.dart';
import '../action/attack_transition_base_action.dart';
import '../action/attack_volcanic_kernel_action.dart';
import '../action/collect_treasure_action.dart';
import '../action/descend_action.dart';
import '../action/explore_action.dart';
import '../action/fight_monster_action.dart';
import '../action/recruit_unit_action.dart';
import '../action/research_tech_action.dart';
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
  static Map<String, Object?>? encode(Action action) {
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
      _ => null,
    };
  }

  /// Whether replaying [action] rolls the same dice as playing it did.
  static bool isExact(Action action) => switch (action) {
    CollectTreasureAction a => a.random is SeededRandom,
    FightMonsterAction a => a.random is SeededRandom,
    AttackTransitionBaseAction a => a.random is SeededRandom,
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
      if (units != null)
        'units': <String, int>{
          for (final MapEntry<UnitType, int> e in units.entries)
            if (e.value > 0) e.key.name: e.value,
        },
      if (random is SeededRandom) 'seed': random.seed,
    };
  }
}
