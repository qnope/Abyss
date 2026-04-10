import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_result.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'send_reinforcements_helper.dart';

void main() {
  group('SendReinforcementsAction.makeHistoryEntry', () {
    test('returns ReinforcementEntry on success', () {
      final s = createReinforcementScenario();
      final action = createReinforcementAction(
        units: {UnitType.scout: 3},
      );
      final result = action.execute(s.game, s.player);
      final entry = action.makeHistoryEntry(
        s.game,
        s.player,
        result,
        5,
      );

      expect(entry, isA<ReinforcementEntry>());
      final reinf = entry! as ReinforcementEntry;
      expect(reinf.turn, 5);
      expect(reinf.category, HistoryEntryCategory.reinforcement);
      expect(reinf.targetLevel, 2);
      expect(reinf.unitCount, 3);
      expect(reinf.subtitle, '3 unites en transit');
    });

    test('returns null on failure', () {
      final s = createReinforcementScenario(scoutCount: 0);
      final action = createReinforcementAction();
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isFalse);
      final entry = action.makeHistoryEntry(
        s.game,
        s.player,
        result,
        1,
      );
      expect(entry, isNull);
    });

    test('returns null when result is generic failure', () {
      final s = createReinforcementScenario();
      final action = createReinforcementAction();
      const failResult = ActionResult.failure('test');
      final entry = action.makeHistoryEntry(
        s.game,
        s.player,
        failResult,
        1,
      );
      expect(entry, isNull);
    });
  });
}
