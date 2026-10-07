import 'package:flutter/material.dart';
import '../../theme/abyss_colors.dart';

/// Vertical light current linking two nodes of a tree. A [lit] current
/// glows in [color]; a [primed] one is a dim hint of the next step.
class TechConnector extends StatelessWidget {
  final Color color;
  final bool lit;
  final bool primed;
  final double height;

  const TechConnector({
    super.key,
    required this.color,
    this.lit = false,
    this.primed = false,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    final fill = lit
        ? color
        : primed
            ? color.withValues(alpha: 0.45)
            : AbyssColors.trench;
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(2),
        boxShadow: lit
            ? [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 8)]
            : null,
      ),
    );
  }
}
