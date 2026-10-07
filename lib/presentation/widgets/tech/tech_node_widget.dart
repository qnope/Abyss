import 'package:flutter/material.dart';
import '../../../domain/tech/tech_node_state.dart';
import '../../theme/abyss_colors.dart';
import 'dashed_ring_painter.dart';

/// Round research node showing its reward ([label]) and a short
/// [caption]. Researched nodes glow, the next reachable one is ringed
/// with dashes and locked ones fade into the background.
class TechNodeWidget extends StatelessWidget {
  final Color color;
  final TechNodeState state;
  final String label;
  final String caption;
  final double size;
  final VoidCallback? onTap;

  const TechNodeWidget({
    super.key,
    required this.color,
    required this.state,
    required this.label,
    required this.caption,
    this.size = 56,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final node = Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: _decoration(),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(children: [
          Text(label,
            style: textTheme.labelLarge?.copyWith(
              color: _labelColor, fontWeight: FontWeight.w800)),
          Text(caption,
            style: textTheme.labelSmall?.copyWith(
              color: _captionColor, fontSize: 9)),
        ]),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: state == TechNodeState.accessible
          ? CustomPaint(
              foregroundPainter: DashedRingPainter(color: color),
              child: node)
          : node,
    );
  }

  BoxDecoration _decoration() => switch (state) {
    TechNodeState.researched => BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [
        color.withValues(alpha: 0.45),
        color.withValues(alpha: 0.12),
      ]),
      border: Border.all(color: color, width: 2),
      boxShadow: [
        BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 14),
      ],
    ),
    TechNodeState.accessible => BoxDecoration(
      shape: BoxShape.circle,
      color: AbyssColors.surfaceLight,
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.18), spreadRadius: 6),
      ],
    ),
    TechNodeState.locked => BoxDecoration(
      shape: BoxShape.circle,
      color: AbyssColors.surfaceDim,
      border: Border.all(color: AbyssColors.surfaceBright),
    ),
  };

  Color get _labelColor => switch (state) {
    TechNodeState.researched => Colors.white,
    TechNodeState.accessible => color,
    TechNodeState.locked => AbyssColors.disabled,
  };

  Color get _captionColor => switch (state) {
    TechNodeState.researched => AbyssColors.onSurface,
    TechNodeState.accessible => color,
    TechNodeState.locked => AbyssColors.onSurfaceDim,
  };
}
