import 'package:flutter/material.dart';

import '../../../domain/map/monster_family.dart';
import '../../extensions/monster_family_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// The rule of a monster family and the unit that answers it. Shows
/// nothing for the generic monsters of older games.
class MonsterFamilyTraits extends StatelessWidget {
  final MonsterFamily? family;

  const MonsterFamilyTraits({super.key, required this.family});

  @override
  Widget build(BuildContext context) {
    final String? rule = family.rule(context.l10n);
    final String? weakness = family.weakness(context.l10n);
    if (rule == null || weakness == null) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rule,
          style: textTheme.bodyMedium?.copyWith(color: AbyssColors.onSurface),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.gps_fixed, size: 16, color: AbyssColors.success),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Faible contre : $weakness',
                style: textTheme.bodyMedium?.copyWith(
                  color: AbyssColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
