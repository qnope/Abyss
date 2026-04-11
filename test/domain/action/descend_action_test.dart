import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/action/descend_result.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
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

  group('DescendAction execute', () {
    test('generates level 2 and transfers units', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 3},
      );
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isTrue);
      expect((result as DescendResult).targetLevel, 2);
      expect(s.game.levels.containsKey(2), isTrue);
      expect(s.player.unitsOnLevel(1)[UnitType.scout]!.count, 7);
      expect(s.player.unitsOnLevel(2)[UnitType.scout]!.count, 3);
    });

    test('initial reveal area is centered on transition position', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      action.execute(s.game, s.player);

      final revealed = s.player.revealedCellsSetOnLevel(2);
      // Reveal should be centered on (5,5) — the transition position
      expect(revealed.contains(GridPosition(x: 5, y: 5)), isTrue);
      // All revealed cells should be near (5,5)
      for (final pos in revealed) {
        expect((pos.x - 5).abs() <= 2, isTrue);
        expect((pos.y - 5).abs() <= 2, isTrue);
      }
    });

    test('does not regenerate level if already exists', () {
      final s = createDescendScenario();
      // First descent generates the level
      final action1 = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 2},
      );
      action1.execute(s.game, s.player);
      final seed = s.game.levels[2]!.seed;

      // Second descent reuses existing level
      final action2 = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 2},
      );
      action2.execute(s.game, s.player);
      expect(s.game.levels[2]!.seed, seed);
      expect(s.player.unitsOnLevel(2)[UnitType.scout]!.count, 4);
    });
  });
}
