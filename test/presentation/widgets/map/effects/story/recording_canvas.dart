import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// A canvas keeping the rectangles, paths, discs and images drawn on it,
/// with their colours, and ignoring everything else.
class RecordingCanvas implements Canvas {
  final rects = <(Rect, Color)>[];

  /// Every path drawn, with its paint's colour and style.
  final paths = <(Path, Color, PaintingStyle)>[];

  /// The middle of every filled circle drawn.
  final discs = <Offset>[];

  /// Where each image was drawn, with its paint's colour.
  final images = <(Rect, Color)>[];

  /// The colour filter of each image's paint, in the order of [images].
  final imageFilters = <ColorFilter?>[];

  /// Every rectangle, path bounds and image destination, in drawing
  /// order.
  final order = <Rect>[];

  @override
  void drawRect(Rect rect, Paint paint) {
    rects.add((rect, paint.color));
    order.add(rect);
  }

  @override
  void drawPath(Path path, Paint paint) {
    paths.add((path, paint.color, paint.style));
    order.add(path.getBounds());
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    if (paint.style == PaintingStyle.fill) discs.add(c);
  }

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) {
    images.add((dst, paint.color));
    imageFilters.add(paint.colorFilter);
    order.add(dst);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
