import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import '../../../domain/tech/tech_check.dart';
import '../../../domain/tech/tech_cost_calculator.dart';
import '../../../domain/tech/tech_option.dart';
import '../../../domain/tech/tech_tree.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../theme/abyss_colors.dart';
import 'tech_choice_row.dart';
import 'tech_cost_row.dart';
import 'tech_target.dart';
import 'tech_target_header.dart';

/// Content of the popup opened from the reef: the tapped branch or node,
/// its effect, cost or blocker, and the button to unlock or research it.
/// A choice node shows its two options side by side.
class TechTargetPanel extends StatelessWidget {
  final TechTarget target;
  final Map<TechBranch, TechBranchState> techBranches;
  final Map<BuildingType, Building> buildings;
  final Map<ResourceType, Resource> resources;
  final bool researchDone;
  final ValueChanged<TechOption> onAct;

  const TechTargetPanel({
    super.key,
    required this.target,
    required this.techBranches,
    required this.buildings,
    required this.resources,
    this.researchDone = false,
    required this.onAct,
  });

  TechBranch get _branch => target.branch;
  int? get _level => target.level;
  TechBranchState? get _state => techBranches[_branch];
  int get _opened => TechCostCalculator.openedBranches(techBranches);
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

  bool get _canAct => !_done && _check.canAct && _blocker == null;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final level = _level;
    final choice = level != null && TechTree.isChoiceLevel(level);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AbyssColors.surfaceLight,
        border: Border.all(color: _branch.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TechTargetHeader(branch: _branch, level: level,
            onAct: choice || _done ? null : () => onAct(TechOption.a),
            canAct: _canAct),
          if (choice) ...[
            const SizedBox(height: 10),
            TechChoiceRow(branch: _branch, level: level,
              taken: _state?.optionAt(level),
              onChoose: _canAct ? onAct : null),
          ],
          const SizedBox(height: 8),
          _status(text),
        ],
      ),
    );
  }

  Widget _status(TextTheme text) {
    final reason = _blocker;
    if (_done || reason != null) {
      return Text(_done ? 'Acquis ✓' : reason!,
        style: text.labelLarge?.copyWith(
          color: _done ? AbyssColors.success : AbyssColors.warning));
    }
    final costs = _level == null
        ? TechCostCalculator.unlockCost(_branch, opened: _opened)
        : TechCostCalculator.researchCost(_branch, _level!, opened: _opened);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TechCostRow(costs: costs, resources: resources),
        if (_level == null && _opened > 0) ...[
          const SizedBox(height: 6),
          Text(_surcharge,
            style: text.bodySmall?.copyWith(color: AbyssColors.warning)),
        ],
      ],
    );
  }

  String get _surcharge {
    final factor = TechCostCalculator.costPercent(_opened + 1) / 100;
    final shown = factor.toStringAsFixed(1).replaceAll('.', ',');
    return 'Toutes les recherches coûteront ×$shown une fois '
        'cette branche ouverte.';
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
    if (_level != null && researchDone) {
      return 'Une recherche par tour : attendez le prochain tour';
    }
    return null;
  }
}
