import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/end_turn_action_result.dart';
import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/kernel_war_helper.dart';

/// The kernel the human holds at [level] with [garrison], struck by the
/// first faction's [army].
KernelWar _struck({
  int level = 3,
  Map<UnitType, int> garrison = smallGarrison,
  Map<UnitType, int> army = horde,
}) {
  final war =
      KernelWar(kernelLevel: level, humanHolds: true)
        ..arm(army)
        ..garrison(garrison);
  ActionExecutor().execute(war.strike(army), war.game, war.attacker);
  return war;
}

FactionAttackReport _reportOf(KernelWar war) {
  final result = EndTurnAction(
    random: Random(1),
    playFactions: false,
  ).execute(war.game, war.human);
  return (result as EndTurnActionResult).turnResult!.attacks.single;
}

void main() {
  test('a won attack that leaves the kernel costs it a level', () {
    final war = _struck();

    final report = _reportOf(war);

    expect(report.target, AttackTarget.kernel);
    expect(report.outcome, AttackOutcome.kernelDamaged);
    expect(report.attackerId, war.attacker.id);
    expect(report.personality, war.game.factions[0].personality);
    expect(report.entry.rampartBefore, 3);
    expect(report.entry.rampartAfter, 2);
    final int dead = report.entry.dead.values.fold(0, (a, b) => a + b);
    expect(dead, greaterThan(0));
    expect(report.unitsLost, dead);
  });

  test('a kernel brought to level 0 is taken with its garrison', () {
    final war = _struck(level: 1);

    final report = _reportOf(war);

    expect(report.outcome, AttackOutcome.kernelTaken);
    expect(report.unitsLost, smallGarrison[UnitType.harpoonist]);
    expect(report.levelBelow, isNull);
    expect(report.passageLost, isNull);
  });

  test('a garrison that holds repels the attack', () {
    final war = _struck(
      garrison: fortress,
      army: const {UnitType.harpoonist: 4},
    );

    final report = _reportOf(war);

    expect(report.target, AttackTarget.kernel);
    expect(report.outcome, AttackOutcome.repelled);
    expect(report.unitsLost, 0);
  });
}
