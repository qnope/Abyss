import 'package:flutter/painting.dart';

import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_army_colors.dart';
import '../../theme/abyss_island_colors.dart';
import '../ambience/sprite_motion.dart';
import '../base/base_drawing.dart';
import '../map/map_content_drawer.dart';
import 'army_sprites.dart';
import 'army_squad_geometry.dart';

/// Draws, in projection coordinates, the figures of a squad back to
/// front, each on its contact shadow: a single draw of the unit's
/// standing bitmap per figure, as it is, or as a blue translucent ghost
/// while the unit is locked (a colour filter on the paint, no layer).
/// Its paints are made once and reused for every squad.
class ArmySquadDrawer {
  final ArmySprites sprites;
  final MapContentDrawer _floor;
  final _figure = Paint()..filterQuality = FilterQuality.medium;
  final _ghost =
      Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = AbyssIslandColors.ghost
        ..color = const Color.fromRGBO(0, 0, 0, AbyssArmyColors.ghostOpacity);
  final _shadow = Paint()..filterQuality = FilterQuality.low;

  ArmySquadDrawer(this.sprites) : _floor = MapContentDrawer(sprites.map);

  /// Draws [figures] of [type], [locked] or not, each in [pose] around
  /// its feet: as drawn by default, the squad standing still.
  void paint(
    Canvas canvas,
    UnitType type, {
    required int figures,
    required bool locked,
    SpriteMotion pose = SpriteMotion.rest,
  }) {
    final image = sprites.standingOf(type);
    final paint = locked ? _ghost : _figure;
    for (final feet in ArmySquadGeometry.feetOf(
      type,
      figures,
      locked: locked,
    )) {
      _floor.drawOnFloor(
        canvas,
        sprites.map.shadow,
        ArmySquadGeometry.shadowBox(feet),
        _shadow,
      );
      final box = ArmySquadGeometry.figureBox(feet);
      pose.paint(canvas, box, () => drawWholeImage(canvas, image, box, paint));
    }
  }
}
