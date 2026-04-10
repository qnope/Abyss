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
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

({Game game, Player player}) createDescendScenario({
  CellContentType transitionContent = CellContentType.transitionBase,
  String? capturedBy = 'test',
  int descentModuleLevel = 1,
  int scoutCount = 10,
}) {
  final cells = List.generate(
    100,
    (_) => MapCell(terrain: TerrainType.plain),
  );

  if (transitionContent == CellContentType.transitionBase) {
    cells[5 * 10 + 5] = MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.transitionBase,
      transitionBase: TransitionBase(
        type: TransitionBaseType.faille,
        name: 'Faille',
        capturedBy: capturedBy,
      ),
    );
  }

  final map = GameMap(width: 10, height: 10, cells: cells, seed: 42);

  final player = Player(
    id: 'test',
    name: 'Test',
    buildings: {
      BuildingType.descentModule: Building(
        type: BuildingType.descentModule,
        level: descentModuleLevel,
      ),
      BuildingType.pressureCapsule: Building(
        type: BuildingType.pressureCapsule,
        level: 0,
      ),
    },
    unitsPerLevel: {
      1: {
        for (final t in UnitType.values)
          t: Unit(type: t, count: t == UnitType.scout ? scoutCount : 0),
      },
    },
  );

  final game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    levels: {1: map},
  );

  return (game: game, player: player);
}
