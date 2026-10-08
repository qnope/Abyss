import 'dart:math' as math;
import 'dart:ui';

import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_cost_calculator.dart';
import '../../../domain/tech/tech_option.dart';

/// Layout of the radial research reef: the laboratory in the centre and
/// one spoke per branch, each research level sitting on its own ring.
class TechReefGeometry {
  static const labRadius = 30.0;
  static const medallionRadius = 26.0;
  static const _labelSpace = 36.0;
  static const _spread = 60 * math.pi / 180;

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
  double get nodeSize => (ringStep - 8).clamp(16, 42);

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

  /// One of the twin nodes of a choice level, set side by side across
  /// the spoke: option A on the left of the current, B on the right.
  Offset twin(TechBranch branch, int level, TechOption option) {
    final side = option == TechOption.a ? -1 : 1;
    return node(branch, level) + Offset.fromDirection(
      angle(branch) + math.pi / 2, side * nodeSize * 0.6);
  }

  Offset medallion(TechBranch branch) => along(branch, spokeLength);
}
