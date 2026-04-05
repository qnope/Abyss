import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  group('MapCell', () {
    test('default construction has expected defaults', () {
      final cell = MapCell(terrain: TerrainType.reef);
      expect(cell.terrain, TerrainType.reef);
      expect(cell.content, CellContentType.empty);
      expect(cell.isRevealed, false);
      expect(cell.monsterDifficulty, isNull);
      expect(cell.bonusResourceType, isNull);
      expect(cell.bonusAmount, isNull);
    });

    test('full construction with all fields', () {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.resourceBonus,
        monsterDifficulty: MonsterDifficulty.hard,
        isRevealed: true,
        bonusResourceType: ResourceType.coral,
        bonusAmount: 25,
      );
      expect(cell.terrain, TerrainType.plain);
      expect(cell.content, CellContentType.resourceBonus);
      expect(cell.monsterDifficulty, MonsterDifficulty.hard);
      expect(cell.isRevealed, true);
      expect(cell.bonusResourceType, ResourceType.coral);
      expect(cell.bonusAmount, 25);
    });

    test('copyWith preserves unchanged fields', () {
      final cell = MapCell(
        terrain: TerrainType.rock,
        content: CellContentType.ruins,
        isRevealed: true,
      );
      final copy = cell.copyWith(isRevealed: false);
      expect(copy.terrain, TerrainType.rock);
      expect(copy.content, CellContentType.ruins);
      expect(copy.isRevealed, false);
    });

    test('copyWith overrides specified fields', () {
      final cell = MapCell(terrain: TerrainType.fault);
      final revealed = cell.copyWith(
        isRevealed: true,
        content: CellContentType.monsterLair,
        monsterDifficulty: MonsterDifficulty.easy,
      );
      expect(revealed.isRevealed, true);
      expect(revealed.content, CellContentType.monsterLair);
      expect(revealed.monsterDifficulty, MonsterDifficulty.easy);
      expect(revealed.terrain, TerrainType.fault);
    });
  });
}
