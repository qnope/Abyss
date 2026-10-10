import 'package:flutter/material.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

/// How an option of a choice node stands for the player.
enum TechOptionStatus { open, taken, discarded }

/// One of the two options of a choice node: its icon, name and effect,
/// and the button that takes it for the rest of the game.
class TechOptionCard extends StatelessWidget {
  final String iconPath;
  final String name;
  final String effect;
  final Color color;
  final TechOptionStatus status;
  final VoidCallback? onChoose;

  const TechOptionCard({
    super.key,
    required this.iconPath,
    required this.name,
    required this.effect,
    required this.color,
    this.status = TechOptionStatus.open,
    this.onChoose,
  });

  bool get _discarded => status == TechOptionStatus.discarded;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AbyssColors.surfaceDim,
        border: Border.all(
          color: status == TechOptionStatus.taken
              ? color
              : AbyssColors.surfaceBright),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        RasterSvg(
          assetPath: iconPath,
          size: 64,
          greyscale: _discarded,
        ),
        const SizedBox(height: 6),
        Text(name,
          textAlign: TextAlign.center,
          style: text.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: _discarded ? AbyssColors.onSurfaceDim : null)),
        const SizedBox(height: 2),
        Text(effect,
          textAlign: TextAlign.center,
          style: text.bodySmall?.copyWith(color: AbyssColors.onSurfaceDim)),
        const SizedBox(height: 8),
        _footer(text),
      ]),
    );
  }

  Widget _footer(TextTheme text) => switch (status) {
    TechOptionStatus.open => ElevatedButton(
      onPressed: onChoose, child: const Text('Choisir')),
    TechOptionStatus.taken => Text('Choisi ✓',
      style: text.labelLarge?.copyWith(color: AbyssColors.success)),
    TechOptionStatus.discarded => Text('Écarté',
      style: text.labelLarge?.copyWith(color: AbyssColors.onSurfaceDim)),
  };
}
