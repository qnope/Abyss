import 'package:flutter/material.dart';
import '../../../domain/tech/tech_node_state.dart';
import '../../theme/abyss_colors.dart';
import 'dashed_ring_painter.dart';

/// Small round research node. Researched nodes are filled and glow, the
/// next reachable one is ringed with dashes and locked ones fade away.
class TechNodeWidget extends StatelessWidget {
  final Color color;
  final TechNodeState state;
  final String label;
  final double size;
  final VoidCallback? onTap;

  const TechNodeWidget({
    super.key,
    required this.color,
    required this.state,
    required this.label,
    this.size = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final node = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: _decoration(),
      child: Text(label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: size * 0.5,
          height: 1,
          fontWeight: FontWeight.w800,
          color: _labelColor)),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: state == TechNodeState.accessible
          ? CustomPaint(
              foregroundPainter: DashedRingPainter(color: color, dashCount: 8),
              child: node)
          : node,
    );
  }

  BoxDecoration _decoration() => switch (state) {
      TechNodeState.researched => BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 10),
        ],
      ),
      TechNodeState.accessible => BoxDecoration(
        shape: BoxShape.circle,
        color: AbyssColors.surfaceDim,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), spreadRadius: 3),
        ],
      ),
      TechNodeState.locked => BoxDecoration(
        shape: BoxShape.circle,
        color: AbyssColors.surfaceDim,
        border: Border.all(color: AbyssColors.surfaceBright, width: 1.5),
      ),
    };

  Color get _labelColor => switch (state) {
    TechNodeState.researched => AbyssColors.abyssBlack,
    TechNodeState.accessible => color,
    TechNodeState.locked => AbyssColors.onSurfaceDim,
  };
}
