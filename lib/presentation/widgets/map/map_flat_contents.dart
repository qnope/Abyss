import '../../../domain/map/post_holder.dart';
import '../../../domain/map/transition_base_type.dart';
import '../../extensions/post_holder_extensions.dart';
import 'map_cell_visual.dart';

/// Sprites of the holes in the seabed, drawn lying flat on their cell:
/// the Faille and every passage arriving from above, in every light.
final Set<String> flatContentSprites = {
  for (final holder in PostHolder.values) ...[
    TransitionBaseType.faille.svgPathFor(holder),
    for (final type in TransitionBaseType.values)
      type.passageSvgPathFor(holder),
  ],
};

/// Whether the content drawn with [sprite] lies flat on its cell.
bool isFlatContent(String? sprite) =>
    sprite != null && flatContentSprites.contains(sprite);

/// How a cell's content meets the floor: lying on it, or standing up.
extension MapCellVisualPose on MapCellVisual {
  /// Whether its content is a hole lying flat on its diamond.
  bool get liesFlat => isFlatContent(contentSprite);

  /// Whether its content stands up on its cell, casting a shadow.
  bool get standsUp => contentSprite != null && !liesFlat;

  /// Whether the standing layer draws anything of it: a standing
  /// content, a glow or a faction ring on the floor.
  bool get onStandingLayer =>
      standsUp || glow != MapGlow.none || factionColor != null;
}
