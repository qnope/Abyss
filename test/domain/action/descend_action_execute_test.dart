import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/action/descend_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'descend_action_helper.dart';

void main() {
  group('DescendAction execute', () {
    test('generates target level when absent', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 2},
      );
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isTrue);
      expect(s.game.levels[2], isNotNull);
    });

    test('transfers units from source to target', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 3},
      );
      action.execute(s.game, s.player);
      expect(s.player.unitsOnLevel(1)[UnitType.scout]!.count, 7);
      expect(s.player.unitsOnLevel(2)[UnitType.scout]!.count, 3);
    });

    test('returns DescendResult with target level', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      final result = action.execute(s.game, s.player);
      expect(result, isA<DescendResult>());
      final dr = result as DescendResult;
      expect(dr.targetLevel, 2);
      expect(dr.unitsSent, {UnitType.scout: 1});
    });

    test('initializes revealed cells on target level', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      action.execute(s.game, s.player);
      expect(s.player.revealedCellsPerLevel[2], isNotNull);
      expect(s.player.revealedCellsPerLevel[2]!, isNotEmpty);
    });

    test('does not regenerate map on second descent', () {
      final s = createDescendScenario();
      DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      ).execute(s.game, s.player);

      final seed = s.game.levels[2]!.seed;
      DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      ).execute(s.game, s.player);

      expect(s.game.levels[2]!.seed, seed);
    });
  });
}
