import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import '../../../domain/tech/tech_check.dart';
import '../../../domain/tech/tech_cost_calculator.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../theme/abyss_colors.dart';
import 'tech_cost_row.dart';
import 'tech_target.dart';

/// Content of the popup opened from the reef: the tapped branch or node,
/// its bonus, cost or blocker, and the button to unlock or research it.
class TechTargetPanel extends StatelessWidget {
  final TechTarget target;
  final Map<TechBranch, TechBranchState> techBranches;
  final Map<BuildingType, Building> buildings;
  final Map<ResourceType, Resource> resources;
  final VoidCallback onAct;

  const TechTargetPanel({
    super.key,
    required this.target,
    required this.techBranches,
    required this.buildings,
    required this.resources,
    required this.onAct,
  });

  TechBranch get _branch => target.branch;
  int? get _level => target.level;
  TechBranchState? get _state => techBranches[_branch];
  bool get _done => _level == null
      ? _state?.unlocked ?? false
      : _level! <= (_state?.researchLevel ?? 0);

  TechCheck get _check => _level == null
      ? TechCostCalculator.checkUnlock(branch: _branch,
          resources: resources, buildings: buildings,
          techBranches: techBranches)
      : TechCostCalculator.checkResearch(branch: _branch,
          targetLevel: _level!, resources: resources, buildings: buildings,
          techBranches: techBranches);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = _branch.color;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AbyssColors.surfaceLight,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_title,
                style: text.titleMedium?.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(_subtitle,
                style: text.bodySmall?.copyWith(
                  color: AbyssColors.onSurfaceDim)),
              const SizedBox(height: 6),
              _status(text),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (!_done) ElevatedButton(
          onPressed: _check.canAct ? onAct : null,
          child: Text(_level == null ? 'Débloquer' : 'Rechercher'),
        ),
      ]),
    );
  }

  String get _title => _level == null
      ? _branch.displayName
      : '${_branch.displayName} · Niveau $_level';

  String get _subtitle => _level == null
      ? _branch.description
      : '+${_branch.bonusPercent(_level!)}% ${_branch.shortEffect}';

  Widget _status(TextTheme text) {
    final reason = _blocker;
    if (_done || reason != null) {
      return Text(_done ? 'Acquis ✓' : reason!,
        style: text.labelLarge?.copyWith(
          color: _done ? AbyssColors.success : AbyssColors.warning));
    }
    final costs = _level == null
        ? TechCostCalculator.unlockCost(_branch)
        : TechCostCalculator.researchCost(_branch, _level!);
    return TechCostRow(costs: costs, resources: resources);
  }

  String? get _blocker {
    final check = _check;
    if (check.branchLocked) return 'Débloquez d\'abord la branche';
    if (check.previousNodeMissing) {
      return 'Recherchez d\'abord le niveau ${_level! - 1}';
    }
    if (check.currentLabLevel < check.requiredLabLevel) {
      return 'Laboratoire niveau ${check.requiredLabLevel} requis';
    }
    return null;
  }
}
