import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// How many rival factions a new game has, from [min] to [max], one tap
/// at a time. Stateless: the parent owns [count].
class FactionCountPicker extends StatelessWidget {
  static const int min = 0;
  static const int max = 10;

  final int count;
  final ValueChanged<int> onChanged;

  const FactionCountPicker({
    super.key,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.newGameFactions, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: count > min ? () => onChanged(count - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
            ),
            IconButton(
              onPressed: count < max ? () => onChanged(count + 1) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        Text(
          count == 0
              ? l10n.newGameFactionsNone
              : l10n.newGameFactionsCount(count),
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AbyssColors.onSurfaceDim),
        ),
      ],
    );
  }
}
