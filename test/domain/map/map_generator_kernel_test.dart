import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('level 3 keeps its kernel and the base stays out of its footprint',
      () {
    var nudged = 0;
    for (var seed = 0; seed < 300; seed++) {
      final result = MapGenerator.generate(seed: seed, level: 3);
      expect(
        result.map.cellAt(10, 10).content,
        CellContentType.volcanicKernel,
        reason: 'seed=$seed',
      );
      final onFootprint = result.baseX >= 10 &&
          result.baseX <= 11 &&
          result.baseY >= 10 &&
          result.baseY <= 11;
      expect(onFootprint, isFalse, reason: 'seed=$seed');
      if (result.baseX == 9 || result.baseY == 9) nudged++;
    }
    expect(nudged, greaterThan(0));
  });

  test('level 3 maps carry the 2x2 footprint, other levels none', () {
    for (var seed = 0; seed < 100; seed++) {
      final map = MapGenerator.generate(seed: seed, level: 3).map;
      for (final (x, y) in [(11, 10), (10, 11), (11, 11)]) {
        expect(map.cellAt(x, y).content, CellContentType.volcanicKernelPart,
            reason: 'seed=$seed');
      }
      for (final level in [1, 2]) {
        final other = MapGenerator.generate(seed: seed, level: level).map;
        expect(
          other.cells.where((c) =>
              c.content == CellContentType.volcanicKernelPart),
          isEmpty,
        );
      }
    }
  });
}
