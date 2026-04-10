import 'dart:math';
import 'cell_content_type.dart';
import 'map_cell.dart';
import 'transition_base.dart';
import 'transition_base_type.dart';

class TransitionBasePlacer {
  static const _failleNames = [
    'Faille Alpha', 'Faille Beta',
    'Faille Gamma', 'Faille Delta',
  ];
  static const _chemineeNames = [
    'Cheminee Primaire', 'Cheminee Secondaire',
    'Cheminee Tertiaire',
  ];

  static void place({
    required List<MapCell> cells,
    required int width,
    required int height,
    required int baseX,
    required int baseY,
    required int level,
    required Random random,
  }) {
    if (level == 1) {
      _placeAll(
        cells, width, height, baseX, baseY, random,
        _buildQuadrants(width, height),
        TransitionBaseType.faille, _failleNames, 8, 5,
      );
    } else if (level == 2) {
      _placeAll(
        cells, width, height, baseX, baseY, random,
        List.filled(3, _outerEdgeCells(width, height)),
        TransitionBaseType.cheminee, _chemineeNames, 10, 5,
      );
    }
  }

  static void _placeAll(
    List<MapCell> cells,
    int width, int height, int baseX, int baseY,
    Random random, List<List<int>> candidateSets,
    TransitionBaseType type, List<String> names,
    int minCenterDist, int minSpacing,
  ) {
    final centerX = width ~/ 2, centerY = height ~/ 2;
    final placed = <int>[];
    for (var i = 0; i < names.length; i++) {
      final idx = _pickCell(
        candidateSets[i], width, centerX, centerY,
        baseX, baseY, minCenterDist, minSpacing, placed, random,
      );
      if (idx != null) {
        cells[idx] = cells[idx].copyWith(
          content: CellContentType.transitionBase,
          transitionBase: TransitionBase(type: type, name: names[i]),
        );
        placed.add(idx);
      }
    }
  }

  static int? _pickCell(
    List<int> candidates, int width,
    int centerX, int centerY, int baseX, int baseY,
    int minCenterDist, int minSpacing,
    List<int> placed, Random random,
  ) {
    for (var spacing = minSpacing; spacing >= 0; spacing--) {
      final valid = candidates.where((idx) {
        final x = idx % width, y = idx ~/ width;
        if (x == baseX && y == baseY) return false;
        if (_chebyshev(x, y, centerX, centerY) < minCenterDist) {
          return false;
        }
        return _spacingOk(idx, width, placed, spacing);
      }).toList();
      if (valid.isEmpty) continue;
      return valid[random.nextInt(valid.length)];
    }
    return null;
  }

  static bool _spacingOk(
    int idx, int width, List<int> placed, int minDist,
  ) {
    final x = idx % width, y = idx ~/ width;
    for (final p in placed) {
      if (_chebyshev(x, y, p % width, p ~/ width) < minDist) {
        return false;
      }
    }
    return true;
  }

  static int _chebyshev(int x1, int y1, int x2, int y2) =>
      max((x1 - x2).abs(), (y1 - y2).abs());

  static List<List<int>> _buildQuadrants(int w, int h) {
    final half = w ~/ 2;
    final lists = [<int>[], <int>[], <int>[], <int>[]];
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        lists[(x < half ? 0 : 1) + (y < half ? 0 : 2)].add(y * w + x);
      }
    }
    return lists;
  }

  static List<int> _outerEdgeCells(int w, int h) {
    final result = <int>{};
    for (var x = 0; x < w; x++) {
      result..add(x)..add((h - 1) * w + x);
    }
    for (var y = 0; y < h; y++) {
      result..add(y * w)..add(y * w + w - 1);
    }
    return result.toList();
  }
}
