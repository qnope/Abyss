import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_visuals_builder.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _kernelSvg = 'assets/icons/terrain/volcanic_kernel.svg';

MapCell _anchor({String? collectedBy}) => MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.volcanicKernel,
      collectedBy: collectedBy,
    );

MapCell _part() => MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.volcanicKernelPart,
    );

GameMap _map({String? collectedBy}) {
  final map = GameMap(
    width: 6,
    height: 6,
    cells: List.generate(36, (_) => MapCell(terrain: TerrainType.plain)),
    seed: 1,
  );
  map.setCell(2, 2, _anchor(collectedBy: collectedBy));
  for (final (x, y) in [(3, 2), (2, 3), (3, 3)]) {
    map.setCell(x, y, _part());
  }
  return map;
}

void main() {
  group('MapCellVisual.from for the volcano', () {
    test('the anchor draws the volcano over a 2x2 span', () {
      final v = MapCellVisual.from(_anchor(), isRevealed: true);
      expect(v.contentSprite, _kernelSvg);
      expect(v.contentSpan, 2);
    });

    test('a captured volcano is never dimmed and wears its seal colour', () {
      final v = MapCellVisual.from(
        _anchor(collectedBy: 'me'),
        isRevealed: true,
        sealColor: AbyssColors.biolumCyan,
      );
      expect(v.dimmed, isFalse);
      expect(v.sealColor, AbyssColors.biolumCyan);
    });

    test('a free volcano has no seal', () {
      final v = MapCellVisual.from(_anchor(), isRevealed: true);
      expect(v.sealColor, isNull);
    });

    test('a part draws nothing of its own', () {
      final v = MapCellVisual.from(_part(), isRevealed: true);
      expect(v.contentSprite, isNull);
      expect(v.glow, MapGlow.none);
      expect(v.contentSpan, 1);
    });

    test('other content keeps a 1x1 span and no seal', () {
      final v = MapCellVisual.from(
        MapCell(terrain: TerrainType.plain, content: CellContentType.ruins),
        isRevealed: true,
      );
      expect(v.contentSpan, 1);
      expect(v.sealColor, isNull);
    });
  });

  group('buildMapVisuals for the volcano', () {
    List<MapCellVisual> build(Set<GridPosition> revealed,
            {String? collectedBy, Map<String, Color> colors = const {}}) =>
        buildMapVisuals(
          gameMap: _map(collectedBy: collectedBy),
          revealedCells: revealed,
          humanPlayerId: 'me',
          ownerColors: colors,
        );

    test('seeing one cell of the volcano reveals all four', () {
      final visuals = build({GridPosition(x: 3, y: 3)});
      for (final i in [2 * 6 + 2, 2 * 6 + 3, 3 * 6 + 2, 3 * 6 + 3]) {
        expect(visuals[i].revealed, isTrue, reason: 'cell $i');
      }
      expect(visuals[2 * 6 + 2].contentSprite, _kernelSvg);
      expect(visuals[0].revealed, isFalse);
    });

    test('the seal takes the colour of the player who holds the volcano', () {
      final visuals = build(
        {GridPosition(x: 2, y: 2)},
        collectedBy: 'rival',
        colors: {'me': AbyssColors.biolumCyan, 'rival': AbyssColors.biolumPurple},
      );
      expect(visuals[2 * 6 + 2].sealColor, AbyssColors.biolumPurple);
    });
  });
}
