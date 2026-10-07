import 'dart:math' as math;
import 'dart:ui';

import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_cost_calculator.dart';

/// Layout of the radial research reef: the laboratory in the centre and
/// one spoke per branch, each research level sitting on its own ring.
class TechReefGeometry {
  static const labRadius = 30.0;
  static const medallionRadius = 26.0;
  static const _labelSpace = 36.0;
  static const _spread = 45 * math.pi / 180;

  final Size size;
  static const _margin = medallionRadius + _labelSpace;

  late final double spokeLength = math.max(0, math.min(
    (size.width / 2 - 46) / math.cos(_spread),
    (size.height - 2 * _margin) / (1 + math.sin(_spread)),
  ));
  late final Offset center = Offset(
    size.width / 2,
    (size.height - spokeLength * (1 + math.sin(_spread))) / 2 + spokeLength,
  );

  TechReefGeometry(this.size);

  double get _firstRing => labRadius + 16;
  double get _lastRing => spokeLength - medallionRadius - 14;

  double get ringStep =>
      (_lastRing - _firstRing) / (TechCostCalculator.maxResearchLevel - 1);

  /// Diameter of a research node, kept smaller than the ring spacing.
  double get nodeSize => (ringStep - 4).clamp(12, 30);

  double ringRadius(int level) => _firstRing + (level - 1) * ringStep;

  double angle(TechBranch branch) => switch (branch) {
    TechBranch.military => -math.pi / 2,
    TechBranch.resources => _spread,
    TechBranch.explorer => math.pi - _spread,
  };

  Offset along(TechBranch branch, double radius) =>
      center + Offset.fromDirection(angle(branch), radius);

  Offset node(TechBranch branch, int level) =>
      along(branch, ringRadius(level));

  Offset medallion(TechBranch branch) => along(branch, spokeLength);
}
