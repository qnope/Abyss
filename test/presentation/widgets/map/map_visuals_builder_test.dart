import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/widgets/map/map_scatter.dart';
import 'package:abyss/presentation/widgets/map/map_visuals_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/map_tab_harness.dart';

void main() {
  test('each cell is floored with the tile of its position', () {
    final visuals = buildMapVisuals(
      gameMap: plainMap(),
      revealedCells: {},
      humanPlayerId: 'me',
    );
    for (var y = 0; y < harnessMapSize; y++) {
      for (var x = 0; x < harnessMapSize; x++) {
        expect(visuals[y * harnessMapSize + x].terrainSprite,
            floorTileOf(TerrainType.plain, (x, y)),
            reason: '($x, $y)');
      }
    }
  });
}
