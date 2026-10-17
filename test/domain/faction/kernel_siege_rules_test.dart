import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/attack_base_defence.dart';
import 'package:abyss/domain/action/attack_held_kernel_action.dart';
import 'package:abyss/domain/action/fight_monster_helpers.dart';
import 'package:abyss/domain/faction/faction_kernel_war.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/faction/kernel_siege.dart';
import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/kernel_war_helper.dart';

bool _besiege(KernelWar war, [ArmyPlanner planner = const ArmyPlanner()]) =>
    FactionKernelWar.besiegeHot(
      FactionTurn(
        game: war.game,
        player: war.attacker,
        executor: ActionExecutor(),
        seeds: Random(2),
      ),
      planner,
    );

/// The human wins a siege of the owner's kernel this turn.
void _humanWins(KernelWar war) {
  war.put(war.human, 3, horde);
  final AttackHeldKernelAction strike = war.strike(horde);
  ActionExecutor().execute(strike, war.game, war.human);
}

int _won(KernelWar war) =>
    war.owner.historyEntries
        .whereType<BaseAssaultEntry>()
        .where((e) => e.defending && e.victory)
        .length;

void main() {
  test('the planner gives up 0.125 of confidence from level 8', () {
    const ArmyPlanner base = ArmyPlanner(confidence: 0.85);
    expect(KernelSiege.plannerFor(base, 7).confidence, 0.85);
    expect(KernelSiege.plannerFor(base, 8).confidence, closeTo(0.725, 1e-9));
    expect(KernelSiege.plannerFor(base, 9).rehearsals, base.rehearsals);
    const ArmyPlanner bold = ArmyPlanner(confidence: 0.7);
    expect(KernelSiege.plannerFor(bold, 9).confidence, 0.625);
  });

  test('at level 8 it accepts a siege won 6 times out of 8', () {
    final war = KernelWar(kernelLevel: 8)..garrison({UnitType.harpoonist: 40});
    final boost = FightMonsterHelpers.unitBoostOf(
      war.attacker,
      attacking: true,
    );
    const ArmyPlanner planner = ArmyPlanner();
    final int n = [for (var n = 1; n <= 120; n++) n].firstWhere((n) {
      final rate = planner.winRate(
        {UnitType.harpoonist: n},
        () => BaseDefence.kernel(war.owner).side,
        boost: boost,
      );
      return rate >= 0.725 && rate < 0.85;
    });
    war.arm({UnitType.harpoonist: n});

    expect(_besiege(war, planner), isTrue);
    expect(war.kernelOf(war.owner), 7);
  });

  test('on easy, one won siege a turn per holder', () {
    final war =
        KernelWar(kernelLevel: 9)
          ..arm()
          ..garrison(smallGarrison)
          ..game.savedDifficulty = Difficulty.easy;
    _humanWins(war);
    expect(_won(war), 1);

    expect(_besiege(war), isFalse);
    expect(war.kernelOf(war.owner), 8);
  });

  test('on normal and hard, two won sieges a turn per holder', () {
    for (final d in [Difficulty.normal, Difficulty.hard]) {
      final war =
          KernelWar(kernelLevel: 9)
            ..arm()
            ..garrison(smallGarrison)
            ..game.savedDifficulty = d;
      _humanWins(war);
      expect(KernelSiege.isCapped(war.game, war.owner), isFalse);

      expect(_besiege(war), isTrue);
      expect(war.kernelOf(war.owner), 7);
      expect(KernelSiege.isCapped(war.game, war.owner), isTrue);
    }
    expect(KernelSiege.wonPerTurn(Difficulty.easy), 1);
    expect(KernelSiege.wonPerTurn(Difficulty.normal), 2);
  });

  test('a siege won on an earlier turn does not count', () {
    final war =
        KernelWar(kernelLevel: 9)
          ..arm()
          ..garrison(smallGarrison)
          ..game.savedDifficulty = Difficulty.easy;
    _humanWins(war);
    war.game.turn++;

    expect(_besiege(war), isTrue);
  });

  test('it never besieges the kernel it holds itself', () {
    final war = KernelWar(kernelLevel: 7)..arm();
    final map = war.game.levels[3]!;
    map.setCell(
      war.at.x,
      war.at.y,
      map.cellAt(war.at.x, war.at.y).copyWith(collectedBy: war.attacker.id),
    );

    expect(_besiege(war), isFalse);
    expect(war.attacker.historyEntries.whereType<BaseAssaultEntry>(), isEmpty);
  });
}
