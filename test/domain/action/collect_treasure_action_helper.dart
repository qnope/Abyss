import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';

/// Builds a 5×5 map with base at (2,2).
/// All cells revealed, plain terrain, empty content.
/// Cell at (1,1) set with the specified content type and optional fields.
GameMap buildCollectTestMap({
  CellContentType content = CellContentType.resourceBonus,
  ResourceType? bonusResourceType,
  int? bonusAmount,
  MonsterDifficulty? monsterDifficulty,
  bool isCollected = false,
}) {
  final cells = <MapCell>[];
  for (var y = 0; y < 5; y++) {
    for (var x = 0; x < 5; x++) {
      if (x == 1 && y == 1) {
        cells.add(MapCell(
          terrain: TerrainType.plain,
          isRevealed: true,
          content: content,
          bonusResourceType: bonusResourceType,
          bonusAmount: bonusAmount,
          monsterDifficulty: monsterDifficulty,
          isCollected: isCollected,
        ));
      } else {
        cells.add(MapCell(
          terrain: TerrainType.plain,
          isRevealed: true,
        ));
      }
    }
  }
  return GameMap(
    width: 5,
    height: 5,
    cells: cells,
    playerBaseX: 2,
    playerBaseY: 2,
    seed: 42,
  );
}

Game createCollectGame({
  CellContentType content = CellContentType.resourceBonus,
  ResourceType? bonusResourceType,
  int? bonusAmount,
  MonsterDifficulty? monsterDifficulty,
  bool isCollected = false,
}) {
  return Game(
    player: Player(name: 'Test'),
    gameMap: buildCollectTestMap(
      content: content,
      bonusResourceType: bonusResourceType,
      bonusAmount: bonusAmount,
      monsterDifficulty: monsterDifficulty,
      isCollected: isCollected,
    ),
  );
}
