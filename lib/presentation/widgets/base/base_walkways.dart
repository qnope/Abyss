import 'dart:ui';

import '../../../domain/building/building_type.dart';
import 'base_layout.dart';

/// A straight leg of walkway on the ground of the base, in cells.
typedef BaseWalkway = (Offset from, Offset to);

/// The lit walkways from the headquarters to every [built] building of
/// [layout], none before the headquarters stands.
///
/// Each one is an L along the grid axes: first along the longer side of
/// the way, then along the other; a building in line with the
/// headquarters gets a single leg.
List<BaseWalkway> baseWalkways(
  BaseLayout layout,
  Iterable<BuildingType> built,
) {
  const hq = BuildingType.headquarters;
  final reached = built.toSet();
  if (!reached.contains(hq)) return const [];
  final start = layout.slotOf(hq).centre;
  return [
    for (final type in layout.drawOrder)
      if (type != hq && reached.contains(type))
        ..._lOf(start, layout.slotOf(type).centre),
  ];
}

/// The legs from [from] to [to], the longer side first.
List<BaseWalkway> _lOf(Offset from, Offset to) {
  final delta = to - from;
  final corner = delta.dx.abs() > delta.dy.abs()
      ? Offset(to.dx, from.dy)
      : Offset(from.dx, to.dy);
  return [
    if (corner != from) (from, corner),
    if (corner != to) (corner, to),
  ];
}
