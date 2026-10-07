import 'package:flutter/material.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import '../../../domain/tech/tech_cost_calculator.dart';
import '../../../domain/tech/tech_node_state.dart';
import '../../extensions/tech_branch_extensions.dart';
import 'tech_branch_medallion.dart';
import 'tech_connector.dart';
import 'tech_node_widget.dart';

/// One column of the research tree: the branch emblem followed by its
/// research nodes, linked by a current that lights up as they complete.
class TechBranchLane extends StatelessWidget {
  final TechBranch branch;
  final TechBranchState? state;
  final int labLevel;
  final VoidCallback onBranchTap;
  final void Function(int level) onNodeTap;

  const TechBranchLane({
    super.key,
    required this.branch,
    required this.state,
    required this.labLevel,
    required this.onBranchTap,
    required this.onNodeTap,
  });

  bool get _unlocked => state?.unlocked ?? false;

  @override
  Widget build(BuildContext context) {
    final color = branch.color;
    return Column(
      children: [
        TechBranchMedallion(
          iconPath: branch.iconPath,
          name: branch.displayName,
          color: color,
          unlocked: _unlocked,
          onTap: onBranchTap,
        ),
        for (var level = 1;
            level <= TechCostCalculator.maxResearchLevel;
            level++) ...[
          TechConnector(
            color: color,
            lit: nodeState(level) == TechNodeState.researched,
            primed: nodeState(level) == TechNodeState.accessible,
          ),
          TechNodeWidget(
            color: color,
            state: nodeState(level),
            label: '+${branch.bonusPercent(level)}%',
            caption: _caption(level),
            onTap: () => onNodeTap(level),
          ),
        ],
      ],
    );
  }

  String _caption(int level) {
    final reqLab = TechCostCalculator.requiredLabLevel(level);
    final researched = nodeState(level) == TechNodeState.researched;
    if (!researched && labLevel < reqLab) return 'Labo $reqLab';
    return 'Niv. $level';
  }

  TechNodeState nodeState(int level) {
    final s = state;
    if (s == null || !s.unlocked) return TechNodeState.locked;
    if (level <= s.researchLevel) return TechNodeState.researched;
    final reqLab = TechCostCalculator.requiredLabLevel(level);
    if (level == s.researchLevel + 1 && labLevel >= reqLab) {
      return TechNodeState.accessible;
    }
    return TechNodeState.locked;
  }
}
