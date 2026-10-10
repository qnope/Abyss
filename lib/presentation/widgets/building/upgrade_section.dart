import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_cost_calculator.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/map/transition_base_type.dart';
import '../../../domain/raid/noise_rules.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/worksite/worksite.dart';
import '../../extensions/building_type_extensions.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../extensions/transition_base_type_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../raid/noise_cost_row.dart';
import '../resource/resource_icon.dart';

class UpgradeSection extends StatelessWidget {
  final Building building;
  final Map<ResourceType, Resource> resources;
  final Map<BuildingType, Building> allBuildings;
  final Worksite worksite;
  final Set<TransitionBaseType> capturedBaseTypes;
  final bool isVolcanicKernelCaptured;
  final int discountPercent;
  final VoidCallback onUpgrade;

  const UpgradeSection({
    super.key,
    required this.building,
    required this.resources,
    required this.allBuildings,
    required this.worksite,
    this.capturedBaseTypes = const {},
    this.isVolcanicKernelCaptured = false,
    this.discountPercent = 0,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final calculator =
        BuildingCostCalculator(discountPercent: discountPercent);
    final check = calculator.checkUpgrade(
      type: building.type,
      currentLevel: building.level,
      resources: resources,
      allBuildings: allBuildings,
      capturedBaseTypes: capturedBaseTypes,
      isVolcanicKernelCaptured: isVolcanicKernelCaptured,
    );
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final hqLevel = allBuildings[BuildingType.headquarters]?.level ?? 0;
    final siteFree = worksite.freeBuildSites(hqLevel) > 0;

    if (check.isMaxLevel) {
      return Text(
        l10n.baseMaxLevel,
        style: textTheme.bodyMedium?.copyWith(color: AbyssColors.disabled),
      );
    }

    final costs = calculator.upgradeCost(building.type, building.level);
    final prereqs = calculator.prerequisites(
      building.type,
      building.level + 1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.baseUpgradeLevels(building.level, building.level + 1),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...costs.entries.map((e) => _costRow(e.key, e.value, l10n)),
        NoiseCostRow(
            noise: NoiseRules.forUpgrade(building.type, building.level + 1)),
        ...prereqs.entries.map((e) => _prereqRow(e.key, e.value, l10n)),
        if (check.missingCapturedBase != null)
          _capturedBaseRow(check.missingCapturedBase!, l10n),
        if (check.missingCapturedKernel)
          _lockedRow(l10n.baseKernelRequired),
        if (!siteFree) _lockedRow(l10n.baseWorksitesBusy),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: check.canUpgrade && siteFree ? onUpgrade : null,
          child: Text(
            building.level == 0 ? l10n.baseBuild : l10n.baseUpgrade,
          ),
        ),
      ],
    );
  }

  Widget _costRow(ResourceType type, int required, AppLocalizations l10n) {
    final available = resources[type]?.amount ?? 0;
    return _row(ResourceIcon(type: type, size: 16), type.displayName(l10n),
        '$available/$required', met: available >= required);
  }

  Widget _prereqRow(BuildingType type, int level, AppLocalizations l10n) {
    final met = (allBuildings[type]?.level ?? 0) >= level;
    return _row(Icon(Icons.lock, size: 16, color: _color(met)),
        type.displayName(l10n), l10n.baseLevelShort(level), met: met);
  }

  Widget _capturedBaseRow(TransitionBaseType type, AppLocalizations l10n) =>
      _lockedRow(l10n.baseCapturedBaseRequired(type.displayName(l10n)));

  Widget _lockedRow(String label) => _row(
    const Icon(Icons.lock, size: 16, color: AbyssColors.error),
    label,
    null,
    met: false,
  );

  static Color _color(bool met) =>
      met ? AbyssColors.onSurface : AbyssColors.error;

  /// A requirement: its icon, its [label] and, at the end, its [amount],
  /// in red until [met].
  Widget _row(Widget icon, String label, String? amount, {required bool met}) {
    final style = TextStyle(color: _color(met));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: style)),
          if (amount != null) Text(amount, style: style),
        ],
      ),
    );
  }
}
