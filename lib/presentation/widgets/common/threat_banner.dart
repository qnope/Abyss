import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

/// Strip under the resource bar for a threat on its way, edged in its
/// [color]: a [title] in that colour, a [detail] line under it, and a
/// chevron when [onTap] opens more.
class ThreatBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final Color color;
  final VoidCallback? onTap;

  const ThreatBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Material(
      color: AbyssColors.surfaceDim,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: style?.copyWith(color: color)),
                    Text(detail, style: style),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AbyssColors.onSurfaceDim,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
