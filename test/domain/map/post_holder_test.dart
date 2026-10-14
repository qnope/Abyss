import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';

void main() {
  TransitionBase base({String? capturedBy}) => TransitionBase(
        type: TransitionBaseType.faille,
        name: 'faille:0',
        capturedBy: capturedBy,
      );

  group('PostHolder.of', () {
    test('a base nobody captured is still guarded', () {
      expect(PostHolder.of(base(), 'human'), PostHolder.guardians);
    });

    test('a base the human captured is theirs', () {
      expect(PostHolder.of(base(capturedBy: 'human'), 'human'),
          PostHolder.human);
    });

    test('a base another player captured is a faction\'s', () {
      expect(PostHolder.of(base(capturedBy: 'murenes'), 'human'),
          PostHolder.faction);
    });
  });

  group('PostHolder.passagesBelow', () {
    GameMap above() {
      final cells = List.generate(9, (_) => MapCell(terrain: TerrainType.plain));
      final map = GameMap(width: 3, height: 3, cells: cells, seed: 1);
      map.setCell(
        2,
        1,
        MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.transitionBase,
          transitionBase: base(capturedBy: 'murenes'),
        ),
      );
      return map;
    }

    test('gives the holder of each base, where its passage lies below', () {
      expect(PostHolder.passagesBelow(above(), 'human'), {
        GridPosition(x: 2, y: 1): PostHolder.faction,
      });
    });

    test('is empty without a level above', () {
      expect(PostHolder.passagesBelow(null, 'human'), isEmpty);
    });
  });
}
