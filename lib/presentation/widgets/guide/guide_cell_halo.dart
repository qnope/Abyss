import 'package:flutter/widgets.dart';

import 'guide_halo.dart';
import 'guide_scope.dart';

/// The guide's halo around its target cell, laid in the [Stack] of a map
/// of [level] over the box [boxOf] gives that cell. Shows nothing when
/// the target has no cell on this level.
class GuideCellHalo extends StatelessWidget {
  final int level;

  /// The box of a cell in the stack, such as the box of its diamond.
  final Rect Function((int, int) cell) boxOf;

  const GuideCellHalo({
    super.key,
    required this.level,
    required this.boxOf,
  });

  @override
  Widget build(BuildContext context) {
    final target = GuideScope.of(context);
    final cell = target?.cell;
    if (cell == null || target?.level != level) {
      return const Positioned(left: 0, top: 0, child: SizedBox.shrink());
    }
    return Positioned.fromRect(
      rect: boxOf((cell.x, cell.y)),
      child: const IgnorePointer(
        child: GuideHalo(active: true, radius: 6, child: SizedBox.expand()),
      ),
    );
  }
}
