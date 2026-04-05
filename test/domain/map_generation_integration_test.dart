import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/cell_content_type.dart';
import 'package:abyss/domain/map_generator.dart';
import 'package:abyss/domain/terrain_type.dart';

void main() {
  group('Map generation integration', () {
    test('seed reproducibility', () {
      final a = MapGenerator.generate(seed: 777);
      final b = MapGenerator.generate(seed: 777);
      expect(a.playerBaseX, b.playerBaseX);
      expect(a.playerBaseY, b.playerBaseY);
      for (var i = 0; i < 400; i++) {
        expect(a.cells[i].terrain, b.cells[i].terrain);
        expect(a.cells[i].content, b.cells[i].content);
        expect(a.cells[i].isRevealed, b.cells[i].isRevealed);
        expect(a.cells[i].monsterDifficulty, b.cells[i].monsterDifficulty);
      }
    });

    for (var seed = 0; seed < 10; seed++) {
      test('full constraints check (seed $seed)', () {
        final map = MapGenerator.generate(seed: seed);

        expect(map.cells.length, 400);
        expect((map.playerBaseX - 10).abs(), lessThanOrEqualTo(2));
        expect((map.playerBaseY - 10).abs(), lessThanOrEqualTo(2));

        // Base neighbors are reef or plain
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final cell = map.cellAt(map.playerBaseX + dx, map.playerBaseY + dy);
            expect(
              cell.terrain == TerrainType.reef ||
              cell.terrain == TerrainType.plain,
              isTrue,
            );
          }
        }

        // 25 revealed cells
        final revealed = map.cells.where((c) => c.isRevealed).length;
        expect(revealed, 25);

        // 5-10 monster lairs
        final lairs = map.cells
            .where((c) => c.content == CellContentType.monsterLair)
            .length;
        expect(lairs, greaterThanOrEqualTo(5));
        expect(lairs, lessThanOrEqualTo(10));

        // Base zone empty of content
        for (var dy = -2; dy <= 2; dy++) {
          for (var dx = -2; dx <= 2; dx++) {
            final x = map.playerBaseX + dx;
            final y = map.playerBaseY + dy;
            if (x < 0 || x >= 20 || y < 0 || y >= 20) continue;
            expect(map.cellAt(x, y).content, CellContentType.empty);
          }
        }

        // Rock cells have no content
        for (final cell in map.cells) {
          if (cell.terrain == TerrainType.rock) {
            expect(cell.content, CellContentType.empty);
          }
        }

        // Connectivity: all 4 edges reachable
        _verifyConnectivity(map);
      });
    }
  });
}

void _verifyConnectivity(dynamic map) {
  final visited = List.filled(400, false);
  final queue = [(map.playerBaseX as int, map.playerBaseY as int)];
  visited[map.playerBaseY * 20 + map.playerBaseX] = true;
  while (queue.isNotEmpty) {
    final (cx, cy) = queue.removeAt(0);
    for (final (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
      final nx = cx + dx, ny = cy + dy;
      if (nx < 0 || nx >= 20 || ny < 0 || ny >= 20) continue;
      final idx = ny * 20 + nx;
      if (visited[idx]) continue;
      if (map.cellAt(nx, ny).terrain == TerrainType.rock) continue;
      visited[idx] = true;
      queue.add((nx, ny));
    }
  }
  final topReachable = List.generate(20, (x) => visited[x]).any((v) => v);
  final bottomReachable =
      List.generate(20, (x) => visited[19 * 20 + x]).any((v) => v);
  final leftReachable =
      List.generate(20, (y) => visited[y * 20]).any((v) => v);
  final rightReachable =
      List.generate(20, (y) => visited[y * 20 + 19]).any((v) => v);
  expect(topReachable, isTrue, reason: 'Top edge unreachable');
  expect(bottomReachable, isTrue, reason: 'Bottom edge unreachable');
  expect(leftReachable, isTrue, reason: 'Left edge unreachable');
  expect(rightReachable, isTrue, reason: 'Right edge unreachable');
}
