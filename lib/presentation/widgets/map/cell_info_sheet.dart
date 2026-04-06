import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

void showCellInfoSheet(
  BuildContext context, {
  required String title,
  required String message,
  IconData? icon,
  Color? iconColor,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CellInfoSheet(
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor,
    ),
  );
}

class _CellInfoSheet extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;

  const _CellInfoSheet({
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 64, color: iconColor ?? AbyssColors.onSurfaceDim),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumCyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
        ],
      ),
    );
  }
}
