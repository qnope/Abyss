import 'package:flutter/painting.dart';

/// [text] laid out in [style] at [size], ready to paint; the caller
/// disposes of it once painted.
TextPainter baseLabelOf(String text, TextStyle style, double size) =>
    TextPainter(
      text: TextSpan(text: text, style: style.copyWith(fontSize: size)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

/// Paints [painter] with its left edge at [left] and its middle on the
/// line [middle], then disposes of it.
void paintLabel(Canvas canvas, TextPainter painter,
    {required double left, required double middle}) {
  painter
    ..paint(canvas, Offset(left, middle - painter.height / 2))
    ..dispose();
}

/// Paints [painter] centred on [centre], then disposes of it.
void paintCentredLabel(Canvas canvas, TextPainter painter, Offset centre) =>
    paintLabel(canvas, painter,
        left: centre.dx - painter.width / 2, middle: centre.dy);

/// [source] cut in dashes [dash] long, [gap] apart, along its length.
Path dashedPathOf(Path source, double dash, double gap) {
  final dashed = Path();
  for (final metric in source.computeMetrics()) {
    for (var at = 0.0; at < metric.length; at += dash + gap) {
      dashed.addPath(metric.extractPath(at, at + dash), Offset.zero);
    }
  }
  return dashed;
}
