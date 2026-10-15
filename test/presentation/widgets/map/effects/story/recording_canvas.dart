import 'package:flutter/painting.dart';

/// A canvas keeping the rectangles drawn on it, with their colours, and
/// ignoring everything else.
class RecordingCanvas implements Canvas {
  final rects = <(Rect, Color)>[];

  @override
  void drawRect(Rect rect, Paint paint) => rects.add((rect, paint.color));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
