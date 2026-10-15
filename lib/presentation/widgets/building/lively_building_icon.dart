import 'package:flutter/widgets.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/resource/production_formulas.dart';
import '../../theme/abyss_colors.dart';
import '../ambience/ambient_bubbles.dart';
import '../ambience/ambient_motion.dart';
import '../ambience/ambient_pose.dart';
import '../ambience/increase_pop.dart';
import 'building_icon.dart';

/// A building's icon in the base, alive when the building works: it
/// breathes, bubbles rise over the ones producing a resource, and it
/// rises when its [level] goes up.
///
/// The motions follow the nearest ambience clock scope, so a whole list
/// shares one clock; an unbuilt or inactive building stands still and
/// greyed.
class LivelyBuildingIcon extends StatelessWidget {
  final BuildingType type;
  final int level;

  /// Whether the building works at full strength (e.g. not degraded).
  final bool active;

  final double size;

  const LivelyBuildingIcon({
    super.key,
    required this.type,
    required this.level,
    this.active = true,
    this.size = 40,
  });

  bool get _built => level > 0;
  bool get _alive => _built && active;

  /// Whether bubbles rise over [type]: it produces a resource.
  static bool bubblesOver(BuildingType type) =>
      productionFormulas.containsKey(type);

  @override
  Widget build(BuildContext context) {
    final box = Size.square(size);
    final icon = BuildingIcon(
      type: type,
      size: size,
      greyscale: !_built,
      faded: !_built,
    );
    return IncreasePop(
      value: level,
      size: box,
      glowColor: AbyssColors.biolumCyan,
      child:
          !_alive
              ? icon
              : Stack(
                alignment: Alignment.topLeft,
                clipBehavior: Clip.none,
                children: [
                  AmbientPose(
                    motion: AmbientMotion.breathe,
                    phase: AmbientMotion.phaseOf(type.index),
                    size: box,
                    child: icon,
                  ),
                  if (bubblesOver(type))
                    Positioned.fill(child: AmbientBubbles(seed: type.index)),
                ],
              ),
    );
  }
}
