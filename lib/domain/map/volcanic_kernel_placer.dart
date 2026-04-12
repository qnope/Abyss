import 'cell_content_type.dart';
import 'map_cell.dart';

class VolcanicKernelPlacer {
  static void place({
    required List<MapCell> cells,
    required int width,
    required int height,
  }) {
    final centerX = width ~/ 2;
    final centerY = height ~/ 2;
    final index = centerY * width + centerX;
    cells[index] = cells[index].copyWith(
      content: CellContentType.volcanicKernel,
      lair: null,
      transitionBase: null,
    );
  }
}
