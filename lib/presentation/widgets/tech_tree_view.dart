import 'package:flutter/material.dart';
import '../../domain/building.dart';
import '../../domain/building_type.dart';
import '../../domain/resource.dart';
import '../../domain/resource_type.dart';
import '../../domain/tech_branch.dart';
import '../../domain/tech_branch_state.dart';
import '../../domain/tech_cost_calculator.dart';
import '../../domain/tech_node_state.dart';
import '../extensions/tech_branch_extensions.dart';
import '../theme/abyss_colors.dart';
import 'building_icon.dart';
import 'tech_node_widget.dart';

class TechTreeView extends StatelessWidget {
  final Map<TechBranch, TechBranchState> techBranches;
  final Map<BuildingType, Building> buildings;
  final Map<ResourceType, Resource> resources;
  final void Function(TechBranch branch) onBranchTap;
  final void Function(TechBranch branch, int level) onNodeTap;

  const TechTreeView({
    super.key,
    required this.techBranches,
    required this.buildings,
    required this.resources,
    required this.onBranchTap,
    required this.onNodeTap,
  });

  int get _labLevel => buildings[BuildingType.laboratory]?.level ?? 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          _buildRootNode(),
          _buildConnector(AbyssColors.biolumTeal),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: TechBranch.values
                .map((b) => _buildBranchColumn(b))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRootNode() {
    return BuildingIcon(
      type: BuildingType.laboratory,
      size: 48,
      greyscale: _labLevel == 0,
    );
  }

  Widget _buildConnector(Color color) {
    return Container(width: 2, height: 16, color: color);
  }

  Widget _buildBranchColumn(TechBranch branch) {
    final state = techBranches[branch];
    final branchColor = branch.color;

    return Column(
      children: [
        TechNodeWidget(
          iconPath: branch.iconPath,
          color: branchColor,
          state: _branchHeaderState(state),
          onTap: () => onBranchTap(branch),
        ),
        ...List.generate(
          TechCostCalculator.maxResearchLevel,
          (i) {
            final level = i + 1;
            return Column(
              children: [
                _buildConnector(
                  _nodeState(state, level) == TechNodeState.locked
                      ? AbyssColors.disabled
                      : branchColor,
                ),
                TechNodeWidget(
                  iconPath: branch.iconPath,
                  color: branchColor,
                  state: _nodeState(state, level),
                  level: level,
                  onTap: () => onNodeTap(branch, level),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  TechNodeState _branchHeaderState(TechBranchState? state) {
    if (state == null || !state.unlocked) return TechNodeState.locked;
    return TechNodeState.researched;
  }

  TechNodeState _nodeState(TechBranchState? state, int level) {
    if (state == null || !state.unlocked) return TechNodeState.locked;
    if (level <= state.researchLevel) return TechNodeState.researched;
    if (level == state.researchLevel + 1 && _labLevel >= level) {
      return TechNodeState.accessible;
    }
    return TechNodeState.locked;
  }
}
