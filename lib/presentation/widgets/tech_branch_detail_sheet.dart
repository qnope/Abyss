import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/building.dart';
import '../../domain/building_type.dart';
import '../../domain/resource.dart';
import '../../domain/resource_type.dart';
import '../../domain/tech_branch.dart';
import '../../domain/tech_branch_state.dart';
import '../../domain/tech_cost_calculator.dart';
import '../extensions/resource_type_extensions.dart';
import '../extensions/tech_branch_extensions.dart';
import '../theme/abyss_colors.dart';
import 'resource_icon.dart';

void showTechBranchDetailSheet(
  BuildContext context, {
  required TechBranch branch,
  required TechBranchState state,
  required Map<ResourceType, Resource> resources,
  required Map<BuildingType, Building> buildings,
  required VoidCallback onUnlock,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TechBranchSheet(
      branch: branch, state: state,
      resources: resources, buildings: buildings, onUnlock: onUnlock,
    ),
  );
}

class _TechBranchSheet extends StatelessWidget {
  final TechBranch branch;
  final TechBranchState state;
  final Map<ResourceType, Resource> resources;
  final Map<BuildingType, Building> buildings;
  final VoidCallback onUnlock;

  const _TechBranchSheet({
    required this.branch, required this.state,
    required this.resources, required this.buildings,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final check = TechCostCalculator.checkUnlock(
      branch: branch, resources: resources,
      buildings: buildings, techBranches: {branch: state},
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(branch.iconPath, width: 64, height: 64),
          const SizedBox(height: 12),
          Text(branch.displayName,
            style: textTheme.headlineSmall?.copyWith(color: branch.color)),
          const SizedBox(height: 8),
          Text(branch.description,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim),
            textAlign: TextAlign.center),
          const Divider(height: 24),
          if (state.unlocked)
            Text('Branche débloquée \u2713',
              style: textTheme.bodyLarge?.copyWith(
                color: AbyssColors.success))
          else
            _buildUnlockSection(textTheme, check),
        ],
      ),
    );
  }

  Widget _buildUnlockSection(TextTheme textTheme, dynamic check) {
    final labLevel = buildings[BuildingType.laboratory]?.level ?? 0;
    if (labLevel < 1) {
      return Text(
        'Construisez un laboratoire pour débloquer cette branche',
        style: textTheme.bodyMedium?.copyWith(color: AbyssColors.error),
        textAlign: TextAlign.center,
      );
    }
    final costs = TechCostCalculator.unlockCost(branch);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...costs.entries.map((e) => _costRow(e.key, e.value)),
        _prereqRow(labLevel),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: check.canAct ? onUnlock : null,
          child: const Text('Débloquer'),
        ),
      ],
    );
  }

  Widget _costRow(ResourceType type, int required) {
    final available = resources[type]?.amount ?? 0;
    final color =
        available >= required ? AbyssColors.onSurface : AbyssColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        ResourceIcon(type: type, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(type.displayName, style: TextStyle(color: color))),
        Text('$available/$required', style: TextStyle(color: color)),
      ]),
    );
  }

  Widget _prereqRow(int labLevel) {
    final color =
        labLevel >= 1 ? AbyssColors.onSurface : AbyssColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(Icons.lock, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Laboratoire', style: TextStyle(color: color))),
        Text('Niv. 1', style: TextStyle(color: color)),
      ]),
    );
  }
}
