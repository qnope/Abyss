import 'dart:math' as math;
import 'dart:ui';

/// Chance that a step along a crest raises a pinnacle.
const _pinnacleChance = 0.22;

/// The crest of a trench wall across a tile [width] by [height], from
/// left to right: around [base] (a share of the height, down from the
/// top) and up to [amplitude] higher, in slow waves shifted by [phase],
/// broken by thin pinnacles.
///
/// Ends at the right edge at the height it starts with on the left, and
/// its waves fit the width a whole number of times, so a tile drawn next
/// to itself joins seamlessly. Drawn from [random]: the same seed gives
/// the same crest.
List<Offset> ridgeCrest(
  math.Random random, {
  required double width,
  required double height,
  required double base,
  required double amplitude,
  required double phase,
}) {
  final waves = math.max(1, (width * 0.013 / math.pi).round());
  final frequency = math.pi * waves / width;
  double heightAt(double x) =>
      (base -
          amplitude *
              (0.35 +
                  0.65 *
                      math.sin(frequency * x + phase).abs() *
                      (0.6 + 0.4 * random.nextDouble()))) *
      height;
  final crest = <Offset>[];
  var x = 0.0;
  while (x < width) {
    final y = heightAt(x);
    final wide = 8 + 8 * random.nextDouble();
    if (crest.isNotEmpty &&
        random.nextDouble() < _pinnacleChance &&
        x + wide < width) {
      final tall = (0.08 + 0.1 * random.nextDouble()) * height;
      crest.addAll([
        Offset(x, y),
        Offset(x + 0.3 * wide, y - 0.7 * tall),
        Offset(x + 0.45 * wide, y - tall),
        Offset(x + 0.62 * wide, y - 0.78 * tall),
        Offset(x + wide, y),
      ]);
      x += wide;
    } else {
      crest.add(Offset(x, y));
      x += 10 + 14 * random.nextDouble();
    }
  }
  return crest..add(Offset(width, crest.first.dy));
}
