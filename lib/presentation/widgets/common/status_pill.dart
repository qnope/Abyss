import 'package:flutter/widgets.dart';

import '../../theme/abyss_colors.dart';
import '../../theme/abyss_text_theme.dart';

/// A short capitalized [label] in a rounded pill tinted with [color],
/// such as a difficulty or how a game ended.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  /// Fades the pill with the item it labels, e.g. a lost game.
  final bool faded;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = faded ? AbyssColors.dimmed(color) : color;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint.withValues(alpha: tint.a * 0.16),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          style: AbyssTextTheme.pillLabel.copyWith(color: tint),
        ),
      ),
    );
  }
}
