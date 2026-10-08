import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/action/attack_volcanic_kernel_action.dart';
import 'package:abyss/domain/action/explore_action.dart';
import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/recruit_unit_action.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tech_helpers.dart';
import '../action/fight_monster_action_helper.dart';

void _silence(Player player, {TechOption option = TechOption.b}) =>
    player.techBranches[TechBranch.explorer] =
        researchedBranch(TechBranch.explorer, 2, options: [option]);

void main() {
  const units = {UnitType.harpoonist: 1};
  final fights = [
    FightMonsterAction(
        targetX: 1, targetY: 1, level: 1, selectedUnits: units),
    AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1, selectedUnits: units),
    AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 1, selectedUnits: units),
  ];

  group('Nage silencieuse', () {
    test('exploring and fighting make no noise', () {
      final player = buildFightTestPlayer();
      _silence(player);

      expect(ExploreAction(targetX: 1, targetY: 1).noiseMade(player), 0);
      for (final fight in fights) {
        expect(fight.noiseMade(player), 0, reason: '${fight.runtimeType}');
      }
    });

    test('without it they keep their noise', () {
      final player = buildFightTestPlayer();
      _silence(player, option: TechOption.a);

      expect(ExploreAction(targetX: 1, targetY: 1).noiseMade(player),
          NoiseRules.perExploration);
      for (final fight in fights) {
        expect(fight.noiseMade(player), NoiseRules.perFight);
      }
    });

    test('recruiting stays noisy', () {
      final player = buildFightTestPlayer();
      _silence(player);
      expect(
        RecruitUnitAction(unitType: UnitType.scout, quantity: 3)
            .noiseMade(player),
        3,
      );
    });

    test('a real fight leaves the gauge untouched', () {
      final scenario = createFightScenario(stock: units);
      _silence(scenario.player);
      final result = ActionExecutor().execute(
        FightMonsterAction(targetX: 1, targetY: 1, level: 1,
            selectedUnits: units, random: Random(0)),
        scenario.game,
        scenario.player,
      );

      expect(result.isSuccess, isTrue);
      expect(scenario.player.raidState.noise, 0);
    });
  });
}
