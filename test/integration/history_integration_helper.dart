import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// Map layout used by the history integration scenario.
///
/// - 7x7 grid, plain terrain everywhere
/// - Base at (3, 3)
/// - Hidden cell available for exploration at (1, 5)
///   (chosen so it is NOT adjacent to the base: the player must first
///    reveal the intermediate cells OR we just pre-reveal a neighbour)
/// - resourceBonus at (4, 3) (adjacent to the base, pre-revealed)
/// - monsterLair at (2, 3) (adjacent to the base, pre-revealed)
GameMap buildHistoryScenarioMap() {
  final cells = <MapCell>[];
  for (var y = 0; y < 7; y++) {
    for (var x = 0; x < 7; x++) {
      if (x == 4 && y == 3) {
        cells.add(MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.resourceBonus,
        ));
      } else if (x == 2 && y == 3) {
        cells.add(MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.monsterLair,
          lair: const MonsterLair(
            difficulty: MonsterDifficulty.easy,
            unitCount: 1,
          ),
        ));
      } else {
        cells.add(MapCell(terrain: TerrainType.plain));
      }
    }
  }
  return GameMap(width: 7, height: 7, cells: cells, seed: 42);
}

/// Pre-reveal the full 7x7 map so every cell is eligible for collection
/// and fight actions. The explore action in the scenario targets a cell
/// that we deliberately *remove* from the revealed set right before the
/// explore step.
List<GridPosition> _fullyRevealed() {
  return <GridPosition>[
    for (var y = 0; y < 7; y++)
      for (var x = 0; x < 7; x++) GridPosition(x: x, y: y),
  ];
}

/// Builds a richly-seeded player that can afford every action in the
/// scenario: plenty of resources, a ready barracks / laboratory, and a
/// non-zero scout stock for exploration.
Player buildHistoryScenarioPlayer({String id = 'human-uuid'}) {
  final player = Player(
    id: id,
    name: 'Nemo',
    baseX: 3,
    baseY: 3,
    resources: {
      ResourceType.algae:
          Resource(type: ResourceType.algae, amount: 9999, maxStorage: 99999),
      ResourceType.coral:
          Resource(type: ResourceType.coral, amount: 9999, maxStorage: 99999),
      ResourceType.ore:
          Resource(type: ResourceType.ore, amount: 9999, maxStorage: 99999),
      ResourceType.energy:
          Resource(type: ResourceType.energy, amount: 9999, maxStorage: 99999),
      ResourceType.pearl:
          Resource(type: ResourceType.pearl, amount: 999, maxStorage: 9999),
    },
    buildings: {
      BuildingType.headquarters:
          Building(type: BuildingType.headquarters, level: 0),
      BuildingType.algaeFarm:
          Building(type: BuildingType.algaeFarm, level: 1),
      BuildingType.coralMine:
          Building(type: BuildingType.coralMine, level: 0),
      BuildingType.oreExtractor:
          Building(type: BuildingType.oreExtractor, level: 0),
      BuildingType.solarPanel:
          Building(type: BuildingType.solarPanel, level: 0),
      BuildingType.laboratory:
          Building(type: BuildingType.laboratory, level: 1),
      BuildingType.barracks:
          Building(type: BuildingType.barracks, level: 1),
    },
    unitsPerLevel: {1: {
      for (final type in UnitType.values)
        type: Unit(
          type: type,
          count: switch (type) {
            UnitType.scout => 3,
            UnitType.harpoonist => 15,
            _ => 0,
          },
        ),
    }},
    revealedCellsPerLevel: {1: _fullyRevealed()},
  );
  return player;
}

Game buildHistoryScenarioGame({String playerId = 'human-uuid'}) {
  final player = buildHistoryScenarioPlayer(id: playerId);
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    gameMap: buildHistoryScenarioMap(),
  );
}
