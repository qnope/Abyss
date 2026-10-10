import 'package:flutter/material.dart';

import '../../../domain/action/action_failure.dart';
import '../../../domain/faction/faction.dart';
import '../../extensions/action_failure_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../../theme/faction_colors.dart';
import '../map/sheet_info_row.dart';

/// Opens the sheet of the base of [faction], whose headquarters stands at
/// [headquartersLevel]. [refusal] is why the human may not attack it
/// now, `null` when it may.
Future<void> showFactionBaseSheet(
  BuildContext context, {
  required Faction faction,
  required int headquartersLevel,
  required ActionFailure? refusal,
  required VoidCallback onAttack,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => FactionBaseSheet(
    faction: faction,
    headquartersLevel: headquartersLevel,
    refusal: refusal,
    onAttack: onAttack,
  ),
);

/// What the human knows of a faction base it has seen: the name and the
/// colour of the faction and its headquarters level, which is public. The
/// attack button is off, with the reason, while the attack is refused.
class FactionBaseSheet extends StatelessWidget {
  final Faction faction;
  final int headquartersLevel;
  final ActionFailure? refusal;
  final VoidCallback onAttack;

  const FactionBaseSheet({
    super.key,
    required this.faction,
    required this.headquartersLevel,
    required this.refusal,
    required this.onAttack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = FactionColors.of(faction.personality);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: color, size: 48),
            const SizedBox(height: 12),
            Text(
              faction.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(color: color),
            ),
            const SizedBox(height: 16),
            SheetInfoRow(
              l10n.factionBaseHeadquarters,
              '$headquartersLevel',
            ),
            if (refusal != null) ...[
              const SizedBox(height: 12),
              Text(
                refusal!.message(l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AbyssColors.biolumCyan,
                    foregroundColor: AbyssColors.abyssBlack,
                  ),
                  onPressed: refusal != null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onAttack();
                        },
                  child: Text(l10n.factionBaseAttack),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
