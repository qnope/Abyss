import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/volcano_footprint.dart';
import 'package:flutter_test/flutter_test.dart';

GameMap _map({bool withParts = true}) {
  final map = GameMap(
    width: 21,
    height: 21,
    cells: List.generate(441, (_) => MapCell(terrain: TerrainType.plain)),
    seed: 1,
  );
  map.setCell(10, 10,
      map.cellAt(10, 10).copyWith(content: CellContentType.volcanicKernel));
  if (withParts) {
    for (final (x, y) in [(11, 10), (10, 11), (11, 11)]) {
      map.setCell(x, y,
          map.cellAt(x, y).copyWith(content: CellContentType.volcanicKernelPart));
    }
  }
  return map;
}

void main() {
  group('anchorOf', () {
    test('each of the four cells resolves to the anchor', () {
      final map = _map();
      for (final (x, y) in [(10, 10), (11, 10), (10, 11), (11, 11)]) {
        expect(VolcanoFootprint.anchorOf(map, x, y),
            GridPosition(x: 10, y: 10), reason: '($x,$y)');
      }
    });

    test('any other cell has no anchor', () {
      final map = _map();
      expect(VolcanoFootprint.anchorOf(map, 9, 10), isNull);
      expect(VolcanoFootprint.anchorOf(map, 12, 12), isNull);
    });

    test('a part with no anchor beside it resolves to nothing', () {
      final map = _map(withParts: false);
      map.setCell(15, 15,
          map.cellAt(15, 15).copyWith(content: CellContentType.volcanicKernelPart));
      expect(VolcanoFootprint.anchorOf(map, 15, 15), isNull);
    });
  });

  group('tapTarget', () {
    test('a tap on any part targets the anchor', () {
      final map = _map();
      final target = VolcanoFootprint.tapTarget(map, {}, 11, 11);
      expect(target.position, GridPosition(x: 10, y: 10));
    });

    test('the volcano counts as seen when any of its cells is', () {
      final map = _map();
      final seen = {GridPosition(x: 11, y: 11)};
      expect(VolcanoFootprint.tapTarget(map, seen, 10, 10).isRevealed, isTrue);
      expect(VolcanoFootprint.tapTarget(map, {}, 10, 10).isRevealed, isFalse);
    });

    test('another cell targets itself and keeps its own visibility', () {
      final map = _map();
      final seen = {GridPosition(x: 3, y: 3)};
      final target = VolcanoFootprint.tapTarget(map, seen, 3, 3);
      expect(target.position, GridPosition(x: 3, y: 3));
      expect(target.isRevealed, isTrue);
      expect(VolcanoFootprint.tapTarget(map, seen, 4, 4).isRevealed, isFalse);
    });
  });

  group('revealWhole', () {
    test('seeing one part reveals the anchor and the other parts', () {
      final map = _map();
      final player = Player(name: 'p')
        ..addRevealedCell(3, GridPosition(x: 11, y: 11));
      VolcanoFootprint.revealWhole(map, player, 3);
      expect(
        player.revealedCellsSetOnLevel(3),
        {
          for (final (x, y) in [(10, 10), (11, 10), (10, 11), (11, 11)])
            GridPosition(x: x, y: y),
        },
      );
    });

    test('a volcano out of sight stays hidden', () {
      final map = _map();
      final player = Player(name: 'p')
        ..addRevealedCell(3, GridPosition(x: 1, y: 1));
      VolcanoFootprint.revealWhole(map, player, 3);
      expect(player.revealedCellsOnLevel(3), hasLength(1));
    });
  });

  group('completeLegacy', () {
    test('grows a 1x1 kernel saved before the footprint to 2x2', () {
      final map = _map(withParts: false);
      VolcanoFootprint.completeLegacy(map);
      for (final (x, y) in [(11, 10), (10, 11), (11, 11)]) {
        expect(map.cellAt(x, y).content, CellContentType.volcanicKernelPart);
      }
    });

    test('wipes the lair or base a part lands on', () {
      final map = _map(withParts: false);
      map.setCell(11, 11,
          map.cellAt(11, 11).copyWith(content: CellContentType.ruins));
      VolcanoFootprint.completeLegacy(map);
      expect(map.cellAt(11, 11).content, CellContentType.volcanicKernelPart);
    });

    test('leaves a passage or a wreck beside the kernel alone', () {
      final map = _map(withParts: false);
      map.setCell(11, 10,
          map.cellAt(11, 10).copyWith(content: CellContentType.passage));
      map.setCell(10, 11,
          map.cellAt(10, 11).copyWith(content: CellContentType.wreck));
      VolcanoFootprint.completeLegacy(map);
      expect(map.cellAt(11, 10).content, CellContentType.passage);
      expect(map.cellAt(10, 11).content, CellContentType.wreck);
      expect(map.cellAt(11, 11).content, CellContentType.volcanicKernelPart);
    });

    test('leaves a complete footprint and maps without a kernel alone', () {
      final map = _map();
      VolcanoFootprint.completeLegacy(map);
      expect(
        map.cells.where((c) => c.content == CellContentType.volcanicKernelPart),
        hasLength(3),
      );
      final plain = GameMap(
        width: 5, height: 5,
        cells: List.generate(25, (_) => MapCell(terrain: TerrainType.plain)),
        seed: 1,
      );
      VolcanoFootprint.completeLegacy(plain);
      expect(plain.cells.every((c) => c.content == CellContentType.empty),
          isTrue);
    });
  });

  test('migrate completes the volcano on every level of a game', () {
    final map = _map(withParts: false);
    final game = Game(
      humanPlayerId: 'p',
      players: {'p': Player(id: 'p', name: 'p')},
      levels: {3: map},
    );
    VolcanoFootprint.migrate(game);
    expect(map.cellAt(11, 11).content, CellContentType.volcanicKernelPart);
  });
}
