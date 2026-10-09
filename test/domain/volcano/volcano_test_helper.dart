import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';

/// Player whose kernel stands at [kernelLevel], with [garrison] in it and
/// [onVolcano] on the volcano level.
Player volcanoPlayer({
  int kernelLevel = 1,
  Map<UnitType, int> garrison = const {},
  Map<UnitType, int> onVolcano = const {},
}) {
  final player = Player(id: 'p1', name: 'Test');
  player.buildings[BuildingType.volcanicKernel]!.level = kernelLevel;
  final stock = KernelGarrison.stockOf(player);
  garrison.forEach((type, count) => stock[type]!.count = count);
  final volcano = KernelGarrison.stockAt(player, KernelGarrison.volcanoLevel);
  onVolcano.forEach((type, count) => volcano[type]!.count = count);
  return player;
}

/// Game of [player] whose level 3 holds the kernel, captured by
/// [player] unless [captured] is false.
Game volcanoGame(Player player, {bool captured = true}) => Game(
  humanPlayerId: player.id,
  players: {player.id: player},
  levels: {
    3: GameMap(
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
  },
);
