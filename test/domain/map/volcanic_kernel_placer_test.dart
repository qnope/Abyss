import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/volcanic_kernel_placer.dart';

void main() {
  List<MapCell> buildCells(int w, int h) {
    return List.generate(
      w * h,
      (_) => MapCell(terrain: TerrainType.plain),
    );
  }

  group('VolcanicKernelPlacer.place', () {
    test('places volcanicKernel at center index 210 on 20x20', () {
      final cells = buildCells(20, 20);
      VolcanicKernelPlacer.place(
        cells: cells,
        width: 20,
        height: 20,
      );
      expect(cells[210].content, CellContentType.volcanicKernel);
    });

    test('center cell (10,10) has volcanicKernel content', () {
      final cells = buildCells(20, 20);
      VolcanicKernelPlacer.place(
        cells: cells,
        width: 20,
        height: 20,
      );
      final centerX = 20 ~/ 2;
      final centerY = 20 ~/ 2;
      final cell = cells[centerY * 20 + centerX];
      expect(cell.content, CellContentType.volcanicKernel);
    });

    test('only one cell has volcanicKernel content', () {
      final cells = buildCells(20, 20);
      VolcanicKernelPlacer.place(
        cells: cells,
        width: 20,
        height: 20,
      );
      final count = cells
          .where((c) => c.content == CellContentType.volcanicKernel)
          .length;
      expect(count, 1);
    });
  });
}
