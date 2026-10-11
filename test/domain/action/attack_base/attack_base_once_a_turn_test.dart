import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/attack_base_validator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/base_attack_helper.dart';

void main() {
  test('a base is attacked once a turn at most by the same player', () {
    final two = assaultGame();
    station(two.human, horde);
    expect(
      ActionExecutor()
          .execute(strike(two, horde), two.game, two.human)
          .isSuccess,
      isTrue,
    );
    station(two.human, horde);

    expect(
      strike(two, horde).validate(two.game, two.human).reason,
      ActionFailure.alreadyAttackedThisTurn,
    );
    expect(
      AttackBaseValidator.refusal(two.game, two.human, two.rival.id),
      ActionFailure.alreadyAttackedThisTurn,
    );
  });

  test('the next turn it can be attacked again', () {
    final two = assaultGame();
    station(two.human, horde);
    ActionExecutor().execute(strike(two, horde), two.game, two.human);
    two.game.turn++;
    station(two.human, horde);

    expect(
      AttackBaseValidator.refusal(two.game, two.human, two.rival.id),
      isNull,
    );
  });
}
