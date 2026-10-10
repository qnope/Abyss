import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/attack_base_action.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/base_attack_helper.dart';

void main() {
  test('a revealed rival base can be attacked with units of the base', () {
    final two = assaultGame();
    station(two.human, horde);

    expect(strike(two, horde).validate(two.game, two.human).isSuccess, isTrue);
  });

  test('the human can be named as a target without its id', () {
    final two = assaultGame();
    station(two.rival, horde);
    final named = AttackBaseAction(
      targetPlayerId: AttackBaseAction.human,
      selectedUnits: horde,
    );

    expect(named.validate(two.game, two.rival).isSuccess, isTrue);
    station(two.human, horde);
    expect(
      named.validate(two.game, two.human).reason,
      ActionFailure.cannotAttackSelf,
    );
  });

  test('a player cannot attack itself', () {
    final two = assaultGame();
    station(two.human, horde);
    final self = AttackBaseAction(
      targetPlayerId: two.human.id,
      selectedUnits: horde,
    );

    expect(
      self.validate(two.game, two.human).reason,
      ActionFailure.cannotAttackSelf,
    );
  });

  test('an unknown player cannot be attacked', () {
    final two = assaultGame();
    station(two.human, horde);
    final ghost = AttackBaseAction(
      targetPlayerId: 'nobody',
      selectedUnits: horde,
    );

    expect(
      ghost.validate(two.game, two.human).reason,
      ActionFailure.noSuchPlayer,
    );
  });

  test('a fallen player is out of reach', () {
    final two = assaultGame();
    station(two.human, horde);
    two.rival.savedFallen = true;

    expect(
      strike(two, horde).validate(two.game, two.human).reason,
      ActionFailure.playerFallen,
    );
  });

  test('the human must have seen the base', () {
    final two = assaultGame(revealed: false);
    station(two.human, horde);

    expect(
      strike(two, horde).validate(two.game, two.human).reason,
      ActionFailure.baseNotRevealed,
    );
  });

  test('a faction attacks a base its strategy knows without the fog', () {
    final two = assaultGame(revealed: false);
    station(two.rival, horde);
    final action = AttackBaseAction(
      targetPlayerId: two.human.id,
      selectedUnits: horde,
    );

    expect(action.validate(two.game, two.rival).isSuccess, isTrue);
  });

  test('the army must exist and not be empty', () {
    final two = assaultGame();
    station(two.human, {UnitType.harpoonist: 3});

    expect(
      strike(two, {
        UnitType.harpoonist: 4,
      }).validate(two.game, two.human).reason,
      ActionFailure.notEnoughUnits,
    );
    expect(
      strike(two, {
        UnitType.harpoonist: 0,
      }).validate(two.game, two.human).reason,
      ActionFailure.noUnitSelected,
    );
  });

  test('units of the deeper levels cannot attack', () {
    final two = assaultGame();
    station(two.human, const {});

    expect(
      strike(two, {
        UnitType.harpoonist: 1,
      }).validate(two.game, two.human).reason,
      ActionFailure.notEnoughUnits,
    );
  });
}
