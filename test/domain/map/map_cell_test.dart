import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  group('MapCell defaults', () {
    test('default collectedBy is null and isCollected is false', () {
      final cell = MapCell(terrain: TerrainType.plain);
      expect(cell.collectedBy, isNull);
      expect(cell.isCollected, isFalse);
    });

    test('default content is empty and monsterDifficulty is null', () {
      final cell = MapCell(terrain: TerrainType.plain);
      expect(cell.terrain, TerrainType.plain);
      expect(cell.content, CellContentType.empty);
      expect(cell.monsterDifficulty, isNull);
    });

    test('full construction with all fields', () {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        monsterDifficulty: MonsterDifficulty.hard,
        collectedBy: 'uuid-a',
      );
      expect(cell.terrain, TerrainType.plain);
      expect(cell.content, CellContentType.monsterLair);
      expect(cell.monsterDifficulty, MonsterDifficulty.hard);
      expect(cell.collectedBy, 'uuid-a');
      expect(cell.isCollected, isTrue);
    });
  });

  group('MapCell.copyWith', () {
    test('copyWith(collectedBy: value) sets collectedBy', () {
      final cell = MapCell(terrain: TerrainType.plain);
      final collected = cell.copyWith(collectedBy: 'uuid-a');
      expect(collected.collectedBy, 'uuid-a');
      expect(collected.isCollected, isTrue);
    });

    test('copyWith() with no args preserves collectedBy', () {
      final cell = MapCell(
        terrain: TerrainType.plain,
        collectedBy: 'uuid-a',
      );
      final copy = cell.copyWith();
      expect(copy.collectedBy, 'uuid-a');
    });

    test('copyWith(content: ...) preserves existing collectedBy', () {
      final cell = MapCell(
        terrain: TerrainType.plain,
        collectedBy: 'uuid-a',
      );
      final copy = cell.copyWith(content: CellContentType.ruins);
      expect(copy.collectedBy, 'uuid-a');
      expect(copy.content, CellContentType.ruins);
    });

    test('copyWith(collectedBy: null) clears the value via sentinel', () {
      final cell = MapCell(
        terrain: TerrainType.plain,
        collectedBy: 'uuid-a',
      );
      final cleared = cell.copyWith(collectedBy: null);
      expect(cleared.collectedBy, isNull);
      expect(cleared.isCollected, isFalse);
    });

    test('copyWith overrides other fields independently', () {
      final cell = MapCell(terrain: TerrainType.plain);
      final updated = cell.copyWith(
        content: CellContentType.monsterLair,
        monsterDifficulty: MonsterDifficulty.easy,
      );
      expect(updated.terrain, TerrainType.plain);
      expect(updated.content, CellContentType.monsterLair);
      expect(updated.monsterDifficulty, MonsterDifficulty.easy);
      expect(updated.collectedBy, isNull);
    });
  });
}
