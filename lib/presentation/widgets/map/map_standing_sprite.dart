import 'dart:ui';

import '../ambience/creature_sheet.dart';
import '../ambience/sprite_motion.dart';
import 'living_creatures.dart';
import 'map_cell_visual.dart';
import 'map_content_drawer.dart';

/// Draws a content standing up in its area: a living creature undulating
/// on its sheet once built, any other content (or a creature whose sheet
/// is not built yet) as its sprite.
///
/// Its paint is made once and reused for every content it draws.
class MapStandingSprite {
  final MapContentDrawer drawer;

  /// The undulating sheet of a living creature's sprite, if built.
  final CreatureSheet? Function(String sprite) creatureSheetOf;

  final _creature = Paint()..filterQuality = FilterQuality.medium;

  MapStandingSprite(this.drawer, this.creatureSheetOf);

  /// Draws [visual] standing in [area] in [pose], [seconds] into the
  /// ambience, a creature undulating at its [phase].
  void draw(Canvas canvas, MapCellVisual visual, Rect area, SpriteMotion pose,
      {required double seconds, required double phase}) {
    final sprite = visual.contentSprite;
    final sheet = isLivingCreature(sprite) ? creatureSheetOf(sprite!) : null;
    if (sheet == null) {
      return drawer.drawStanding(canvas, visual, area, pose: pose);
    }
    final frame = sheet.undulation.frameAt(seconds, phase: phase);
    pose.paint(canvas, area, () => sheet.draw(canvas, frame, area, _creature));
  }
}
