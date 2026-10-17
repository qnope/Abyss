import 'package:flutter/material.dart';

import '../../../domain/action/action_failure.dart';
import '../../../domain/faction/base_intel.dart';
import '../../../domain/faction/faction.dart';
import '../../extensions/action_failure_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../map/sheet_info_row.dart';
import 'base_intel_report.dart';
import 'faction_identity.dart';

/// Opens the sheet of the base of [faction], whose headquarters stands at
/// [headquartersLevel]. [refusal] is why the human may not attack it
/// now, `null` when it may. [intel] is the last report a Scout brought
/// back, read on [turn]; [spyRefusal] is why the human may not send
/// another one now, `null` when it may.
Future<void> showFactionBaseSheet(
  BuildContext context, {
  required Faction faction,
  required int headquartersLevel,
  required ActionFailure? refusal,
  required BaseIntel? intel,
  required int turn,
  required ActionFailure? spyRefusal,
  required VoidCallback onSpy,
  required VoidCallback onAttack,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder:
      (_) => FactionBaseSheet(
        faction: faction,
        headquartersLevel: headquartersLevel,
        refusal: refusal,
        intel: intel,
        turn: turn,
        spyRefusal: spyRefusal,
        onSpy: onSpy,
        onAttack: onAttack,
      ),
);

/// What the human knows of a faction base it has seen: who the faction is
/// (see [FactionIdentity]) and its headquarters level, which is public. The
/// attack button is off, with the reason, while the attack is refused.
class FactionBaseSheet extends StatelessWidget {
  final Faction faction;
  final int headquartersLevel;
  final ActionFailure? refusal;
  final BaseIntel? intel;
  final int turn;
  final ActionFailure? spyRefusal;
  final VoidCallback onSpy;
  final VoidCallback onAttack;

  const FactionBaseSheet({
    super.key,
    required this.faction,
    required this.headquartersLevel,
    required this.refusal,
    required this.intel,
    required this.turn,
    required this.spyRefusal,
    required this.onSpy,
    required this.onAttack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FactionIdentity(faction: faction),
            const SizedBox(height: 16),
            SheetInfoRow(l10n.factionBaseHeadquarters, '$headquartersLevel'),
            const SizedBox(height: 12),
            if (intel != null)
              BaseIntelReport(intel: intel!, turn: turn)
            else
              Text(
                l10n.factionIntelNone,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AbyssColors.onSurfaceDim,
                ),
              ),
            if (refusal != null) ...[
              const SizedBox(height: 12),
              Text(
                refusal!.message(l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
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
                OutlinedButton(
                  onPressed:
                      spyRefusal != null
                          ? null
                          : () {
                            Navigator.of(context).pop();
                            onSpy();
                          },
                  child: Text(l10n.factionSpy),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AbyssColors.biolumCyan,
                    foregroundColor: AbyssColors.abyssBlack,
                  ),
                  onPressed:
                      refusal != null
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
