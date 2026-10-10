import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_degradation.dart';
import '../../../domain/building/building_type.dart';
import '../../extensions/building_degradation_texts.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// "Dégradé" marker of a building whose headquarters requirement is no
/// longer met. With [detail] it also says which level is missing and what
/// the building suffers.
class DegradedBadge extends StatelessWidget {
  final int requiredHeadquarters;
  final String? detail;

  const DegradedBadge({
    super.key,
    required this.requiredHeadquarters,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final Widget label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warning_amber, size: 14, color: AbyssColors.warning),
        const SizedBox(width: 4),
        Text(
          detail == null
              ? l10n.buildingDegraded
              : l10n.buildingDegradedReason(requiredHeadquarters),
          style: textTheme.bodySmall?.copyWith(color: AbyssColors.warning),
        ),
      ],
    );
    if (detail == null) return label;
    return Column(
      children: [
        label,
        const SizedBox(height: 4),
        Text(
          detail!,
          style: textTheme.bodySmall?.copyWith(color: AbyssColors.onSurfaceDim),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// The detailed [DegradedBadge] of [type] within [buildings]; nothing
/// when it is not degraded.
class DegradedNotice extends StatelessWidget {
  final BuildingType type;
  final Map<BuildingType, Building> buildings;

  const DegradedNotice({
    super.key,
    required this.type,
    required this.buildings,
  });

  @override
  Widget build(BuildContext context) {
    final int? missing = BuildingDegradation.missingHeadquarters(
      buildings,
      type,
    );
    if (missing == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DegradedBadge(
        requiredHeadquarters: missing,
        detail: type.degradedEffect(context.l10n),
      ),
    );
  }
}
