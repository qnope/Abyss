import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';

/// Bottom of an army selection screen: the warning that an assault needs
/// an admiral, the button that launches the fight and the one that
/// cancels it.
class ArmySelectionActions extends StatelessWidget {
  final String launchLabel;
  final VoidCallback? onLaunch;
  final bool admiralMissing;

  const ArmySelectionActions({
    super.key,
    required this.launchLabel,
    required this.onLaunch,
    this.admiralMissing = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (admiralMissing) ...[
          const SizedBox(height: 8),
          Text(
            l10n.fightAdmiralRequired,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onLaunch,
              child: Text(launchLabel),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
        ]),
      ],
    );
  }
}
