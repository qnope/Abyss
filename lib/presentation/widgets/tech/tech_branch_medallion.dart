import 'package:flutter/material.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';
import '../guide/guide_halo.dart';

/// Round emblem of a tech branch, glowing once unlocked and greyed out
/// with a padlock otherwise. The [label] is drawn above or below it.
class TechBranchMedallion extends StatelessWidget {
  final String iconPath;
  final String label;
  final String? detail;
  final Color color;
  final bool unlocked;
  final bool labelAbove;
  final double size;

  /// Whether the guide's halo surrounds the emblem.
  final bool highlighted;
  final VoidCallback? onTap;

  const TechBranchMedallion({
    super.key,
    required this.iconPath,
    required this.label,
    this.detail,
    required this.color,
    required this.unlocked,
    this.labelAbove = false,
    this.size = 52,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: unlocked ? color : AbyssColors.onSurfaceDim,
      fontWeight: FontWeight.w700, height: 1.1);
    final text = Text(detail == null ? '$label\n' : '$label\n$detail',
      maxLines: 2,
      textAlign: TextAlign.center,
      style: style);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (labelAbove) ...[text, const SizedBox(height: 4)],
          GuideHalo(
            active: highlighted, shape: BoxShape.circle, child: _emblem()),
          if (!labelAbove) ...[const SizedBox(height: 4), text],
        ],
      ),
    );
  }

  Widget _emblem() {
    final ring = unlocked ? color : AbyssColors.disabled;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AbyssColors.surfaceLight,
            border: Border.all(color: ring, width: 2.5),
            boxShadow: unlocked
                ? [BoxShadow(
                    color: color.withValues(alpha: 0.55), blurRadius: 16)]
                : null,
          ),
          child: RasterSvg(
            assetPath: iconPath,
            size: size * 0.6,
            color: unlocked ? null : AbyssColors.disabled,
          ),
        ),
        if (!unlocked) const Positioned(
          right: -3,
          bottom: -3,
          child: Icon(Icons.lock, size: 16, color: AbyssColors.warning),
        ),
      ],
    );
  }
}
