import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/attack_base_action.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/installation_objectives.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/two_player_game.dart';

void main() {
  test('no attack before turn 10 without the tutorial', () {
    final early = assaultGame(turn: 9);
    station(early.human, horde);
    final ready = assaultGame(turn: 10);
    station(ready.human, horde);

    expect(
      strike(early, horde).validate(early.game, early.human).reason,
      ActionFailure.attackTooEarly,
    );
    expect(
      strike(ready, horde).validate(ready.game, ready.human).isSuccess,
      isTrue,
    );
  });

  test('no attack while the tutorial chapter is unfinished', () {
    final two = assaultGame(turn: 30);
    station(two.human, horde);
    _tutorial(two.human, two, done: false);

    expect(
      strike(two, horde).validate(two.game, two.human).reason,
      ActionFailure.attackTooEarly,
    );
    _tutorial(two.human, two, done: true);
    expect(strike(two, horde).validate(two.game, two.human).isSuccess, isTrue);
  });

  test('a player still in the tutorial cannot be attacked either', () {
    final two = assaultGame(turn: 30);
    station(two.rival, horde);
    _tutorial(two.human, two, done: false);
    final action = AttackBaseAction(
      targetPlayerId: two.human.id,
      selectedUnits: horde,
    );

    expect(
      action.validate(two.game, two.rival).reason,
      ActionFailure.attackTooEarly,
    );
  });
}

void _tutorial(Player player, TwoPlayerGame two, {required bool done}) {
  final state = ObjectiveMigration.stateOf(two.game, player);
  state.tutorialEnabled = true;
  state.completed.clear();
  if (done) {
    for (final objective in installationObjectives) {
      state.complete(objective.id);
    }
  }
}
