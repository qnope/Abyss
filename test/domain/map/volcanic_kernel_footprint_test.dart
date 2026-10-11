import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/volcanic_kernel_placer.dart';
import 'package:flutter_test/flutter_test.dart';

List<MapCell> _plain(int size) => List.generate(
      size * size,
      (_) => MapCell(terrain: TerrainType.plain),
    );

void main() {
  test('the kernel covers a 2x2 footprint anchored on the centre', () {
    const size = 21;
    final cells = _plain(size);
    VolcanicKernelPlacer.place(cells: cells, width: size, height: size);

    expect(cells[10 * size + 10].content, CellContentType.volcanicKernel);
    for (final i in [10 * size + 11, 11 * size + 10, 11 * size + 11]) {
      expect(cells[i].content, CellContentType.volcanicKernelPart);
    }
    final covered = cells
        .where((c) =>
            c.content == CellContentType.volcanicKernel ||
            c.content == CellContentType.volcanicKernelPart)
        .length;
    expect(covered, 4);
  });

  test('the footprint wipes lairs and transition bases it lands on', () {
    const size = 21;
    final cells = _plain(size);
    cells[11 * size + 11] =
        cells[11 * size + 11].copyWith(content: CellContentType.monsterLair);
    VolcanicKernelPlacer.place(cells: cells, width: size, height: size);

    expect(cells[11 * size + 11].content, CellContentType.volcanicKernelPart);
    expect(cells[11 * size + 11].lair, isNull);
  });

  test('footprint lists the four cells, anchor first', () {
    expect(
      VolcanicKernelPlacer.footprint(10, 10),
      [(10, 10), (11, 10), (10, 11), (11, 11)],
    );
  });
}
