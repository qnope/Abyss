import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import '../../../domain/tech/tech_cost_calculator.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../theme/abyss_colors.dart';
import 'tech_reef_geometry.dart';

/// Background of the research reef: sonar rings (solid up to the lab
/// level, dashed beyond), a halo around the lab and one current per
/// branch lit up to its research level.
class TechReefPainter extends CustomPainter {
  final Map<TechBranch, TechBranchState> techBranches;
  final int labLevel;

  const TechReefPainter({required this.techBranches, required this.labLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final g = TechReefGeometry(size);
    _paintHalo(canvas, g);
    _paintRings(canvas, g);
    for (final branch in TechBranch.values) {
      _paintSpoke(canvas, g, branch);
    }
  }

  void _paintHalo(Canvas canvas, TechReefGeometry g) {
    final r = TechReefGeometry.labRadius * 2.2;
    canvas.drawCircle(g.center, r, Paint()
      ..shader = RadialGradient(colors: [
        AbyssColors.biolumTeal.withValues(alpha: 0.3),
        AbyssColors.biolumTeal.withValues(alpha: 0),
      ]).createShader(Rect.fromCircle(center: g.center, radius: r)));
  }

  void _paintRings(Canvas canvas, TechReefGeometry g) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AbyssColors.trench;
    for (var l = 1; l <= TechCostCalculator.maxResearchLevel; l++) {
      final radius = g.ringRadius(l);
      if (l <= labLevel) {
        canvas.drawCircle(g.center, radius, paint);
      } else {
        _dashedCircle(canvas, g.center, radius, paint);
      }
    }
    if (labLevel < 1) return;
    final reached = math.min(labLevel, TechCostCalculator.maxResearchLevel);
    canvas.drawCircle(g.center, g.ringRadius(reached), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AbyssColors.biolumTeal.withValues(alpha: 0.45));
  }

  void _dashedCircle(Canvas canvas, Offset c, double r, Paint paint) {
    final count = (r / 4).round();
    final step = 2 * math.pi / count;
    final rect = Rect.fromCircle(center: c, radius: r);
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * step, step * 0.45, false, paint);
    }
  }

  void _paintSpoke(Canvas canvas, TechReefGeometry g, TechBranch branch) {
    final start = g.along(branch, TechReefGeometry.labRadius);
    final end = g.along(
      branch, g.spokeLength - TechReefGeometry.medallionRadius);
    canvas.drawLine(start, end, Paint()
      ..color = AbyssColors.trench
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round);
    final state = techBranches[branch];
    if (state == null || !state.unlocked || state.researchLevel == 0) return;
    final lit = g.node(branch, state.researchLevel);
    final color = branch.color;
    canvas.drawLine(start, lit, Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawLine(start, lit, Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(TechReefPainter oldDelegate) => true;
}
