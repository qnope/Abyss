import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../theme/abyss_army_colors.dart';
import '../../theme/abyss_colors.dart';
import '../../theme/abyss_island_colors.dart';
import '../base/base_label_text.dart';
import '../base/base_pad_tier.dart';
import '../base/base_slot_projection.dart';
import '../map/map_projection.dart';
import 'army_layout.dart';
import 'army_trident.dart';

const _u = basePadUnit;

/// Draws, in projection coordinates, the army's crest painted flat in the
/// middle of the parade ground, as on the mockup: a round deck, two
/// glowing rings, eight studs, and a trident laid on the floor.
class ArmyCrestDrawer {
  /// Radius of the crest, in cells.
  static const radius = 1.15;

  /// Units of the trident's drawing (see [armyTrident]) along the crest's
  /// radius, as on the mockup.
  static const _tridentSpan = 44.0;

  const ArmyCrestDrawer();

  /// Draws the crest at [ArmyLayout.crest].
  void paint(Canvas canvas) {
    final centre = baseGroundToProjection(ArmyLayout.crest);
    final crest = Rect.fromCenter(
      center: centre,
      width: 2 * radius * MapProjection.tileWidth,
      height: 2 * radius * MapProjection.tileHeight,
    );
    Rect scaled(double share) => Rect.fromCenter(
        center: centre, width: share * crest.width, height: share * crest.height);
    canvas
      ..drawOval(
          scaled(1.05).translate(0, 3 * _u),
          Paint()
            ..color = AbyssArmyColors.crestShadow.withValues(alpha: .45))
      ..drawOval(
          crest,
          Paint()
            ..shader = ui.Gradient.linear(crest.topLeft, crest.bottomRight,
                const [
                  AbyssIslandColors.deckLight,
                  AbyssIslandColors.deckMid,
                  AbyssIslandColors.deckDark,
                ], const [0, .5, 1]))
      ..drawOval(crest, _stroke(AbyssColors.abyssBlack, 1, .8))
      ..drawOval(scaled(.9), _stroke(AbyssArmyColors.crestLight, .7, 1.6))
      ..drawPath(dashedPathOf(Path()..addOval(scaled(.78)), 5 * _u, 3 * _u),
          _stroke(AbyssArmyColors.crestLight, .35, .8))
      ..drawOval(
          scaled(.7),
          Paint()
            ..color = AbyssArmyColors.crestLight.withValues(alpha: .08)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6 * _u));
    _trident(canvas, centre, crest.width / 2 / _tridentSpan);
    final stud = Paint()..color = AbyssArmyColors.crestSheen;
    final ring = scaled(.9);
    for (var k = 0; k < 8; k++) {
      final angle = k * pi / 4;
      canvas.drawCircle(
        centre.translate(ring.width / 2 * cos(angle), ring.height / 2 * sin(angle)),
        1.3 * _u,
        stud,
      );
    }
  }

  /// The trident drawn upright at [scale], then laid on the floor: turned
  /// a quarter of a half turn and squashed to half its height.
  void _trident(Canvas canvas, Offset centre, double scale) {
    final trident = armyTrident();
    canvas
      ..save()
      ..translate(centre.dx, centre.dy)
      ..scale(scale, scale / 2)
      ..rotate(pi / 4)
      ..drawPath(trident,
          Paint()..color = AbyssArmyColors.crestLight.withValues(alpha: .75))
      ..drawPath(
          trident,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = .8
            ..color = AbyssArmyColors.crestSheen.withValues(alpha: .6))
      ..restore();
  }

  static Paint _stroke(Color colour, double alpha, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width * _u
    ..color = colour.withValues(alpha: alpha);
}
