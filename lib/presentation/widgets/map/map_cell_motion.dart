import '../../../domain/map/cell_content_type.dart';
import '../ambience/ambient_motion.dart';
import 'map_cell_visual.dart';

/// The idle motion of a seen, uncollected [content]: creatures float,
/// homes breathe, posts and the volcano pulse their glow, and loose
/// things (a wreck, a treasure, a resource) sway on the seabed.
///
/// [isHome] marks the base of the player or of a faction standing there.
AmbientMotion contentMotionOf(CellContentType content, {bool isHome = false}) {
  if (_pulses(content)) return AmbientMotion.pulse;
  if (isHome) return AmbientMotion.breathe;
  return switch (content) {
    CellContentType.monsterLair => AmbientMotion.bob,
    CellContentType.wreck ||
    CellContentType.ruins ||
    CellContentType.resourceBonus => AmbientMotion.sway,
    _ => AmbientMotion.still,
  };
}

bool _pulses(CellContentType content) =>
    content == CellContentType.transitionBase ||
    content == CellContentType.passage ||
    content == CellContentType.volcanicKernel;

/// The glow that [motion] makes pulse under [content], if any.
MapGlow pulseGlowOf(CellContentType content, AmbientMotion motion) {
  if (motion != AmbientMotion.pulse) return MapGlow.none;
  return content == CellContentType.volcanicKernel
      ? MapGlow.volcano
      : MapGlow.post;
}
