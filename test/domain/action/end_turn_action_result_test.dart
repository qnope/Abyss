import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/action_result.dart';
import 'package:abyss/domain/action/end_turn_action_result.dart';
import 'package:abyss/domain/turn/turn_result.dart';

void main() {
  group('EndTurnActionResult', () {
    test('success carries the turn result and no reason', () {
      const turn = TurnResult(
        changes: [],
        previousTurn: 3,
        newTurn: 4,
        hadRecruitedUnits: false,
      );
      final result = EndTurnActionResult.success(turnResult: turn);

      expect(result, isA<ActionResult>());
      expect(result.isSuccess, isTrue);
      expect(result.reason, isNull);
      expect(result.turnResult, same(turn));
    });

    test('success may carry no turn result', () {
      final result = EndTurnActionResult.success(turnResult: null);
      expect(result.isSuccess, isTrue);
      expect(result.turnResult, isNull);
    });

    test('failure keeps the reason and drops the turn result', () {
      // Built at runtime (not const) so the constructor body is exercised.
      final reason = ActionFailure.values.byName('gameOver');
      final result = EndTurnActionResult.failure(reason);

      expect(result.isSuccess, isFalse);
      expect(result.reason, ActionFailure.gameOver);
      expect(result.turnResult, isNull);
    });
  });
}
