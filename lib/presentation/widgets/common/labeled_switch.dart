import 'package:flutter/material.dart';
import '../../theme/abyss_colors.dart';

/// A [Switch] with its [title] and a one-line [subtitle] explaining it,
/// the whole row tappable.
///
/// Stateless — the parent owns [value]; [onChanged] fires with the new
/// value when the player taps the row.
class LabeledSwitch extends StatelessWidget {
  const LabeledSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall?.copyWith(color: AbyssColors.onSurfaceDim),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
