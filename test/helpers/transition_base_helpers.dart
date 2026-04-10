import 'dart:math';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';

/// Extracts the indices of all cells that contain a transition base.
List<int> transitionBaseIndices(List<MapCell> cells) => [
      for (var i = 0; i < cells.length; i++)
        if (cells[i].content == CellContentType.transitionBase) i,
    ];

/// Chebyshev distance between two grid positions.
int chebyshev(int x1, int y1, int x2, int y2) =>
    max((x1 - x2).abs(), (y1 - y2).abs());
