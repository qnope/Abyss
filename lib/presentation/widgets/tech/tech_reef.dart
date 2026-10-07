import 'package:flutter/material.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import '../../../domain/tech/tech_cost_calculator.dart';
import '../../../domain/tech/tech_node_state.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../building/building_icon.dart';
import 'tech_branch_medallion.dart';
import 'tech_node_widget.dart';
import 'tech_reef_geometry.dart';
import 'tech_reef_painter.dart';
import 'tech_target.dart';

/// Radial research tree: the laboratory in the centre and the three
/// branches radiating out like a sonar, one ring per research level.
class TechReef extends StatelessWidget {
  final Map<TechBranch, TechBranchState> techBranches;
  final int labLevel;
  final ValueChanged<TechTarget> onTap;

  const TechReef({
    super.key,
    required this.techBranches,
    required this.labLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final g = TechReefGeometry(constraints.biggest);
      return Stack(children: [
        Positioned.fill(child: CustomPaint(
          painter: TechReefPainter(
            techBranches: techBranches, labLevel: labLevel))),
        _at(g.center, _lab()),
        for (final branch in TechBranch.values) ...[
          for (var l = 1; l <= TechCostCalculator.maxResearchLevel; l++)
            _at(g.node(branch, l), _node(branch, l, g.nodeSize)),
          _medallion(g, branch),
        ],
      ]);
    });
  }

  Widget _at(Offset center, Widget child) => Positioned(
    left: center.dx,
    top: center.dy,
    child: FractionalTranslation(
      translation: const Offset(-0.5, -0.5), child: child),
  );

  Widget _lab() => Container(
    width: TechReefGeometry.labRadius * 2,
    height: TechReefGeometry.labRadius * 2,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AbyssColors.surfaceLight,
      border: Border.all(
        color: labLevel > 0 ? AbyssColors.biolumTeal : AbyssColors.disabled,
        width: 2),
    ),
    child: BuildingIcon(
      type: BuildingType.laboratory, size: 40, greyscale: labLevel == 0),
  );

  Widget _node(TechBranch branch, int level, double size) {
    return TechNodeWidget(
      color: branch.color,
      state: nodeState(branch, level),
      label: '$level',
      size: size,
      onTap: () => onTap(TechTarget(branch, level)),
    );
  }

  Widget _medallion(TechReefGeometry g, TechBranch branch) {
    final state = techBranches[branch];
    final unlocked = state?.unlocked ?? false;
    final level = state?.researchLevel ?? 0;
    final above = branch == TechBranch.military;
    final shift = above ? -18.0 : 18.0;
    return _at(
      g.medallion(branch) + Offset(0, shift),
      TechBranchMedallion(
        iconPath: branch.iconPath,
        label: branch.displayName,
        detail: unlocked ? '+${branch.bonusPercent(level)}%' : null,
        color: branch.color,
        unlocked: unlocked,
        labelAbove: above,
        size: TechReefGeometry.medallionRadius * 2,
        onTap: () => onTap(TechTarget(branch)),
      ),
    );
  }

  TechNodeState nodeState(TechBranch branch, int level) {
    final s = techBranches[branch];
    if (s == null || !s.unlocked) return TechNodeState.locked;
    if (level <= s.researchLevel) return TechNodeState.researched;
    final reqLab = TechCostCalculator.requiredLabLevel(level);
    if (level == s.researchLevel + 1 && labLevel >= reqLab) {
      return TechNodeState.accessible;
    }
    return TechNodeState.locked;
  }
}
