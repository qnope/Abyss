import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

class TabPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;

  const TabPlaceholder({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AbyssColors.biolumCyan.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.screenComingSoon,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AbyssColors.disabled,
            ),
          ),
        ],
      ),
    );
  }
}
