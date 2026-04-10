import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'descend_action_helper.dart';

void main() {
  group('DescendAction validate', () {
    test('succeeds with valid conditions', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 3},
      );
      expect(action.validate(s.game, s.player).isSuccess, isTrue);
    });

    test('fails when map is null', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 99,
        selectedUnits: {UnitType.scout: 1},
      );
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Carte non generee');
    });

    test('fails when cell has no transition base', () {
      final s = createDescendScenario(
        transitionContent: CellContentType.empty,
      );
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Pas de base de transition');
    });

    test('fails when base not captured by player', () {
      final s = createDescendScenario(capturedBy: null);
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Base non capturee');
    });

    test('fails when required building missing', () {
      final s = createDescendScenario(descentModuleLevel: 0);
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Batiment requis manquant');
    });

    test('fails with insufficient units', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 100},
      );
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Unites insuffisantes');
    });

    test('fails with no units selected', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {},
      );
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Aucune unite selectionnee');
    });
  });
}
