import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../extensions/building_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'degraded_badge.dart';
import 'lively_building_icon.dart';

class BuildingCard extends StatelessWidget {
  final Building building;
  final VoidCallback onTap;

  /// Headquarters level the building is missing; `null` unless degraded.
  final int? missingHeadquarters;

  const BuildingCard({
    super.key,
    required this.building,
    required this.onTap,
    this.missingHeadquarters,
  });

  bool get _isBuilt => building.level > 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = _buildContent(context, textTheme);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: content,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        LivelyBuildingIcon(
          type: building.type,
          level: building.level,
          active: missingHeadquarters == null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              building.type.displayName(context.l10n),
              style: textTheme.titleMedium?.copyWith(
                color: _isBuilt
                    ? building.type.color
                    : AbyssColors.dimmed(AbyssColors.onSurface),
              ),
            ),
            Text(
              _isBuilt
                  ? context.l10n.baseLevel(building.level)
                  : context.l10n.baseNotBuilt,
              style: textTheme.bodySmall?.copyWith(
                color: _isBuilt
                    ? AbyssColors.onSurfaceDim
                    : AbyssColors.dimmed(AbyssColors.disabled),
              ),
            ),
            if (missingHeadquarters != null)
              DegradedBadge(requiredHeadquarters: missingHeadquarters!),
          ],
        ),
      ],
    );
  }
}
