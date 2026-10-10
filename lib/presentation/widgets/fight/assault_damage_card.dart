import 'package:flutter/material.dart';

import '../../../domain/history/history_entry.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'fight_report_card.dart';

/// What a won assault broke in the base: the rampart, or the
/// headquarters when there was none. Says the base held when nothing
/// broke.
class AssaultDamageCard extends StatelessWidget {
  final BaseAssaultEntry entry;

  const AssaultDamageCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = <String>[
      if (entry.rampartAfter != entry.rampartBefore)
        l10n.assaultRampart(entry.rampartBefore, entry.rampartAfter),
      if (entry.headquartersAfter != entry.headquartersBefore)
        l10n.assaultHeadquarters(
          entry.headquartersBefore,
          entry.headquartersAfter,
        ),
    ];
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AbyssColors.onSurface,
    );
    return FightReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines.isEmpty ? [l10n.assaultBaseIntact] : lines)
            Text(line, style: style),
        ],
      ),
    );
  }
}
