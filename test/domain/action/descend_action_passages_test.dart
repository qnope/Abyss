import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'descend_action_helper.dart';

void main() {
  group('DescendAction passage reservation', () {
    test('generates level 2 with passage cells at faille positions', () {
      final s = createDescendScenario();

      // Record faille positions from level 1
      final parentMap = s.game.levels[1]!;
      final failles = <GridPosition, String>{};
      for (var y = 0; y < parentMap.height; y++) {
        for (var x = 0; x < parentMap.width; x++) {
          final cell = parentMap.cellAt(x, y);
          if (cell.content == CellContentType.transitionBase &&
              cell.transitionBase != null) {
            failles[GridPosition(x: x, y: y)] =
                cell.transitionBase!.name;
          }
        }
      }
      expect(failles, isNotEmpty);

      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      action.execute(s.game, s.player);

      final level2 = s.game.levels[2]!;
      for (final entry in failles.entries) {
        final cell = level2.cellAt(entry.key.x, entry.key.y);
        // May overlap with the base cell, which gets cleared
        if (cell.content == CellContentType.empty) continue;
        expect(cell.content, CellContentType.passage);
        expect(cell.passageName, entry.value);
      }
    });

    test('passage cells have no lair or transitionBase', () {
      final s = createDescendScenario();
      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      action.execute(s.game, s.player);

      final level2 = s.game.levels[2]!;
      for (var y = 0; y < level2.height; y++) {
        for (var x = 0; x < level2.width; x++) {
          final cell = level2.cellAt(x, y);
          if (cell.content == CellContentType.passage) {
            expect(cell.lair, isNull);
            expect(cell.transitionBase, isNull);
          }
        }
      }
    });

    test('multiple failles produce multiple passages', () {
      final s = createDescendScenario();
      // Add a second faille to level 1
      final parentMap = s.game.levels[1]!;
      parentMap.setCell(
        3,
        3,
        MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.transitionBase,
          transitionBase: TransitionBase(
            type: TransitionBaseType.faille,
            name: 'Faille B',
            capturedBy: 'test',
          ),
        ),
      );

      final action = DescendAction(
        transitionX: 5,
        transitionY: 5,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      action.execute(s.game, s.player);

      final level2 = s.game.levels[2]!;
      final passages = <GridPosition>[];
      for (var y = 0; y < level2.height; y++) {
        for (var x = 0; x < level2.width; x++) {
          if (level2.cellAt(x, y).content == CellContentType.passage) {
            passages.add(GridPosition(x: x, y: y));
          }
        }
      }
      expect(passages.length, greaterThanOrEqualTo(2));
    });
  });
}
