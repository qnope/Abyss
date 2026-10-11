import 'package:flutter/material.dart';

import '../../../domain/faction/base_intel.dart';
import '../../../domain/resource/resource_type.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../map/sheet_info_row.dart';

/// What a Scout reported of a base, read on turn [turn]: the rampart, the
/// army and the stocks, and how long the report still holds.
class BaseIntelReport extends StatelessWidget {
  final BaseIntel intel;
  final int turn;

  const BaseIntelReport({super.key, required this.intel, required this.turn});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final fresh = intel.isFresh(turn);
    final army = <String>[
      for (final e in intel.army.entries)
        if (e.value > 0) e.key.units(l10n, e.value),
    ];
    final stocks = <String>[
      for (final MapEntry<ResourceType, int> e in intel.stocks.entries)
        '${e.key.displayName(l10n)} ${e.value}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.factionIntelTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          fresh
              ? l10n.factionIntelFresh(intel.turnsLeft(turn))
              : l10n.factionIntelStale,
          style: theme.textTheme.bodySmall?.copyWith(
            color: fresh ? AbyssColors.onSurfaceDim : theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        SheetInfoRow(l10n.factionIntelRampart, '${intel.rampartLevel}'),
        SheetInfoRow(
          l10n.factionIntelArmy,
          army.isEmpty ? l10n.factionIntelNoArmy : army.join(', '),
        ),
        SheetInfoRow(l10n.factionIntelStocks, stocks.join(', ')),
      ],
    );
  }
}
