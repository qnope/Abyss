import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/faction/faction_kernel_war.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/fight/army_planner.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/raid/raid_state.dart';
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
/// [mark] dates its gap from the turn and the kernel gap; the attacker
/// stands ready.
KernelWar _scene(
  int level, {
  bool humanHolds = true,
  required void Function(RaidState, int turn, int gap) mark,
}) {
  final war =
      KernelWar(kernelLevel: level, humanHolds: humanHolds)
        ..game.turn = 40
        ..arm()
        ..garrison(smallGarrison);
  mark(war.owner.raidState, war.game.turn, war.game.difficulty.kernelGap);
  return war;
}

FactionTurn _turn(KernelWar war) => FactionTurn(
  game: war.game,
  player: war.attacker,
  executor: ActionExecutor(),
  seeds: Random(2),
);

void main() {
  test('a kernel of the human just turned hot is not even weighed', () {
    final war = _scene(7, mark: (s, t, gap) => s.kernelHotTurn = t - gap + 1);
    final planner = _Counting();

    expect(FactionKernelWar.besiegeHot(_turn(war), planner), isFalse);
    expect(planner.weighed, 0);
    expect(war.kernelOf(war.human), 7);
  });

  test('it is besieged once kernelGap turns have passed', () {
    final war = _scene(7, mark: (s, t, gap) => s.kernelHotTurn = t - gap);

    expect(FactionKernelWar.besiegeHot(_turn(war), _Counting()), isTrue);
    expect(war.kernelOf(war.human), 6);
  });

  test('a siege the human just lost holds back the next one', () {
    final war = _scene(
      3,
      mark: (s, t, gap) => s.kernelSiegeLostTurn = t - gap + 1,
    );
    final planner = _Counting();

    expect(FactionKernelWar.besiegeCold(_turn(war), planner), isFalse);
    expect(planner.weighed, 0);
    expect(war.kernelOf(war.human), 3);
  });

  test('a won siege of the human dates the gap', () {
    final war = _scene(3, mark: (s, t, gap) {});

    expect(FactionKernelWar.besiegeCold(_turn(war), _Counting()), isTrue);
    expect(war.human.raidState.kernelSiegeLostTurn, 40);
    final held = _Counting();
    expect(FactionKernelWar.besiegeCold(_turn(war), held), isFalse);
    expect(held.weighed, 0);
    war.human.raidState.kernelSiegeLostTurn = null;
    final free = _Counting();
    FactionKernelWar.besiegeCold(_turn(war), free);
    expect(free.weighed, greaterThan(0), reason: 'only the gap held it');
  });

  test('factions besiege each other with no gap', () {
    final war = _scene(
      7,
      humanHolds: false,
      mark:
          (s, t, gap) =>
              s
                ..kernelHotTurn = t
                ..kernelSiegeLostTurn = t,
    );

    expect(FactionKernelWar.besiegeHot(_turn(war), _Counting()), isTrue);
    expect(war.kernelOf(war.owner), 6);
  });
}
