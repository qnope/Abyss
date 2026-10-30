import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../theme/abyss_colors.dart';
import '../ambience/delta_float.dart';
import '../ambience/rise_glow_painter.dart';
import '../ambience/rise_motion.dart';
import '../base/base_label_text.dart';
import '../base/base_pad_tier.dart';
import 'army_plaque.dart';
import 'army_plaque_drawer.dart';
import 'squad_arrival.dart';

const _u = basePadUnit;

/// Draws, in projection coordinates, the plaque of a squad while its
/// recruit arrives (see [SquadArrival]): its count [before] the landing,
/// then the one [after] popping with a glow, as an icon does in a list
/// (IncreasePop), while the gain floats up right of it, « +5 », as
/// [DeltaFloat] floats it.
class ArmyPlaqueArrivalDrawer {
  final ArmyPlaqueDrawer plaques;

  const ArmyPlaqueArrivalDrawer([this.plaques = const ArmyPlaqueDrawer()]);

  /// Draws the plaque centred on [at] at the progress [t] of [arrival],
  /// on a canvas [zoom] times larger on the screen.
  void paint(
    Canvas canvas,
    Offset at, {
    required ArmyPlaque before,
    required ArmyPlaque after,
    required SquadArrival arrival,
    required double t,
    required double zoom,
  }) {
    final pop = SquadArrival.popAt(t);
    if (pop <= 0) {
      plaques.paint(canvas, at, before);
    } else {
      const side = 2 * ArmyPlaqueDrawer.pillHeight;
      final box = Rect.fromCenter(center: at, width: side, height: side);
      canvas
        ..save()
        ..translate(box.left, box.top);
      RiseGlowPainter(
        progress: AlwaysStoppedAnimation(pop),
        color: after.colour,
      ).paint(canvas, box.size);
      canvas.restore();
      RiseMotion.at(pop).paint(canvas, box, () {
        plaques.paint(canvas, at, after);
      });
    }
    final lift = SquadArrival.floatAt(t);
    if (lift > 0 && lift < 1) {
      _float(canvas, at, after, arrival.gained, lift, zoom);
    }
  }

  /// The gain floating up right of [plaque] at [t] of its float.
  void _float(
    Canvas canvas,
    Offset at,
    ArmyPlaque plaque,
    int gained,
    double t,
    double zoom,
  ) {
    const style = DeltaFloat.defaultStyle, gain = AbyssColors.success;
    final text = baseLabelOf(
      DeltaFloat.label(gained),
      style.copyWith(color: gain.withValues(alpha: DeltaFloat.fadeAt(t))),
      style.fontSize! / zoom,
    );
    final (_, right) = plaques.reach(plaque);
    final rise = DeltaFloat.defaultRise / zoom * DeltaFloat.liftAt(t);
    paintLabel(
      canvas,
      text,
      left: at.dx + right + 2 * _u,
      middle: at.dy - rise,
    );
  }
}
