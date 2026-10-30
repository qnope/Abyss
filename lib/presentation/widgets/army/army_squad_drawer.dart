import 'package:flutter/painting.dart';

import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_army_colors.dart';
import '../../theme/abyss_island_colors.dart';
import '../ambience/sprite_motion.dart';
import '../base/base_drawing.dart';
import '../map/map_content_drawer.dart';
import 'army_sprites.dart';
import 'army_squad_geometry.dart';
import 'squad_slots.dart';

/// The pose of the figure on a slot of a squad (see SquadSlots.arrival).
typedef FigurePose = SpriteMotion Function(int figure);

/// Draws, in projection coordinates, the figures of a squad back to
/// front, each on its contact shadow: a single draw of the unit's
/// standing bitmap per figure, as it is, or as a blue translucent ghost
/// while the unit is locked (a colour filter on the paint, no layer).
/// Its paints are made once and reused for every squad.
class ArmySquadDrawer {
  final ArmySprites sprites;
  final MapContentDrawer _floor;
  final _figure = Paint()..filterQuality = FilterQuality.medium;
  final _faded = Paint()..filterQuality = FilterQuality.medium;
  final _ghost =
      Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = AbyssIslandColors.ghost
        ..color = const Color.fromRGBO(0, 0, 0, AbyssArmyColors.ghostOpacity);
  final _shadow = Paint()..filterQuality = FilterQuality.low;

  ArmySquadDrawer(this.sprites) : _floor = MapContentDrawer(sprites.map);

  /// Draws [figures] of [type], [locked] or not, each in the pose
  /// [poseOf] gives its slot, around its feet (standing still by
  /// default), but the one on slot [hidden].
  void paint(
    Canvas canvas,
    UnitType type, {
    required int figures,
    required bool locked,
    FigurePose? poseOf,
    int? hidden,
  }) {
    final image = sprites.standingOf(type);
    final paint = locked ? _ghost : _figure;
    for (final figure in SquadSlots.figuresBackToFront(figures)) {
      if (figure == hidden) continue;
      final feet = ArmySquadGeometry.feetAt(type, figure, locked: locked);
      _floor.drawOnFloor(
        canvas,
        sprites.map.shadow,
        ArmySquadGeometry.shadowBox(feet),
        _shadow,
      );
      final box = ArmySquadGeometry.figureBox(feet);
      final pose = poseOf?.call(figure) ?? SpriteMotion.rest;
      pose.paint(
        canvas,
        ArmySquadGeometry.bodyBox(feet),
        () => drawWholeImage(canvas, image, box, paint),
      );
    }
  }

  /// Draws one figure of [type] alone on [feet] in [pose], at [opacity],
  /// on its shadow if [shadow]: a recruit arriving.
  void paintOne(
    Canvas canvas,
    UnitType type,
    Offset feet, {
    SpriteMotion pose = SpriteMotion.rest,
    double opacity = 1,
    bool shadow = true,
  }) {
    if (shadow) {
      _floor.drawOnFloor(
        canvas,
        sprites.map.shadow,
        ArmySquadGeometry.shadowBox(feet),
        _shadow,
      );
    }
    _faded.color = Color.fromRGBO(0, 0, 0, opacity);
    final box = ArmySquadGeometry.figureBox(feet);
    pose.paint(
      canvas,
      ArmySquadGeometry.bodyBox(feet),
      () => drawWholeImage(canvas, sprites.standingOf(type), box, _faded),
    );
  }
}
