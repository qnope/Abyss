import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/attack_post_action.dart';
import 'package:abyss/domain/action/action_type.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/post_attack_helper.dart';

PostWar _ready([TransitionBaseType kind = TransitionBaseType.faille]) {
  final war = PostWar(kind);
  war.arm(war.attacker);
  return war;
}

void main() {
  for (final kind in TransitionBaseType.values) {
    test('a post held by a rival can be attacked: ${kind.name}', () {
      final war = _ready(kind);

      expect(
        war.strike(horde).validate(war.game, war.attacker).isSuccess,
        isTrue,
      );
    });
  }

  test('the army comes from the units of the level of the post', () {
    final war = PostWar(TransitionBaseType.cheminee);
    war.put(war.attacker, 1, horde);

    expect(
      war.strike(horde).validate(war.game, war.attacker).reason,
      ActionFailure.notEnoughUnits,
    );
  });

  test('an army must have at least one unit', () {
    final war = _ready();

    expect(
      war.strike({UnitType.harpoonist: 0}).validate(war.game, war.attacker),
      predicate<dynamic>((r) => r.reason == ActionFailure.noUnitSelected),
    );
  });

  test('a free post is not attacked, it is captured', () {
    final war = _ready()..post.capturedBy = null;

    expect(
      war.strike(horde).validate(war.game, war.attacker).reason,
      ActionFailure.baseNotCaptured,
    );
  });

  test('a player cannot attack its own post', () {
    final war = _ready()..post.capturedBy = null;
    war.post.capturedBy = war.attacker.id;

    expect(
      war.strike(horde).validate(war.game, war.attacker).reason,
      ActionFailure.cannotAttackSelf,
    );
  });

  test('a cell that is not a post is refused', () {
    final war = _ready();
    final blank = AttackPostAction(
      targetX: war.at.x,
      targetY: war.at.y,
      level: 3,
      selectedUnits: horde,
    );

    expect(
      blank.validate(war.game, war.attacker).reason,
      ActionFailure.noTransitionBaseHere,
    );
  });

  test('a post of an owner who fell is refused', () {
    final war = _ready();
    war.owner.savedFallen = true;

    expect(
      war.strike(horde).validate(war.game, war.attacker).reason,
      ActionFailure.playerFallen,
    );
  });

  test('nobody attacks a post before the first raid turn', () {
    final war = _ready();
    war.game.turn = 5;

    expect(
      war.strike(horde).validate(war.game, war.attacker).reason,
      ActionFailure.attackTooEarly,
    );
  });

  test('the human must have seen the post, a faction need not', () {
    final war = PostWar(TransitionBaseType.faille);
    war.owner.revealedCellsPerLevel[1] = [];
    war.human.revealedCellsPerLevel[1] = [];
    war.arm(war.human);
    war.arm(war.attacker);

    expect(
      war.strike(horde).validate(war.game, war.human).reason,
      ActionFailure.baseNotRevealed,
    );
    expect(
      war.strike(horde).validate(war.game, war.attacker).isSuccess,
      isTrue,
    );
  });

  test('it is the attackPost action', () {
    final war = _ready();

    expect(war.strike(horde).type, ActionType.attackPost);
    expect(war.strike(horde).description, startsWith('Attaque poste ('));
  });
}
