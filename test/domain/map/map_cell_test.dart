import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  group('MapCell defaults', () {
    test('default collectedBy is null and isCollected is false', () {
      final cell = MapCell(terrain: TerrainType.plain);
      expect(cell.collectedBy, isNull);
      expect(cell.isCollected, isFalse);
    });

    test('default content is empty and lair is null', () {
      final cell = MapCell(terrain: TerrainType.plain);
      expect(cell.terrain, TerrainType.plain);
      expect(cell.content, CellContentType.empty);
      expect(cell.lair, isNull);
    });

    test('full construction with all fields', () {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.hard,
          unitCount: 150,
        ),
        collectedBy: 'uuid-a',
      );
      expect(cell.terrain, TerrainType.plain);
      expect(cell.content, CellContentType.monsterLair);
      expect(cell.lair!.difficulty, MonsterDifficulty.hard);
      expect(cell.lair!.unitCount, 150);
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

    test('copyWith() with no args preserves collectedBy and lair', () {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.easy,
          unitCount: 25,
        ),
        collectedBy: 'uuid-a',
      );
      final copy = cell.copyWith();
      expect(copy.collectedBy, 'uuid-a');
      expect(copy.lair!.difficulty, MonsterDifficulty.easy);
      expect(copy.lair!.unitCount, 25);
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

    test('copyWith(lair: value) replaces lair', () {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.easy,
          unitCount: 25,
        ),
      );
      final updated = cell.copyWith(
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.hard,
          unitCount: 200,
        ),
      );
      expect(updated.lair!.difficulty, MonsterDifficulty.hard);
      expect(updated.lair!.unitCount, 200);
    });

    test('copyWith(lair: null) clears the lair via sentinel', () {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.medium,
          unitCount: 75,
        ),
      );
      final cleared = cell.copyWith(lair: null);
      expect(cleared.lair, isNull);
    });

    test('copyWith overrides other fields independently', () {
      final cell = MapCell(terrain: TerrainType.plain);
      final updated = cell.copyWith(
        content: CellContentType.monsterLair,
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.easy,
          unitCount: 30,
        ),
      );
      expect(updated.terrain, TerrainType.plain);
      expect(updated.content, CellContentType.monsterLair);
      expect(updated.lair!.difficulty, MonsterDifficulty.easy);
      expect(updated.collectedBy, isNull);
    });
  });
}
