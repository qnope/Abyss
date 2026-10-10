import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../extensions/building_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'building_icon.dart';

class BuildingCard extends StatelessWidget {
  final Building building;
  final VoidCallback onTap;

  const BuildingCard({
    super.key,
    required this.building,
    required this.onTap,
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
        BuildingIcon(
          type: building.type,
          size: 40,
          greyscale: !_isBuilt,
          faded: !_isBuilt,
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
                  ? 'Niveau ${building.level}'
                  : 'Non construit',
              style: textTheme.bodySmall?.copyWith(
                color: _isBuilt
                    ? AbyssColors.onSurfaceDim
                    : AbyssColors.dimmed(AbyssColors.disabled),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
