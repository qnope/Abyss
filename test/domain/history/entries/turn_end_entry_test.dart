import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/history/entries/turn_end_entry_factory.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  group('TurnEndEntry', () {
    test('title uses French tour format with recorded turn', () {
      final entry = TurnEndEntry(
        turn: 12,
        changes: const [],
        deactivatedBuildings: const [],
        lostUnits: const {},
      );

      expect(entry.turn, 12);
      expect(entry.category, HistoryEntryCategory.turnEnd);
      expect(entry.title, 'Tour 12 terminé');
      expect(entry.subtitle, isNull);
    });
  });

  group('TurnEndEntryFactory', () {
    test('fromTurnResult copies changes, deactivated buildings and losses', () {
      const result = TurnResult(
        changes: [
          TurnResourceChange(
            type: ResourceType.algae,
            produced: 30,
            consumed: 10,
            wasCapped: false,
            beforeAmount: 100,
            afterAmount: 120,
          ),
          TurnResourceChange(
            type: ResourceType.energy,
            produced: 5,
            wasCapped: true,
            beforeAmount: 50,
            afterAmount: 50,
          ),
        ],
        previousTurn: 4,
        newTurn: 5,
        hadRecruitedUnits: false,
        deactivatedBuildings: [BuildingType.laboratory],
        lostUnits: {UnitType.scout: 2},
      );

      const factory = TurnEndEntryFactory();
      final entry = factory.fromTurnResult(5, result);

      expect(entry.turn, 5);
      expect(entry.category, HistoryEntryCategory.turnEnd);
      expect(entry.title, 'Tour 5 terminé');
      expect(entry.changes, hasLength(2));
      expect(entry.changes.first.type, ResourceType.algae);
      expect(entry.changes.first.afterAmount, 120);
      expect(entry.deactivatedBuildings, [BuildingType.laboratory]);
      expect(entry.lostUnits[UnitType.scout], 2);
    });

    test('fromTurnResult handles empty deactivations and losses', () {
      const result = TurnResult(
        changes: [],
        previousTurn: 1,
        newTurn: 2,
        hadRecruitedUnits: true,
      );

      const factory = TurnEndEntryFactory();
      final entry = factory.fromTurnResult(2, result);

      expect(entry.turn, 2);
      expect(entry.changes, isEmpty);
      expect(entry.deactivatedBuildings, isEmpty);
      expect(entry.lostUnits, isEmpty);
    });
  });
}
