import 'package:flutter/material.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import 'unit_icon.dart';

class UnitCard extends StatelessWidget {
  final UnitType unitType;
  final Map<int, int> countsPerLevel;
  final bool isUnlocked;
  final VoidCallback onTap;

  const UnitCard({
    super.key,
    required this.unitType,
    required this.countsPerLevel,
    required this.isUnlocked,
    required this.onTap,
  });

  int get _totalCount =>
      countsPerLevel.values.fold(0, (a, b) => a + b);

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

  String get _subtitle {
    final nonEmpty = countsPerLevel.entries
        .where((e) => e.value > 0)
        .toList();
    if (nonEmpty.length <= 1) return '$_totalCount unites';
    return nonEmpty
        .map((e) => 'Niv ${e.key}: ${e.value}')
        .join(' · ');
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
                _subtitle,
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
