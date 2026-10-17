import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/attack_cooldown.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/post_attack_helper.dart';

/// A war at turn 40 where [by] last attacked the posts of the owner
/// [ago] turns before.
PostWar _war({
  bool humanHolds = false,
  required Player Function(PostWar) by,
  required int ago,
}) {
  final war = PostWar(TransitionBaseType.faille, humanHolds: humanHolds)
    ..game.turn = 40;
  final Player attacker = by(war);
  war.arm(attacker);
  attacker.raidState.postAttackTurns[war.owner.id] = 40 - ago;
  return war;
}

ActionFailure? _refusal(PostWar war, Player attacker) =>
    war.strike(horde).validate(war.game, attacker).reason;

void main() {
  test('a faction waits the cooldown before attacking the human again', () {
    final soon = _war(humanHolds: true, by: (w) => w.attacker, ago: 3);
    final late = _war(humanHolds: true, by: (w) => w.attacker, ago: 4);

    expect(AttackCooldown.turns, 4);
    expect(_refusal(soon, soon.attacker), ActionFailure.attackTooSoon);
    expect(_refusal(late, late.attacker), isNull);
  });

  test('a faction waits the cooldown before attacking a faction again', () {
    final soon = _war(by: (w) => w.attacker, ago: 1);
    final late = _war(by: (w) => w.attacker, ago: 4);

    expect(_refusal(soon, soon.attacker), ActionFailure.attackTooSoon);
    expect(_refusal(late, late.attacker), isNull);
  });

  test('the human waits the cooldown before attacking a faction again', () {
    final soon = _war(by: (w) => w.human, ago: 3);
    final late = _war(by: (w) => w.human, ago: 4);

    expect(_refusal(soon, soon.human), ActionFailure.attackTooSoon);
    expect(_refusal(late, late.human), isNull);
  });

  test('another attacker may strike the very next turn', () {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true)
      ..game.turn = 40;
    war.arm(war.attacker, {UnitType.harpoonist: 6});
    war.put(war.human, war.below, wall);
    ActionExecutor().execute(
      war.strike({UnitType.harpoonist: 6}),
      war.game,
      war.attacker,
    );
    final other = war.game.players[war.game.factions[1].id]!;
    other.addRevealedCell(war.level, war.at);
    war.arm(other);
    war.game.turn = 41;

    expect(_refusal(war, war.attacker), ActionFailure.attackTooSoon);
    expect(_refusal(war, other), isNull);
  });

  test('an attack starts the cooldown whatever its outcome', () {
    final won = PostWar(TransitionBaseType.faille, humanHolds: true)
      ..game.turn = 40;
    won.arm(won.attacker);
    final lost = PostWar(TransitionBaseType.faille, humanHolds: true)
      ..game.turn = 40;
    lost.arm(lost.attacker, {UnitType.harpoonist: 6});
    lost.put(lost.human, lost.below, wall);

    ActionExecutor().execute(won.strike(horde), won.game, won.attacker);
    ActionExecutor().execute(
      lost.strike({UnitType.harpoonist: 6}),
      lost.game,
      lost.attacker,
    );

    expect(won.post.capturedBy, won.attacker.id);
    expect(lost.post.capturedBy, lost.human.id);
    expect(won.attacker.raidState.postAttackTurns, {won.human.id: 40});
    expect(lost.attacker.raidState.postAttackTurns, {lost.human.id: 40});
  });

  test('the kernel cooldown leaves the posts alone', () {
    final war = PostWar(TransitionBaseType.faille)..game.turn = 40;
    war.arm(war.attacker);
    war.attacker.raidState.kernelAttackTurns[war.owner.id] = 40;

    expect(_refusal(war, war.attacker), isNull);
  });
}
