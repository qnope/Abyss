import 'dart:ui' as ui;

import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege_run.dart';
import 'package:abyss/presentation/widgets/map/effects/story/siege_geometry.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const icon = 'assets/icons/units/harpoonist.svg';
  const ring = Color(0xFF66BB6A);

  /// The colours of the rings drawn when the attackers are closest.
  List<Color> ringsOf(MapSiege siege) {
    final run = siege.stage(MapStage(originOf: (cell) => cell)) as MapSiegeRun;
    final canvas = _RingCanvas();
    run.paint(canvas, run.timeline.impact);
    return canvas.rings;
  }

  bool sameHue(Color a, Color b) =>
      a.toARGB32() & 0xFFFFFF == b.toARGB32() & 0xFFFFFF;

  test('raiders keep their red ring', () {
    const siege = MapSiege(
        place: (5, 5),
        victory: false,
        attackerSprite: 'assets/icons/monsters/medium.svg');
    expect(siege.attackerRing, AbyssColors.error);
    final rings = ringsOf(siege);
    expect(rings, hasLength(SiegeGeometry.attackers));
    expect(rings.every((c) => sameHue(c, AbyssColors.error)), isTrue);
  });

  test('a faction attacks with its unit icon, ringed in its colour', () {
    const siege = MapSiege(
        place: (5, 5),
        victory: false,
        attackerSprite: icon,
        attackerRing: ring);
    expect(siege.imagePaths, {icon});
    final rings = ringsOf(siege);
    expect(rings, hasLength(SiegeGeometry.attackers));
    expect(rings.every((c) => sameHue(c, ring)), isTrue);
  });
}

/// A canvas keeping the colours of the outlined circles drawn on it.
class _RingCanvas implements Canvas {
  final rings = <Color>[];

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    if (paint.style == PaintingStyle.stroke) rings.add(paint.color);
  }

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
