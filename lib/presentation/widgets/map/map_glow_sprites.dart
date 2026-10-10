import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';
import 'map_cell_visual.dart';

/// Proportions of the glow, expressed in a 48 logical-pixel cell.
const _referenceCell = 48.0;
const _coreDiameter = 28.0;
const _blurRadius = 12.0;
const _spread = 4.0;

/// Renders a [MapGlow] once into a square bitmap of [size] pixels, so the
/// blur is computed at load time instead of on every frame.
Future<ui.Image> rasterizeGlow(MapGlow glow, int size) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final scale = size / _referenceCell;
  canvas.scale(scale);
  _paintGlow(canvas, glow);
  final picture = recorder.endRecording();
  return picture.toImage(size, size).whenComplete(picture.dispose);
}

void _paintGlow(Canvas canvas, MapGlow glow) {
  const center = Offset(_referenceCell / 2, _referenceCell / 2);
  const radius = _coreDiameter / 2;
  final color = _glowColor(glow);
  final shadow = Paint()
    ..color = color.withValues(alpha: 0.6)
    ..maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      Shadow.convertRadiusToSigma(_blurRadius),
    );
  canvas.drawCircle(center, radius + _spread, shadow);
  if (glow == MapGlow.passage || glow == MapGlow.wreck) {
    final core = Paint()..color = color.withValues(alpha: 0.3);
    canvas.drawCircle(center, radius, core);
    return;
  }
  _paintBolt(canvas, center, color);
}

void _paintBolt(Canvas canvas, Offset center, Color color) {
  const icon = Icons.electric_bolt;
  final painter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: _coreDiameter,
        color: color,
      ),
    ),
  )..layout();
  final offset = center - Offset(painter.width / 2, painter.height / 2);
  painter.paint(canvas, offset);
  painter.dispose();
}

Color _glowColor(MapGlow glow) => switch (glow) {
      MapGlow.passage => AbyssColors.biolumPurple,
      MapGlow.wreck => AbyssColors.energyYellow,
      MapGlow.capturedBase => AbyssColors.biolumCyan,
      MapGlow.hostileBase || MapGlow.none => AbyssColors.error,
    };
