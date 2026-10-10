import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../../theme/abyss_colors.dart';

/// One depth of marine snow: every flake of a layer shares its size,
/// colours and speed, so the whole layer is a single batched draw.
class SnowLayer {
  /// Index of the layer's first flake in the field.
  final int start;
  final int count;

  /// Radius of a flake's bright core, in logical pixels.
  final double radius;

  /// Loops through the screen per animation cycle: a whole number, so
  /// the cycle restarts seamlessly. Near flakes rise faster (parallax).
  final int laps;

  final Color core;
  final Color halo;

  const SnowLayer({
    required this.start,
    required this.count,
    required this.radius,
    required this.laps,
    required this.core,
    required this.halo,
  });
}

/// Precomputed flakes of marine snow slowly rising and drifting.
///
/// Positions are pure functions of the animation progress `t` in 0..1,
/// written into caller-owned buffers so painting allocates nothing.
class MarineSnowField {
  /// Distance above and below the box where flakes wrap around, unseen.
  static const margin = 24.0;

  final List<SnowLayer> layers;
  final Float32List _x;
  final Float32List _phase;
  final Float32List _drift;
  final Float32List _driftPhase;
  final Int8List _driftLaps;

  MarineSnowField._(
    this.layers,
    this._x,
    this._phase,
    this._drift,
    this._driftPhase,
    this._driftLaps,
  );

  /// Builds the same field for the same [seed].
  factory MarineSnowField({int seed = 11}) {
    final random = math.Random(seed);
    const specs = [(26, 0.9, 1, 0.3), (16, 1.4, 2, 0.4), (8, 2.0, 3, 0.48)];
    final layers = <SnowLayer>[];
    var start = 0;
    for (final (count, radius, laps, alpha) in specs) {
      layers.add(
        SnowLayer(
          start: start,
          count: count,
          radius: radius,
          laps: laps,
          core: AbyssColors.pearlWhite.withValues(alpha: alpha),
          halo: AbyssColors.biolumCyan.withValues(alpha: alpha * 0.16),
        ),
      );
      start += count;
    }
    Float32List fill(double Function() next) =>
        Float32List.fromList([for (var i = 0; i < start; i++) next()]);
    return MarineSnowField._(
      layers,
      fill(random.nextDouble),
      fill(random.nextDouble),
      fill(() => 0.008 + random.nextDouble() * 0.022),
      fill(random.nextDouble),
      Int8List.fromList([
        for (var i = 0; i < start; i++) 1 + random.nextInt(2),
      ]),
    );
  }

  int get count => _x.length;

  /// Writes the `x, y` of every flake of [layer] at progress [t] into
  /// [out], which holds `2 * layer.count` values.
  void writePositions(SnowLayer layer, double t, Size size, Float32List out) {
    for (var i = 0; i < layer.count; i++) {
      final flake = layer.start + i;
      out[2 * i] = _xAt(flake, t) * size.width;
      out[2 * i + 1] = _yAt(flake, layer.laps, t, size.height);
    }
  }

  /// Position of flake [index] at progress [t], for tests and tools.
  Offset positionAt(int index, double t, Size size) {
    final laps = layers.lastWhere((l) => l.start <= index).laps;
    return Offset(
      _xAt(index, t) * size.width,
      _yAt(index, laps, t, size.height),
    );
  }

  double _xAt(int i, double t) =>
      _x[i] +
      _drift[i] * math.sin(2 * math.pi * (t * _driftLaps[i] + _driftPhase[i]));

  double _yAt(int i, int laps, double t, double height) {
    final rise = (_phase[i] + t * laps) % 1.0;
    return height + margin - rise * (height + 2 * margin);
  }
}
