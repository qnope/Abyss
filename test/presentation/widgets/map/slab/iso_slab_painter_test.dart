import 'dart:ui';

import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_slab_theme.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/slab/iso_slab.dart';
import 'package:abyss/presentation/widgets/map/slab/iso_slab_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const columns = 6, rows = 4;
  final slab = IsoSlab(columns: columns, rows: rows, salt: 2);
  final (lit, shaded) = (slab.faces.first, slab.faces.last);
  const painter = IsoSlabPainter(columns: columns, rows: rows, salt: 2);
  void paint(Canvas canvas) => painter.paint(canvas, Size.zero);

  /// A path filled with a gradient, holding [inside] but not [outside].
  PaintPatternPredicate shadedFill(List<Offset> inside,
          [List<Offset> outside = const []]) =>
      (method, args) {
        if (method != #drawPath || (args[1] as Paint).shader == null) {
          return false;
        }
        final path = args[0] as Path;
        return inside.every(path.contains) && !outside.any(path.contains);
      };

  /// A path stroked or filled in [color], whatever its opacity.
  PaintPatternPredicate tinted(Color color) => (method, args) =>
      method == #drawPath &&
      (args[1] as Paint).color.toARGB32() & 0xFFFFFF ==
          color.toARGB32() & 0xFFFFFF;

  test('fills the lit face then the shaded one with their gradients', () {
    expect(
      paint,
      paints
        ..something(shadedFill(
            [lit.pointAt(0.5, 0.5), lit.pointAt(0.05, 0.6)],
            [lit.pointAt(0.5, -0.2), shaded.pointAt(0.5, 0.5)]))
        ..something(shadedFill(
            [shaded.pointAt(0.5, 0.5), shaded.pointAt(0.95, 0.6)],
            [shaded.pointAt(0.5, -0.2), lit.pointAt(0.5, 0.5)])),
    );
    expect(AbyssSlabTheme.litFace.first.computeLuminance(),
        greaterThan(AbyssSlabTheme.shadedFace.first.computeLuminance()));
  });

  test('draws strata, stones, algae, glowing specks and lit lips', () {
    expect(
      paint,
      paints
        ..something(tinted(AbyssSlabTheme.litStratum))
        ..something(tinted(AbyssSlabTheme.stratumGroove))
        ..something(tinted(AbyssSlabTheme.stoneGlint))
        ..something(tinted(AbyssSlabTheme.strands[lit.strands.first.tint]))
        ..something(tinted(AbyssSlabTheme.shadedStratum))
        ..line(p1: lit.start, p2: lit.end, color: AbyssSlabTheme.litLip)
        ..line(p1: shaded.start, p2: shaded.end,
            color: AbyssSlabTheme.shadedLip),
    );
    expect(lit.specks.length + shaded.specks.length, greaterThan(0));
    // Halos, glows and cores of every speck, three batches in all.
    expect(paint, paintsExactlyCountTimes(#drawRawPoints, 3));
    expect(paint, paintsExactlyCountTimes(#drawLine, 2));
  });

  test('never draws an oval nor a rect, which the still map keeps for '
      'nothing', () {
    expect(paint, paintsExactlyCountTimes(#drawOval, 0));
    expect(paint, paintsExactlyCountTimes(#drawRect, 0));
    expect(paint, paintsExactlyCountTimes(#drawImageRect, 0));
  });

  test('draws nothing for an empty map', () {
    const empty = IsoSlabPainter(columns: 0, rows: 0);
    expect((Canvas canvas) => empty.paint(canvas, Size.zero), paintsNothing);
  });

  test('repaints only for another slab', () {
    expect(painter.shouldRepaint(
        const IsoSlabPainter(columns: columns, rows: rows, salt: 2)), isFalse);
    for (final other in const [
      IsoSlabPainter(columns: columns, rows: rows, salt: 3),
      IsoSlabPainter(columns: columns + 1, rows: rows, salt: 2),
      IsoSlabPainter(columns: columns, rows: rows, salt: 2, depth: 10),
    ]) {
      expect(painter.shouldRepaint(other), isTrue);
    }
  });

  test('the still map stands on its slab, drawn over the fog', () {
    final tile = TerrainType.plain.tileSvgPaths.first;
    final visuals = [
      for (var i = 0; i < columns * rows; i++)
        MapCellVisual(terrainSprite: tile, revealed: i.isEven),
    ];
    final map = MapPainter(visuals: visuals, columns: columns, decorSalt: 2);
    final face = IsoSlab(columns: columns, rows: rows, salt: 2).faces.first;
    expect(
      (Canvas canvas) => map.paint(canvas, Size.zero),
      paints
        ..something((method, args) =>
            method == #drawPath && (args[1] as Paint).maskFilter != null)
        ..something(shadedFill([face.pointAt(0.5, 0.5)])),
    );
  });
}
