import 'package:flutter/material.dart';
import '../../../domain/game/difficulty.dart';
import '../../extensions/difficulty_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// One [ChoiceChip] per [Difficulty], with the description of the
/// selected one below.
///
/// Stateless — the parent owns [current]; [onChanged] fires when the
/// player taps another level.
class DifficultyPicker extends StatelessWidget {
  const DifficultyPicker({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final Difficulty current;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.difficultyTitle, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            for (final difficulty in Difficulty.values)
              ChoiceChip(
                label: Text(difficulty.displayName(context.l10n)),
                selected: difficulty == current,
                selectedColor: difficulty.color.withAlpha(60),
                onSelected: (selected) {
                  if (selected) onChanged(difficulty);
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          current.description(context.l10n),
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AbyssColors.onSurfaceDim),
        ),
      ],
    );
  }
}
