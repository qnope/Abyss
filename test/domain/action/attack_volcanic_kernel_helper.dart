import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

({Game game, Player player}) createKernelScenario({
  String? collectedBy,
  Map<UnitType, int> stock = const {},
  CellContentType content = CellContentType.volcanicKernel,
  int level = 3,
}) {
  final cells = List.generate(
    25,
    (_) => MapCell(terrain: TerrainType.plain),
  );

  cells[1 * 5 + 1] = MapCell(
    terrain: TerrainType.plain,
    content: content,
    collectedBy: collectedBy,
  );

  final map = GameMap(width: 5, height: 5, cells: cells, seed: 42);

  final unitsForLevel = <UnitType, Unit>{
    for (final t in UnitType.values)
      t: Unit(type: t, count: stock[t] ?? 0),
  };

  final player = Player(
    id: 'test-uuid',
    name: 'Test',
    buildings: {
      for (final t in BuildingType.values)
        t: Building(type: t, level: 0),
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
