import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// Builds a 5x5 map with the (1,1) cell holding a monster lair.
GameMap buildFightTestMap({
  MonsterDifficulty difficulty = MonsterDifficulty.easy,
  int unitCount = 1,
  String? collectedBy,
  bool withLair = true,
  CellContentType content = CellContentType.monsterLair,
}) {
  final cells = <MapCell>[];
  for (var y = 0; y < 5; y++) {
    for (var x = 0; x < 5; x++) {
      if (x == 1 && y == 1) {
        cells.add(MapCell(
          terrain: TerrainType.plain,
          content: content,
          lair: withLair
              ? MonsterLair(difficulty: difficulty, unitCount: unitCount)
              : null,
          collectedBy: collectedBy,
        ));
      } else {
        cells.add(MapCell(terrain: TerrainType.plain));
      }
    }
  }
  return GameMap(width: 5, height: 5, cells: cells, seed: 42);
}

/// Player with a configurable stock of units and default base/resources.
Player buildFightTestPlayer({
  String id = 'test-uuid',
  Map<UnitType, int> stock = const {},
  int militaryResearchLevel = 0,
}) {
  final Player player = Player(
    id: id,
    name: 'Test',
    baseX: 2,
    baseY: 2,
  );
  for (final MapEntry<UnitType, int> entry in stock.entries) {
    player.units[entry.key]!.count = entry.value;
  }
  if (militaryResearchLevel > 0) {
    final TechBranchState mil = player.techBranches[TechBranch.military]!;
    mil.unlocked = true;
    mil.researchLevel = militaryResearchLevel;
  }
  return player;
}

({Game game, Player player}) createFightScenario({
  MonsterDifficulty difficulty = MonsterDifficulty.easy,
  int unitCount = 1,
  String? collectedBy,
  bool withLair = true,
  CellContentType content = CellContentType.monsterLair,
  Map<UnitType, int> stock = const {},
  String playerId = 'test-uuid',
  int militaryResearchLevel = 0,
}) {
  final Player player = buildFightTestPlayer(
    id: playerId,
    stock: stock,
    militaryResearchLevel: militaryResearchLevel,
  );
  final Game game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    gameMap: buildFightTestMap(
      difficulty: difficulty,
      unitCount: unitCount,
      collectedBy: collectedBy,
      withLair: withLair,
      content: content,
    ),
  );
  return (game: game, player: player);
}
