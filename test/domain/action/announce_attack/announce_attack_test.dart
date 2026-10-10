import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/announce_attack_helper.dart';
import '../../../helpers/base_attack_helper.dart';

void main() {
  test('an announcement lands two turns ahead with its exact army', () {
    final two = announceGame();

    final result = announce(
      army: {UnitType.harpoonist: 25},
    ).execute(two.game, two.rival);

    expect(result.isSuccess, isTrue);
    final attack = pendingOf(two).single;
    expect(attack.attackerId, two.rival.id);
    expect(attack.arrivalTurn, 14);
    expect(attack.units, {UnitType.harpoonist: 25});
  });

  test('the army stays on the base until the attack', () {
    final two = announceGame();

    announce(army: {UnitType.harpoonist: 25}).execute(two.game, two.rival);

    expect(standing(two.rival, UnitType.harpoonist), 40);
  });

  test('nothing is announced while the tutorial is unfinished', () {
    final two = announceGame();
    ObjectiveMigration.stateOf(two.game, two.human).tutorialEnabled = true;

    expect(
      announce().validate(two.game, two.rival).reason,
      ActionFailure.attackTooEarly,
    );
  });

  test('without a tutorial nothing is announced before turn 10', () {
    final early = announceGame(turn: 9);
    final ready = announceGame(turn: 10);

    expect(
      announce().validate(early.game, early.rival).reason,
      ActionFailure.attackTooEarly,
    );
    expect(announce().validate(ready.game, ready.rival).isSuccess, isTrue);
  });

  test('no attack is announced for the turn a monster raid hits', () {
    final two = announceGame();
    two.human.raidState.announce(
      const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 3),
      14,
    );

    expect(
      announce().validate(two.game, two.rival).reason,
      ActionFailure.raidSameTurn,
    );
  });

  test('a raid on another turn does not stand in the way', () {
    final two = announceGame();
    two.human.raidState.announce(
      const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 3),
      15,
    );

    expect(announce().validate(two.game, two.rival).isSuccess, isTrue);
  });

  test('a faction has one pending attack at a time', () {
    final two = announceGame();
    announce(army: {UnitType.harpoonist: 10}).execute(two.game, two.rival);

    expect(
      announce(
        army: {UnitType.harpoonist: 10},
      ).validate(two.game, two.rival).reason,
      ActionFailure.attackAlreadyAnnounced,
    );
  });

  test('the human cannot announce an attack on itself', () {
    final two = announceGame();
    station(two.human, raiders);

    expect(
      announce().validate(two.game, two.human).reason,
      ActionFailure.cannotAttackSelf,
    );
  });

  test('units the base does not hold cannot be announced', () {
    final two = announceGame();

    expect(
      announce(
        army: {UnitType.harpoonist: 41},
      ).validate(two.game, two.rival).reason,
      ActionFailure.notEnoughUnits,
    );
  });

  test('the announcement never counts as a fight for the rival', () {
    final two = announceGame();

    announce().execute(two.game, two.rival);

    expect(announce().noiseMade(two.rival), 0);
    expect(two.human.historyEntries, isEmpty);
  });
}
