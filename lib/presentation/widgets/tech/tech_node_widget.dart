import 'package:flutter/material.dart';
import '../../../domain/tech/tech_node_state.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';
import 'dashed_ring_painter.dart';

/// Round research node showing its icon. Researched nodes glow, the next
/// reachable one is ringed with dashes, locked ones fade away and the
/// option a choice left aside is greyed out and struck through.
class TechNodeWidget extends StatelessWidget {
  final Color color;
  final TechNodeState state;
  final String iconPath;
  final double size;
  final VoidCallback? onTap;

  const TechNodeWidget({
    super.key,
    required this.color,
    required this.state,
    required this.iconPath,
    this.size = 24,
    this.onTap,
  });

  bool get _lit =>
      state == TechNodeState.researched || state == TechNodeState.accessible;

  @override
  Widget build(BuildContext context) {
    final node = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: _decoration(),
      child: RasterSvg(
        assetPath: iconPath,
        size: size * 0.78,
        color: _lit ? null : _grey,
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: switch (state) {
        TechNodeState.accessible => CustomPaint(
          foregroundPainter: DashedRingPainter(color: color, dashCount: 10),
          child: node),
        TechNodeState.discarded => CustomPaint(
          foregroundPainter: _StrikePainter(), child: node),
        _ => node,
      },
    );
  }

  Color get _grey => state == TechNodeState.locked
      ? AbyssColors.dimmed(AbyssColors.disabled)
      : AbyssColors.disabled;

  BoxDecoration _decoration() => switch (state) {
    TechNodeState.researched => BoxDecoration(
      shape: BoxShape.circle,
      color: AbyssColors.surfaceDim,
      border: Border.all(color: color, width: 2),
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
    TechNodeState.locked || TechNodeState.discarded => BoxDecoration(
      shape: BoxShape.circle,
      color: AbyssColors.surfaceDim,
      border: Border.all(color: AbyssColors.surfaceBright, width: 1.5),
    ),
  };
}

/// Diagonal stroke across a node the player gave up.
class _StrikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.width * 0.2;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      Paint()
        ..color = AbyssColors.onSurfaceDim
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_StrikePainter oldDelegate) => false;
}
