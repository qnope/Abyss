import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import '../../../domain/tech/tech_cost_calculator.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../resource/resource_icon.dart';

void showTechNodeDetailSheet(
  BuildContext context, {
  required TechBranch branch,
  required int level,
  required TechBranchState state,
  required Map<ResourceType, Resource> resources,
  required Map<BuildingType, Building> buildings,
  required VoidCallback onResearch,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TechNodeSheet(
      branch: branch, level: level, state: state,
      resources: resources, buildings: buildings, onResearch: onResearch,
    ),
  );
}

class _TechNodeSheet extends StatelessWidget {
  final TechBranch branch;
  final int level;
  final TechBranchState state;
  final Map<ResourceType, Resource> resources;
  final Map<BuildingType, Building> buildings;
  final VoidCallback onResearch;

  const _TechNodeSheet({
    required this.branch, required this.level, required this.state,
    required this.resources, required this.buildings,
    required this.onResearch,
  });

  String get _bonusText => switch (branch) {
    TechBranch.military => '+${level * 20}% attaque et défense',
    TechBranch.resources => '+${level * 20}% production de ressources',
    TechBranch.explorer => '+${level * 20}% portée d\'exploration',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = branch.color;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(branch.iconPath, width: 64, height: 64),
          const SizedBox(height: 12),
          Text('${branch.displayName} — Niveau $level',
            style: textTheme.headlineSmall?.copyWith(color: color)),
          const SizedBox(height: 8),
          Text('Bonus: $_bonusText',
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim)),
          const Divider(height: 24),
          _buildBody(textTheme),
        ],
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    if (level <= state.researchLevel) {
      return Text('Recherche complétée \u2713',
        style: textTheme.bodyLarge?.copyWith(color: AbyssColors.success));
    }
    if (level == state.researchLevel + 1) {
      return _buildResearchSection(textTheme);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Recherchez d\'abord le niveau ${level - 1}',
        style: textTheme.bodyMedium?.copyWith(
          color: AbyssColors.onSurfaceDim),
        textAlign: TextAlign.center),
      const SizedBox(height: 12),
      const ElevatedButton(onPressed: null, child: Text('Rechercher')),
    ]);
  }

  Widget _buildResearchSection(TextTheme textTheme) {
    final check = TechCostCalculator.checkResearch(
      branch: branch, targetLevel: level,
      resources: resources, buildings: buildings,
      techBranches: {branch: state},
    );
    final costs = TechCostCalculator.researchCost(branch, level);
    final labLevel = buildings[BuildingType.laboratory]?.level ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...costs.entries.map((e) => _costRow(e.key, e.value)),
        _prereqRow(labLevel),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: check.canAct ? onResearch : null,
          child: const Text('Rechercher'),
        ),
      ],
    );
  }

  Widget _costRow(ResourceType type, int required) {
    final available = resources[type]?.amount ?? 0;
    final c = available >= required ? AbyssColors.onSurface : AbyssColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        ResourceIcon(type: type, size: 16), const SizedBox(width: 8),
        Expanded(child: Text(type.displayName, style: TextStyle(color: c))),
        Text('$available/$required', style: TextStyle(color: c)),
      ]),
    );
  }

  Widget _prereqRow(int labLevel) {
    final reqLab = TechCostCalculator.requiredLabLevel(level);
    final c = labLevel >= reqLab ? AbyssColors.onSurface : AbyssColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(Icons.lock, size: 16, color: c), const SizedBox(width: 8),
        Expanded(child: Text('Laboratoire', style: TextStyle(color: c))),
        Text('Niv. $reqLab', style: TextStyle(color: c)),
      ]),
    );
  }
}
