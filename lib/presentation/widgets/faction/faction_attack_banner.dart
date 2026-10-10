import 'package:flutter/material.dart';

import '../../../domain/raid/announced_attack.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'faction_attack_sheet.dart';

/// Strip next to the raid alert for an attack of a faction on its way,
/// in the colour of the faction: who, when, and the exact army. Tapping
/// it opens the sheet of the army.
class FactionAttackBanner extends StatelessWidget {
  final AnnouncedAttack attack;
  final String factionName;
  final Color color;
  final int currentTurn;

  const FactionAttackBanner({
    super.key,
    required this.attack,
    required this.factionName,
    required this.color,
    required this.currentTurn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.bodyMedium;
    final army = [
      for (final e in attack.units.entries)
        if (e.value > 0) e.key.units(l10n, e.value),
    ].join(', ');
    return Material(
      color: AbyssColors.surfaceDim,
      child: InkWell(
        onTap:
            () => showFactionAttackSheet(
              context,
              attack: attack,
              factionName: factionName,
              color: color,
            ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(Icons.flag, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.factionAttackBanner(
                        factionName,
                        attack.arrivalTurn,
                        (attack.arrivalTurn - currentTurn).clamp(0, 99),
                      ),
                      style: style?.copyWith(color: color),
                    ),
                    Text(l10n.factionAttackArmy(army), style: style),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AbyssColors.onSurfaceDim),
            ],
          ),
        ),
      ),
    );
  }
}
