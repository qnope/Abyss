import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/unit/unit_type.dart';
import '../ambience/bubbles_painter.dart';
import '../base/base_fit.dart';
import '../base/base_pad_tier.dart';
import 'army_roster.dart';
import 'army_squad_geometry.dart';

const _u = basePadUnit;

/// A few bubbles rising now and then from the helmet of the front soldier
/// of every unlocked squad standing on the parade ground, on the shared
/// ambience clock, as over a working building of the base (see
/// [BubblesPainter]).
class ArmyHelmetBubbles {
  /// Bubbles over each squad at once.
  static const count = 2;

  /// The box the bubbles rise through, in projection units.
  static const size = Size(30 * _u, 46 * _u);

  final Map<UnitType, BubblesPainter> _painters;

  ArmyHelmetBubbles(ValueListenable<double> clock, ArmyRoster roster)
    : _painters = {
        for (final type in UnitType.values)
          if (!roster.isLocked(type) && roster.figuresOf(type) > 0)
            type: BubblesPainter(
              clock: clock,
              seed: 40 + type.index,
              count: count,
            ),
      };

  /// The squads bubbling.
  Iterable<UnitType> get squads => _painters.keys;

  /// The box, in projection coordinates, the bubbles of [type] rise
  /// through: over the helmet of its front soldier.
  static Rect areaOf(UnitType type) {
    final feet = ArmySquadGeometry.feetAt(type, 0, locked: false);
    final head = ArmySquadGeometry.figureBox(feet).topCenter;
    return Rect.fromLTWH(
      head.dx - size.width / 2,
      head.dy - size.height + 8 * _u,
      size.width,
      size.height,
    );
  }

  /// Paints the bubbles over the parade ground seen through [fit], on a
  /// canvas in the view's coordinates.
  void paint(Canvas canvas, BaseFit fit) {
    for (final MapEntry(key: type, value: bubbles) in _painters.entries) {
      final area = areaOf(type);
      canvas
        ..save()
        ..translate(fit.toView(area.topLeft).dx, fit.toView(area.topLeft).dy);
      bubbles.paint(canvas, area.size * fit.zoom);
      canvas.restore();
    }
  }
}
