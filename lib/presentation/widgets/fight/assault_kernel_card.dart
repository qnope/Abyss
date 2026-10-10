import 'package:flutter/material.dart';

import '../../../domain/history/history_entry.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'fight_report_card.dart';

/// What a won assault did to a volcanic kernel: the level it lost, and
/// who holds it now when the last level fell. The entry carries the
/// kernel's levels in its rampart fields.
class AssaultKernelCard extends StatelessWidget {
  final BaseAssaultEntry entry;

  const AssaultKernelCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool fell = entry.rampartAfter == 0;
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AbyssColors.onSurface);
    return FightReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.assaultKernelLevel(entry.rampartBefore, entry.rampartAfter),
            style: style,
          ),
          if (fell)
            Text(
              entry.defending
                  ? l10n.assaultKernelLost
                  : l10n.assaultKernelTaken,
              style: style,
            ),
        ],
      ),
    );
  }
}
