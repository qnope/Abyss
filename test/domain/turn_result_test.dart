import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/turn_result.dart';
import 'package:abyss/domain/unit_type.dart';

void main() {
  group('TurnResourceChange', () {
    test('consumed defaults to 0', () {
      final change = TurnResourceChange(
        type: ResourceType.algae,
        produced: 50,
        wasCapped: false,
        beforeAmount: 100,
        afterAmount: 150,
      );
      expect(change.consumed, 0);
    });

    test('consumed stores given value', () {
      final change = TurnResourceChange(
        type: ResourceType.algae,
        produced: 50,
        consumed: 12,
        wasCapped: false,
        beforeAmount: 100,
        afterAmount: 138,
      );
      expect(change.consumed, 12);
    });
  });

  group('TurnResult', () {
    test('deactivatedBuildings defaults to empty', () {
      final result = TurnResult(
        changes: [],
        previousTurn: 1,
        newTurn: 2,
        hadRecruitedUnits: false,
      );
      expect(result.deactivatedBuildings, isEmpty);
    });

    test('lostUnits defaults to empty', () {
      final result = TurnResult(
        changes: [],
        previousTurn: 1,
        newTurn: 2,
        hadRecruitedUnits: false,
      );
      expect(result.lostUnits, isEmpty);
    });

    test('stores deactivatedBuildings', () {
      final result = TurnResult(
        changes: [],
        previousTurn: 1,
        newTurn: 2,
        hadRecruitedUnits: false,
        deactivatedBuildings: [BuildingType.oreExtractor],
      );
      expect(result.deactivatedBuildings.length, 1);
    });

    test('stores lostUnits', () {
      final result = TurnResult(
        changes: [],
        previousTurn: 1,
        newTurn: 2,
        hadRecruitedUnits: false,
        lostUnits: {UnitType.scout: 5},
      );
      expect(result.lostUnits[UnitType.scout], 5);
    });
  });
}
