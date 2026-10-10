import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';

/// A single-player game whose volcano level holds the kernel, captured
/// by the human when [captured], with [onVolcano] scouts on the volcano
/// level and [garrisoned] scouts already inside the kernel.
Game kernelGarrisonGame({
  bool captured = true,
  int onVolcano = 3,
  int garrisoned = 0,
}) {
  final player = Player(
    name: 'Nemo',
    unitsPerLevel: {
      KernelGarrison.volcanoLevel: {
        UnitType.scout: Unit(type: UnitType.scout, count: onVolcano),
      },
      KernelGarrison.stockKey: {
        UnitType.scout: Unit(type: UnitType.scout, count: garrisoned),
      },
    },
  );
  return Game.singlePlayer(player)
    ..levels = {
      KernelGarrison.volcanoLevel: GameMap(
        width: 1,
        height: 1,
        seed: 0,
        cells: [
          MapCell(
            terrain: TerrainType.plain,
            content: CellContentType.volcanicKernel,
            collectedBy: captured ? player.id : null,
          ),
        ],
      ),
    };
}

/// Scouts of [game]'s human on the volcano level.
int scoutsOnVolcano(Game game) => game.humanPlayer
    .unitsOnLevel(KernelGarrison.volcanoLevel)[UnitType.scout]!
    .count;
