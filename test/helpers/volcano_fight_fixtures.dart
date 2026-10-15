import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// The top left cell of the volcano of [volcanoFightGame].
const volcanoFightCell = (11, 10);
const _side = 20;

/// A lone player beside a free volcano, an admiral and breakers ready.
Game volcanoFightGame() {
  final cells = List.generate(
      _side * _side, (_) => MapCell(terrain: TerrainType.plain));
  for (var dy = 0; dy < 2; dy++) {
    for (var dx = 0; dx < 2; dx++) {
      final (x, y) = (volcanoFightCell.$1 + dx, volcanoFightCell.$2 + dy);
      cells[y * _side + x] = MapCell(
        terrain: TerrainType.plain,
        content: dx == 0 && dy == 0
            ? CellContentType.volcanicKernel
            : CellContentType.volcanicKernelPart,
      );
    }
  }
  final game = Game.singlePlayer(Player(
    name: 'Nemo',
    baseX: 7,
    baseY: 10,
    revealedCellsPerLevel: {1: [
      for (var y = 0; y < _side; y++)
        for (var x = 0; x < _side; x++) GridPosition(x: x, y: y),
    ]},
  ))
    ..levels = {1: GameMap(width: _side, height: _side, cells: cells, seed: 1)};
  final units = game.humanPlayer.unitsOnLevel(1);
  units[UnitType.abyssAdmiral]!.count = 1;
  units[UnitType.domeBreaker]!.count = 30;
  return game;
}
