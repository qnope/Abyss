import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/kernel_war_helper.dart';

/// A war at turn 40 where [by], armed, last besieged the owner's kernel
/// [ago] turns before (never when `null`).
KernelWar _war({
  bool humanHolds = false,
  required Player Function(KernelWar) by,
  int? ago,
}) {
  final war = KernelWar(kernelLevel: 3, humanHolds: humanHolds)..game.turn = 40;
  final Player attacker = by(war);
  war.put(attacker, KernelGarrison.volcanoLevel, horde);
  if (ago != null) {
    attacker.raidState.kernelAttackTurns[war.owner.id] = 40 - ago;
  }
  return war;
}

ActionFailure? _refusal(KernelWar war, Player attacker) =>
    war.strike(horde).validate(war.game, attacker).reason;

void main() {
  test('a faction waits the cooldown before besieging the human again', () {
    final soon = _war(humanHolds: true, by: (w) => w.attacker, ago: 3);
    final late = _war(humanHolds: true, by: (w) => w.attacker, ago: 4);

    expect(_refusal(soon, soon.attacker), ActionFailure.attackTooSoon);
    expect(_refusal(late, late.attacker), isNull);
  });

  test('a faction waits the cooldown before besieging a faction again', () {
    final soon = _war(by: (w) => w.attacker, ago: 2);
    final late = _war(by: (w) => w.attacker, ago: 4);

    expect(_refusal(soon, soon.attacker), ActionFailure.attackTooSoon);
    expect(_refusal(late, late.attacker), isNull);
  });

  test('the human waits the cooldown before besieging a faction again', () {
    final soon = _war(by: (w) => w.human, ago: 3);
    final late = _war(by: (w) => w.human, ago: 4);

    expect(_refusal(soon, soon.human), ActionFailure.attackTooSoon);
    expect(_refusal(late, late.human), isNull);
  });

  test('a hot kernel is besieged with no grace', () {
    final war =
        KernelWar(kernelLevel: 7, humanHolds: true)
          ..game.turn = 40
          ..arm();

    expect(_refusal(war, war.attacker), isNull);
  });

  test('a siege starts the cooldown whatever its outcome', () {
    final won = _war(humanHolds: true, by: (w) => w.attacker);
    final lost = _war(humanHolds: true, by: (w) => w.attacker)
      ..garrison(fortress);

    ActionExecutor().execute(won.strike(horde), won.game, won.attacker);
    ActionExecutor().execute(lost.strike(horde), lost.game, lost.attacker);

    expect(won.kernelOf(won.human), 2);
    expect(lost.kernelOf(lost.human), 3);
    expect(won.attacker.raidState.kernelAttackTurns, {won.human.id: 40});
    expect(lost.attacker.raidState.kernelAttackTurns, {lost.human.id: 40});
    expect(lost.human.raidState.kernelSiegeLostTurn, isNull);
  });

  test('another attacker may besiege the very next turn', () {
    final war = _war(humanHolds: true, by: (w) => w.attacker);
    ActionExecutor().execute(war.strike(horde), war.game, war.attacker);
    final other = war.game.players[war.game.factions[1].id]!;
    war.put(other, KernelGarrison.volcanoLevel, horde);
    war.game.turn = 41;

    expect(_refusal(war, war.attacker), ActionFailure.attackTooSoon);
    expect(_refusal(war, other), isNull);
  });

  test('the post cooldown leaves the kernel alone', () {
    final war = _war(by: (w) => w.attacker);
    war.attacker.raidState.postAttackTurns[war.owner.id] = 40;

    expect(_refusal(war, war.attacker), isNull);
  });
}
