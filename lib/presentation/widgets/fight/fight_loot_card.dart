import 'package:flutter/material.dart';

import '../../../domain/resource/resource_type.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../resource/resource_icon.dart';
import 'fight_report_card.dart';

/// Resources won in a fight, or that there were none.
class FightLootCard extends StatelessWidget {
  final Map<ResourceType, int> loot;

  const FightLootCard({super.key, required this.loot});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final entries = loot.entries.where((e) => e.value != 0).toList();
    return FightReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.fightLoot,
            style:
                textTheme.titleMedium?.copyWith(color: AbyssColors.biolumCyan),
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Text(
              l10n.fightNoLoot,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AbyssColors.onSurfaceDim),
            )
          else
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  ResourceIcon(type: e.key, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${e.key.displayName(l10n)} +${e.value}',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AbyssColors.onSurface),
                  ),
                ]),
              ),
        ],
      ),
    );
  }
}
