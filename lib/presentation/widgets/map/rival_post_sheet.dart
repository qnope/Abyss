import 'package:flutter/material.dart';

import '../../../domain/action/action_failure.dart';
import '../../../domain/map/transition_base.dart';
import '../../extensions/action_failure_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'transition_base_sheet.dart';

/// Opens the sheet of a Faille or Cheminée that the player called
/// [ownerName] holds.
Future<void> showRivalPostSheet(
  BuildContext context, {
  required TransitionBase post,
  required String ownerName,
  required ActionFailure? refusal,
  required VoidCallback onAttack,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder:
      (_) => RivalPostSheet(
        post: post,
        ownerName: ownerName,
        refusal: refusal,
        onAttack: onAttack,
      ),
);

/// A post held by another player: who holds it, and the attack button,
/// off with the reason while the attack is refused.
class RivalPostSheet extends StatelessWidget {
  final TransitionBase post;
  final String ownerName;
  final ActionFailure? refusal;
  final VoidCallback onAttack;

  const RivalPostSheet({
    super.key,
    required this.post,
    required this.ownerName,
    required this.refusal,
    required this.onAttack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TransitionBaseHeader(transitionBase: post),
            const SizedBox(height: 12),
            Text(
              l10n.mapHeldBy(ownerName),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AbyssColors.pearlWhite,
                fontWeight: FontWeight.bold,
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
