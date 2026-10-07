import 'package:flutter/material.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

/// Large round emblem heading a tech branch, glowing once unlocked and
/// greyed out with a padlock otherwise.
class TechBranchMedallion extends StatelessWidget {
  final String iconPath;
  final String name;
  final Color color;
  final bool unlocked;
  final VoidCallback? onTap;

  const TechBranchMedallion({
    super.key,
    required this.iconPath,
    required this.name,
    required this.color,
    required this.unlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ring = unlocked ? color : AbyssColors.disabled;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AbyssColors.surfaceLight,
                  border: Border.all(color: ring, width: 3),
                  boxShadow: unlocked
                      ? [BoxShadow(
                          color: color.withValues(alpha: 0.55),
                          blurRadius: 18)]
                      : null,
                ),
                child: RasterSvg(
                  assetPath: iconPath,
                  size: 40,
                  color: unlocked ? null : AbyssColors.disabled,
                ),
              ),
              if (!unlocked) const Positioned(
                right: -2,
                bottom: -2,
                child: Icon(Icons.lock, size: 18,
                  color: AbyssColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: unlocked ? color : AbyssColors.onSurfaceDim,
              fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
