import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_result.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'descend_action_helper.dart';

void main() {
  group('DescendAction.makeHistoryEntry', () {
    test('returns DescentEntry on successful execute', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 4},
      );
      final result = action.execute(s.game, s.player);
      final entry = action.makeHistoryEntry(
        s.game,
        s.player,
        result,
        3,
      );

      expect(entry, isA<DescentEntry>());
      final descent = entry! as DescentEntry;
      expect(descent.turn, 3);
      expect(descent.category, HistoryEntryCategory.descent);
      expect(descent.targetLevel, 2);
      expect(descent.unitCount, 4);
      expect(descent.subtitle, '4 unites envoyees');
    });

    test('returns null on failure result', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      const failResult = ActionResult.failure('nope');
      final entry = action.makeHistoryEntry(
        s.game,
        s.player,
        failResult,
        1,
      );
      expect(entry, isNull);
    });

    test('returns null when result is not DescendResult', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      const genericSuccess = ActionResult.success();
      final entry = action.makeHistoryEntry(
        s.game,
        s.player,
        genericSuccess,
        1,
      );
      expect(entry, isNull);
    });

    test('unitCount sums all unit types sent', () {
      final s = createDescendScenario(scoutCount: 20);
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 5},
      );
      final result = action.execute(s.game, s.player);
      final entry = action.makeHistoryEntry(
        s.game,
        s.player,
        result,
        7,
      ) as DescentEntry;
      expect(entry.unitCount, 5);
    });
  });
}
