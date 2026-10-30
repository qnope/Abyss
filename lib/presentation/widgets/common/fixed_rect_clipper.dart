import 'package:flutter/widgets.dart';

/// Clips to a fixed [rect] of the box, whatever its size: for a
/// [ClipRect] keeping a costly layer to the part of it that shows.
class FixedRectClipper extends CustomClipper<Rect> {
  final Rect rect;

  const FixedRectClipper(this.rect);

  @override
  Rect getClip(Size size) => rect;

  @override
  bool shouldReclip(FixedRectClipper oldClipper) => oldClipper.rect != rect;
}
