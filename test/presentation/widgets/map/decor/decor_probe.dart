import 'package:abyss/presentation/widgets/map/decor/map_decor.dart';
import 'package:abyss/presentation/widgets/map/map_cell_size.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';

/// The foot of [decor] on the flat map, in cells.
(double, double) flatFootOf(MapDecor decor) {
  final flat = MapProjection.toFlat(decor.foot) / cellSize;
  return (flat.dx, flat.dy);
}

/// Whether [value] is a whole number, but for rounding.
bool isWhole(double value) => (value - value.round()).abs() < 1e-6;

/// The cells whose diamond the foot of [decor] lies on: four around a
/// corner, two along an edge, one inside a cell.
Set<(int, int)> cellsTouchedBy(MapDecor decor) {
  final (fx, fy) = flatFootOf(decor);
  List<int> around(double v) =>
      isWhole(v) ? [v.round() - 1, v.round()] : [v.floor()];
  return {
    for (final x in around(fx))
      for (final y in around(fy)) (x, y),
  };
}
