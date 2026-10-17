import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/post_attack_helper.dart';

/// The human holds the post, the faction stands ready, the human lost a
/// post [ago] turns before (never when `null`).
PostWar _humanPost({int? ago}) {
  final war = PostWar(TransitionBaseType.faille, humanHolds: true);
  war.game.turn = 40;
  war.arm(war.attacker);
  if (ago != null) war.human.raidState.postLostTurn = war.game.turn - ago;
  return war;
}

void main() {
  test('the harder the game, the closer the attacks on the posts', () {
    expect(Difficulty.easy.postGap, 16);
    expect(Difficulty.normal.postGap, 12);
    expect(Difficulty.hard.postGap, 6);
  });

  test('a faction waits postGap turns after the human lost a post', () {
    final gap = _humanPost().game.difficulty.postGap;
    final soon = _humanPost(ago: gap - 1);
    final late = _humanPost(ago: gap);

    expect(
      soon.strike(horde).validate(soon.game, soon.attacker).reason,
      ActionFailure.attackTooSoon,
    );
    expect(
      late.strike(horde).validate(late.game, late.attacker).isSuccess,
      isTrue,
    );
  });

  test('a human who never lost a post can be attacked early', () {
    final war = _humanPost()..game.turn = 13;

    expect(war.human.raidState.postLostTurn, isNull);
    expect(
      war.strike(horde).validate(war.game, war.attacker).isSuccess,
      isTrue,
    );
  });

  test('the posts between factions are not spaced', () {
    final war = PostWar(TransitionBaseType.faille)..game.turn = 40;
    war.arm(war.attacker);
    war.owner.raidState.postLostTurn = 39;

    expect(
      war.strike(horde).validate(war.game, war.attacker).isSuccess,
      isTrue,
    );
  });

  test('the human attacking a faction post is not spaced', () {
    final war = PostWar(TransitionBaseType.faille)..game.turn = 40;
    war.arm(war.human);
    war.human.raidState.postLostTurn = 39;
    war.owner.raidState.postLostTurn = 39;

    expect(war.strike(horde).validate(war.game, war.human).isSuccess, isTrue);
  });

  test('a post taken from its owner records the turn of the loss', () {
    final war = _humanPost();

    ActionExecutor().execute(war.strike(horde), war.game, war.attacker);

    expect(war.post.capturedBy, war.attacker.id);
    expect(war.human.raidState.postLostTurn, 40);
  });

  test('a post that holds records no loss', () {
    final war = _humanPost();
    war.arm(war.attacker, {UnitType.harpoonist: 6});
    war.put(war.human, war.below, wall);

    ActionExecutor().execute(
      war.strike({UnitType.harpoonist: 6}),
      war.game,
      war.attacker,
    );

    expect(war.post.capturedBy, war.human.id);
    expect(war.human.raidState.postLostTurn, isNull);
  });
}
