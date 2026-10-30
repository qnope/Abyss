import '../ambience/ambient_motion.dart';
import '../ambience/rise_motion.dart';
import '../ambience/sprite_motion.dart';

/// The pose of a building of the base at [seconds] of the shared ambience
/// clock, around its foot on the pad: [breathing] (shifted by [phase],
/// see [AmbientMotion.phaseOf]) when it works, popping up when its level
/// just went up ([rise] from 0 to 1, see [RiseMotion]), else as drawn.
SpriteMotion baseBuildingPose({
  required bool breathing,
  required double seconds,
  double phase = 0,
  double? rise,
}) {
  final breath = breathing
      ? AmbientMotion.breathe.at(seconds, phase: phase)
      : SpriteMotion.rest;
  final pop = rise == null ? SpriteMotion.rest : RiseMotion.at(rise);
  if (breath.isRest && pop.isRest && pop.glow == 0) return SpriteMotion.rest;
  return SpriteMotion(
    scale: breath.scale * pop.scale,
    dy: pop.dy,
    glow: pop.glow,
    pivot: SpritePivot.bottom,
  );
}
