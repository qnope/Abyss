import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base_placer.dart';
import '../../helpers/transition_base_helpers.dart';

void main() {
  const width = 20, height = 20, baseX = 10, baseY = 10;

  List<MapCell> makeCells() => List.generate(
        width * height,
        (_) => MapCell(terrain: TerrainType.plain),
      );

  group('TransitionBasePlacer reservedIndices', () {
    test('reserved indices are never chosen for placement', () {
      // First run without reservation to find where failles land.
      final baseline = makeCells();
      TransitionBasePlacer.place(
        cells: baseline, width: width, height: height,
        baseX: baseX, baseY: baseY, level: 1,
        random: Random(99),
      );
      final baselinePositions =
          transitionBaseIndices(baseline).toSet();
      expect(baselinePositions.length, 4);

      // Re-run with those positions reserved.
      final cells = makeCells();
      TransitionBasePlacer.place(
        cells: cells, width: width, height: height,
        baseX: baseX, baseY: baseY, level: 1,
        random: Random(99),
        reservedIndices: baselinePositions,
      );
      final newPositions = transitionBaseIndices(cells).toSet();
      expect(newPositions.length, 4);
      expect(
        newPositions.intersection(baselinePositions),
        isEmpty,
        reason: 'No transition base should land on a reserved index',
      );
    });
  });
}
