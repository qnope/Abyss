import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/tech/tech_node_state.dart';
import '../../theme/abyss_colors.dart';

class TechNodeWidget extends StatelessWidget {
  final String iconPath;
  final Color color;
  final TechNodeState state;
  final int? level;
  final VoidCallback? onTap;

  const TechNodeWidget({
    super.key,
    required this.iconPath,
    required this.color,
    required this.state,
    this.level,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = switch (state) {
      TechNodeState.locked => 0.3,
      TechNodeState.accessible => 0.7,
      TechNodeState.researched => 1.0,
    };

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AbyssColors.surfaceLight,
                border: _buildBorder(),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: state == TechNodeState.locked
                      ? const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        )
                      : null,
                ),
              ),
            ),
            if (level != null) ...[
              const SizedBox(height: 4),
              Text(
                'Niv. $level',
                style: TextStyle(
                  fontSize: 10,
                  color: state == TechNodeState.researched
                      ? color
                      : AbyssColors.onSurfaceDim,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Border? _buildBorder() => switch (state) {
    TechNodeState.locked => null,
    TechNodeState.accessible => Border.all(color: color, width: 1),
    TechNodeState.researched => Border.all(color: color, width: 2),
  };
}
