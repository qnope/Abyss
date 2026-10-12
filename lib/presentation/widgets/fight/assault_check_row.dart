import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

/// How a point of a checklist stands.
enum AssaultCheckState {
  ok(Icons.check_circle, AbyssColors.success),
  warning(Icons.error, AbyssColors.warning),
  missing(Icons.cancel, AbyssColors.error);

  final IconData icon;
  final Color color;

  const AssaultCheckState(this.icon, this.color);
}

/// One point of a checklist: an icon telling its [state], a [title] and
/// a dimmer [detail] line below it.
class AssaultCheckRow extends StatelessWidget {
  final AssaultCheckState state;
  final String title;
  final String detail;

  const AssaultCheckRow({
    super.key,
    required this.state,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(state.icon, size: 20, color: state.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AbyssColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  detail,
                  style: textTheme.bodySmall?.copyWith(
                    color: AbyssColors.onSurfaceDim,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
