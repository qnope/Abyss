import 'package:flutter/widgets.dart';

import '../../theme/abyss_menu_theme.dart';

/// A small ring holding a count, such as the number of saved games.
class CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const CountBadge({super.key, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        '$count',
        style: AbyssMenuTheme.badgeLabel.copyWith(color: color),
      ),
    );
  }
}
