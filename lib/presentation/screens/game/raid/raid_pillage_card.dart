import 'package:flutter/material.dart';

import '../../../../domain/resource/resource_type.dart';
import '../../../extensions/resource_type_extensions.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../theme/abyss_colors.dart';
import '../../../widgets/resource/resource_icon.dart';

/// Resources the monsters carried away after a lost raid.
class RaidPillageCard extends StatelessWidget {
  final Map<ResourceType, int> pillaged;

  const RaidPillageCard({super.key, required this.pillaged});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final entries = pillaged.entries.where((e) => e.value > 0).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.raidPillage,
              style: textTheme.titleMedium?.copyWith(color: AbyssColors.error),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              Text(
                l10n.raidNothingToLoot,
                style: textTheme.bodyMedium
                    ?.copyWith(color: AbyssColors.onSurfaceDim),
              ),
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  ResourceIcon(type: e.key, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${e.key.displayName(l10n)} -${e.value}',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AbyssColors.onSurface),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
