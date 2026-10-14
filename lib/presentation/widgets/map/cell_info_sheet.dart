import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

void showCellInfoSheet(
  BuildContext context, {
  required String title,
  required String message,
  IconData? icon,
  Color? iconColor,
  String? illustration,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CellInfoSheet(
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor,
      illustration: illustration,
    ),
  );
}

class _CellInfoSheet extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;

  /// SVG drawn instead of [icon], such as the arrival of a passage.
  final String? illustration;

  const _CellInfoSheet({
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (illustration != null) ...[
            RasterSvg(assetPath: illustration!, size: 112),
            const SizedBox(height: 12),
          ] else if (icon != null) ...[
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
