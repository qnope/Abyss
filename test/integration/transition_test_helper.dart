import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

const int kMapSize = 5;
const int kFailleX = 2;
const int kFailleY = 2;

GameMap buildMapWithFaille({String? capturedBy}) {
  final cells = List.generate(
    kMapSize * kMapSize,
    (_) => MapCell(terrain: TerrainType.plain),
  );
  cells[kFailleY * kMapSize + kFailleX] = MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.transitionBase,
    transitionBase: TransitionBase(
      type: TransitionBaseType.faille,
      name: 'Faille Alpha',
      capturedBy: capturedBy,
    ),
  );
  return GameMap(
    width: kMapSize,
    height: kMapSize,
    cells: cells,
    seed: 42,
  );
}

Player buildRichPlayer({String id = 'player-1'}) {
  return Player(
    id: id,
    name: 'Nemo',
    resources: {
      ResourceType.algae: Resource(
        type: ResourceType.algae,
        amount: 9999,
        maxStorage: 99999,
      ),
      ResourceType.coral: Resource(
        type: ResourceType.coral,
        amount: 9999,
        maxStorage: 99999,
      ),
      ResourceType.ore: Resource(
        type: ResourceType.ore,
        amount: 9999,
        maxStorage: 99999,
      ),
      ResourceType.energy: Resource(
        type: ResourceType.energy,
        amount: 9999,
        maxStorage: 99999,
      ),
      ResourceType.pearl: Resource(
        type: ResourceType.pearl,
        amount: 999,
        maxStorage: 9999,
      ),
    },
    buildings: {
      for (final t in BuildingType.values)
        t: Building(type: t, level: 0),
    },
    unitsPerLevel: {
      1: {
        for (final t in UnitType.values)
          t: Unit(type: t, count: 0),
      },
    },
  );
}

({Game game, Player player}) buildTransitionScenario() {
  final player = buildRichPlayer();
  player.buildings[BuildingType.descentModule]!.level = 1;
  player.buildings[BuildingType.barracks]!.level = 5;
  player.buildings[BuildingType.algaeFarm]!.level = 3;
  player.buildings[BuildingType.solarPanel]!.level = 3;

  player.unitsOnLevel(1)[UnitType.abyssAdmiral]!.count = 1;
  player.unitsOnLevel(1)[UnitType.domeBreaker]!.count = 30;
  player.unitsOnLevel(1)[UnitType.scout]!.count = 10;

  final map = buildMapWithFaille();
  final game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    levels: {1: map},
  );

  return (game: game, player: player);
}
