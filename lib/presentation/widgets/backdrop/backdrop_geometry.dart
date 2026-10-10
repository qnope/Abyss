import 'dart:math' as math;
import 'dart:ui';

/// Pixel step every bitmap side is rounded up to: a window resized by a
/// few pixels keeps its bitmap instead of rasterizing the art again.
const double backdropBucketStep = 256;

/// Longest side of a backdrop bitmap, in pixels. Larger screens stretch
/// it slightly: soft enough for a background, and memory stays bounded.
const double backdropMaxPixels = 2048;

/// Part of an art of size [art] shown when it covers a box of size [box]
/// (like `BoxFit.cover`), centred on [focus] as far as the art allows.
Rect coverCrop(Size art, Size box, Offset focus) {
  if (box.isEmpty || art.isEmpty) return Offset.zero & art;
  final scale = math.max(box.width / art.width, box.height / art.height);
  final width = box.width / scale;
  final height = box.height / scale;
  final left = (focus.dx - width / 2).clamp(0.0, art.width - width);
  final top = (focus.dy - height / 2).clamp(0.0, art.height - height);
  return Rect.fromLTWH(left, top, width, height);
}

/// Bitmap size, in pixels, of a box of [pixels] physical pixels: capped
/// to [backdropMaxPixels], then each side rounded up to the next
/// [backdropBucketStep].
Size rasterBucket(Size pixels) {
  if (pixels.isEmpty || !pixels.isFinite) return Size.zero;
  final cap = math.min(1.0, backdropMaxPixels / pixels.longestSide);
  double round(double side) => math.min(
    backdropMaxPixels,
    (side * cap / backdropBucketStep).ceil() * backdropBucketStep,
  );
  return Size(round(pixels.width), round(pixels.height));
}
