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

({Game game, Player player}) createAttackScenario({
  TransitionBaseType baseType = TransitionBaseType.faille,
  String? capturedBy,
  int descentModuleLevel = 1,
  int pressureCapsuleLevel = 0,
  Map<UnitType, int> stock = const {},
  CellContentType content = CellContentType.transitionBase,
  bool withTransitionBase = true,
  int level = 1,
}) {
  final cells = List.generate(
    25,
    (_) => MapCell(terrain: TerrainType.plain),
  );

  if (withTransitionBase) {
    cells[1 * 5 + 1] = MapCell(
      terrain: TerrainType.plain,
      content: content,
      transitionBase: TransitionBase(
        type: baseType,
        name: baseType == TransitionBaseType.faille ? 'Faille' : 'Cheminée',
        capturedBy: capturedBy,
      ),
    );
  }

  final map = GameMap(width: 5, height: 5, cells: cells, seed: 42);

  final unitsForLevel = <UnitType, Unit>{
    for (final t in UnitType.values)
      t: Unit(type: t, count: stock[t] ?? 0),
  };

  final player = Player(
    id: 'test-uuid',
    name: 'Test',
    buildings: {
      ...PlayerBuildings.defaults(),
      BuildingType.descentModule: Building(
        type: BuildingType.descentModule,
        level: descentModuleLevel,
      ),
      BuildingType.pressureCapsule: Building(
        type: BuildingType.pressureCapsule,
        level: pressureCapsuleLevel,
      ),
    },
    unitsPerLevel: {level: unitsForLevel},
  );

  final game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    levels: {level: map},
  );

  return (game: game, player: player);
}

class PlayerBuildings {
  static Map<BuildingType, Building> defaults() => {
        for (final t in BuildingType.values)
          t: Building(type: t, level: 0),
      };
}
