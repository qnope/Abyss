import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import 'tech_branch_lane.dart';
import 'tech_lab_header.dart';

/// Laboratory screen: a header summarising active bonuses above three
/// bioluminescent currents, one per research branch.
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Column(
        children: [
          TechLabHeader(labLevel: _labLevel, techBranches: techBranches),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final branch in TechBranch.values)
                Expanded(
                  child: TechBranchLane(
                    branch: branch,
                    state: techBranches[branch],
                    labLevel: _labLevel,
                    onBranchTap: () => onBranchTap(branch),
                    onNodeTap: (level) => onNodeTap(branch, level),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
