import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/faction/faction_kernel_war.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/kernel_war_helper.dart';

/// Counts the kernels the faction weighs before it besieges one.
class _Counting extends ArmyPlanner {
  int weighed = 0;

  @override
  bool wins(
    Map<UnitType, int> army,
    List<Combatant> Function() enemy, {
    UnitBoost boost = UnitBoost.none,
    List<Combatant> Function()? allies,
    bool needsAdmiral = false,
  }) {
    weighed++;
    return super.wins(
      army,
      enemy,
      boost: boost,
      allies: allies,
      needsAdmiral: needsAdmiral,
    );
  }
}

/// The owner (the human with [humanHolds]) holds the kernel at [level];
/// the attacker, ready, last besieged it [ago] turns before.
KernelWar _scene(int level, {bool humanHolds = true, int? ago}) {
  final war =
      KernelWar(kernelLevel: level, humanHolds: humanHolds)
        ..game.turn = 40
        ..arm()
        ..garrison(smallGarrison);
  if (ago != null) {
    war.attacker.raidState.kernelAttackTurns[war.owner.id] = 40 - ago;
  }
  return war;
}

FactionTurn _turn(KernelWar war) => FactionTurn(
  game: war.game,
  player: war.attacker,
  executor: ActionExecutor(),
  seeds: Random(2),
);

void main() {
  test('a kernel on cooldown is not even weighed', () {
    for (final bool hot in [true, false]) {
      final war = _scene(hot ? 7 : 3, ago: 3);
      final planner = _Counting();
      final turn = _turn(war);

      expect(
        hot
            ? FactionKernelWar.besiegeHot(turn, planner)
            : FactionKernelWar.besiegeCold(turn, planner),
        isFalse,
      );
      expect(FactionKernelWar.play(turn, planner), isFalse);
      expect(planner.weighed, 0);
      expect(war.kernelOf(war.human), hot ? 7 : 3);
    }
  });

  test('a freshly hot kernel is besieged at once', () {
    final war = _scene(7);

    expect(FactionKernelWar.besiegeHot(_turn(war), _Counting()), isTrue);
    expect(war.kernelOf(war.human), 6);
  });

  test('it is besieged again once the cooldown is over', () {
    final war = _scene(3);

    expect(FactionKernelWar.besiegeCold(_turn(war), _Counting()), isTrue);
    expect(war.attacker.raidState.kernelAttackTurns, {war.human.id: 40});
    expect(war.human.raidState.kernelSiegeLostTurn, 40);
    war.game.turn = 43;
    final held = _Counting();
    expect(FactionKernelWar.besiegeCold(_turn(war), held), isFalse);
    expect(held.weighed, 0);
    war.game.turn = 44;
    expect(FactionKernelWar.besiegeCold(_turn(war), _Counting()), isTrue);
  });

  test('factions between them keep the same cooldown', () {
    final soon = _scene(7, humanHolds: false, ago: 3);
    final late = _scene(7, humanHolds: false, ago: 4);

    expect(FactionKernelWar.besiegeHot(_turn(soon), _Counting()), isFalse);
    expect(FactionKernelWar.besiegeHot(_turn(late), _Counting()), isTrue);
    expect(late.kernelOf(late.owner), 6);
  });
}
