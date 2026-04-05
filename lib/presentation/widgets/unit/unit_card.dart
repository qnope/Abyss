import 'package:flutter/material.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import 'unit_icon.dart';

class UnitCard extends StatelessWidget {
  final UnitType unitType;
  final int count;
  final bool isUnlocked;
  final VoidCallback onTap;

  const UnitCard({
    super.key,
    required this.unitType,
    required this.count,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = _buildContent(textTheme);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child:
              isUnlocked ? content : Opacity(opacity: 0.5, child: content),
        ),
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    return Row(
      children: [
        UnitIcon(
          type: unitType,
          size: 40,
          greyscale: !isUnlocked,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unitType.displayName,
              style: textTheme.titleMedium?.copyWith(
                color: isUnlocked ? unitType.color : null,
              ),
            ),
            if (isUnlocked)
              Text(
                '$count unites',
                style: textTheme.bodySmall?.copyWith(
                  color: AbyssColors.onSurfaceDim,
                ),
              )
            else
              Row(
                children: [
                  const Icon(
                    Icons.lock,
                    size: 14,
                    color: AbyssColors.disabled,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Verrouille',
                    style: textTheme.bodySmall?.copyWith(
                      color: AbyssColors.disabled,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
