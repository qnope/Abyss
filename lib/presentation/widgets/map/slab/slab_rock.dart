import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../../theme/abyss_slab_theme.dart';
import 'iso_slab.dart';

/// Draws the details of the rock of a slab's faces, in projection
/// coordinates, each kind in a few batched draws: strata parallel to the
/// lip, stones set in the rock, algae hanging over the lip and specks
/// glowing in it. Sizes are given in [unit]s, the slab's depth over the
/// mockup's.
abstract final class SlabRock {
  /// Strata lines across a face, and how much they wave, as a share of
  /// its depth.
  static const strataCount = 5;
  static const _strataWave = 0.02;

  /// Shades the stones are sorted into, one batched draw each.
  static const _stoneShades = 3;

  /// Strata lines across [face], each over its dark groove.
  static void strata(Canvas canvas, SlabFace face, double unit) {
    final steps = (face.tiles * 1.5).ceil().clamp(8, 1 << 12);
    final colour =
        face.lit ? AbyssSlabTheme.litStratum : AbyssSlabTheme.shadedStratum;
    for (var k = 1; k <= strataCount; k++) {
      final t = k / (strataCount + 1.5);
      final line = Path();
      for (var s = 0; s <= steps; s++) {
        final wave = _strataWave * math.sin(s * 0.9 + k);
        final p = face.pointAt(s / steps, t + wave);
        s == 0 ? line.moveTo(p.dx, p.dy) : line.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(line, Paint()
        ..style = PaintingStyle.stroke
        ..color = colour.withValues(alpha: 0.45 - 0.35 * t)
        ..strokeWidth = (1.2 - 0.6 * t) * unit);
      canvas.drawPath(line.shift(Offset(0, 2.8 * unit)), Paint()
        ..style = PaintingStyle.stroke
        ..color = AbyssSlabTheme.stratumGroove.withValues(alpha: 0.4 - 0.25 * t)
        ..strokeWidth = 0.8 * unit);
    }
  }

  /// The stones of [face], batched by shade, then their glints.
  static void stones(Canvas canvas, SlabFace face, double unit) {
    final shades = List.generate(_stoneShades, (_) => Path());
    final glints = Path();
    for (final (:centre, :radius, :shade) in face.stones) {
      final bucket = (shade * _stoneShades).floor().clamp(0, _stoneShades - 1);
      shades[bucket].addOval(Rect.fromCenter(
          center: centre, width: 2 * radius, height: 1.4 * radius));
      glints
        ..moveTo(centre.dx - 0.7 * radius, centre.dy - 0.2 * radius)
        ..relativeQuadraticBezierTo(
            0.6 * radius, -0.6 * radius, 1.3 * radius, 0);
    }
    for (var i = 0; i < _stoneShades; i++) {
      final colour = Color.lerp(AbyssSlabTheme.stoneLight,
          AbyssSlabTheme.stoneDark, (i + 0.5) / _stoneShades)!;
      canvas.drawPath(shades[i], Paint()..color = colour);
    }
    canvas.drawPath(glints, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * unit
      ..color = AbyssSlabTheme.stoneGlint);
  }

  /// The algae hanging from the lip of [face], each its own width.
  static void strands(Canvas canvas, SlabFace face) {
    for (final (:root, :length, :sway, :width, :tint) in face.strands) {
      final path = Path()
        ..moveTo(root.dx, root.dy)
        ..relativeQuadraticBezierTo(sway, length / 2, 0.4 * sway, length);
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = AbyssSlabTheme.strands[tint]
        ..strokeWidth = width);
    }
  }

  /// The [specks] of a slab in three batches: halos, glows, cores.
  static void specks(Canvas canvas, List<Offset> specks, double unit) {
    final points = Float32List(2 * specks.length);
    for (final (i, p) in specks.indexed) {
      points[2 * i] = p.dx;
      points[2 * i + 1] = p.dy;
    }
    for (final (colour, diameter) in [
      (AbyssSlabTheme.speckHalo, 5.0),
      (AbyssSlabTheme.speckGlow, 2.4),
      (AbyssSlabTheme.speckCore, 1.4),
    ]) {
      canvas.drawRawPoints(ui.PointMode.points, points, Paint()
        ..color = colour
        ..strokeCap = StrokeCap.round
        ..strokeWidth = diameter * unit);
    }
  }
}
