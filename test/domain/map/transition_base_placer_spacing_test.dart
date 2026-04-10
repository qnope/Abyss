import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base_placer.dart';
import '../../helpers/transition_base_helpers.dart';

void main() {
  const width = 20, height = 20, baseX = 10, baseY = 10;
  const centerX = width ~/ 2, centerY = height ~/ 2;

  List<MapCell> makeCells() => List.generate(
        width * height,
        (_) => MapCell(terrain: TerrainType.plain),
      );

  List<(int x, int y)> placeAndGetPositions(int level, int seed) {
    final cells = makeCells();
    TransitionBasePlacer.place(
      cells: cells, width: width, height: height,
      baseX: baseX, baseY: baseY, level: level,
      random: Random(seed),
    );
    return transitionBaseIndices(cells)
        .map((i) => (i % width, i ~/ width))
        .toList();
  }

  group('Level 1 faille quadrants', () {
    test('each quadrant has exactly 1 faille', () {
      for (var seed = 0; seed < 20; seed++) {
        final positions = placeAndGetPositions(1, seed);
        final half = width ~/ 2;
        final quadrants = <int>[0, 0, 0, 0];
        for (final (x, y) in positions) {
          quadrants[(x < half ? 0 : 1) + (y < half ? 0 : 2)]++;
        }
        for (var q = 0; q < 4; q++) {
          expect(quadrants[q], 1,
              reason: 'seed=$seed quadrant=$q');
        }
      }
    });
  });

  group('Level 1 faille distances', () {
    test('all failles at Chebyshev distance > 8 from center', () {
      for (var seed = 0; seed < 20; seed++) {
        for (final (x, y) in placeAndGetPositions(1, seed)) {
          expect(
            chebyshev(x, y, centerX, centerY),
            greaterThanOrEqualTo(8),
            reason: 'seed=$seed faille at ($x,$y)',
          );
        }
      }
    });

    test('minimum spacing of 5 between failles', () {
      for (var seed = 0; seed < 20; seed++) {
        final positions = placeAndGetPositions(1, seed);
        for (var i = 0; i < positions.length; i++) {
          for (var j = i + 1; j < positions.length; j++) {
            final (x1, y1) = positions[i];
            final (x2, y2) = positions[j];
            expect(
              chebyshev(x1, y1, x2, y2),
              greaterThanOrEqualTo(5),
              reason: 'seed=$seed ($x1,$y1)-($x2,$y2)',
            );
          }
        }
      }
    });
  });

  group('Level 2 cheminee distances', () {
    test('all cheminees at Chebyshev distance > 10 from center',
        () {
      for (var seed = 0; seed < 20; seed++) {
        for (final (x, y) in placeAndGetPositions(2, seed)) {
          expect(
            chebyshev(x, y, centerX, centerY),
            greaterThanOrEqualTo(10),
            reason: 'seed=$seed cheminee at ($x,$y)',
          );
        }
      }
    });

    test('minimum spacing of 5 between cheminees', () {
      for (var seed = 0; seed < 20; seed++) {
        final positions = placeAndGetPositions(2, seed);
        for (var i = 0; i < positions.length; i++) {
          for (var j = i + 1; j < positions.length; j++) {
            final (x1, y1) = positions[i];
            final (x2, y2) = positions[j];
            expect(
              chebyshev(x1, y1, x2, y2),
              greaterThanOrEqualTo(5),
              reason: 'seed=$seed ($x1,$y1)-($x2,$y2)',
            );
          }
        }
      }
    });
  });
}
