import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../theme/abyss_motion.dart';

/// How a living creature undulates, as a pure function of a frame: a
/// grid laid over its sprite whose vertices a travelling wave sways more
/// and more toward the bottom (tentacles and tails), while the body
/// squashes and stretches a little and the head stays put.
///
/// Positions are fractions of the sprite's side, (0, 0) its top left.
/// Frames loop seamlessly over [frames], played over
/// [AbyssMotion.swimCycle].
@immutable
class CreatureUndulation {
  /// Frames of one loop.
  final int frames;

  /// Squares of the grid, per side.
  final int grid;

  /// Sideways sway of the bottom row.
  final double amplitude;

  /// How much shorter (and wider) the body gets when squashed.
  final double squash;

  /// Wavelengths of the travelling wave from head to bottom.
  final double waves;

  static const standard = CreatureUndulation();

  const CreatureUndulation({
    this.frames = 12,
    this.grid = 8,
    this.amplitude = 0.06,
    this.squash = 0.03,
    this.waves = 0.75,
  });

  /// Furthest a vertex goes from its rest place, on either axis.
  double get reach => amplitude + squash;

  /// The (grid + 1)² vertices of the grid at rest, row by row.
  List<Offset> restVertices() => [
        for (var row = 0; row <= grid; row++)
          for (var col = 0; col <= grid; col++)
            Offset(col / grid, row / grid),
      ];

  /// The vertices of [restVertices] as moved at [frame] (any integer:
  /// it wraps around the loop).
  List<Offset> verticesAt(int frame) {
    final time = (frame % frames) / frames;
    final body = squash * math.sin(2 * math.pi * time);
    return [
      for (final rest in restVertices()) _moved(rest, time, body),
    ];
  }

  Offset _moved(Offset rest, double time, double body) {
    final depth = rest.dy;
    final sway = amplitude *
        depth *
        depth *
        math.sin(2 * math.pi * (time - waves * depth));
    final x = 0.5 + (rest.dx - 0.5) * (1 + body * depth) + sway;
    return Offset(x, depth * (1 - body));
  }

  /// Indices of [restVertices] drawing two triangles per grid square.
  List<int> triangles() {
    final side = grid + 1;
    return [
      for (var row = 0; row < grid; row++)
        for (var col = 0; col < grid; col++) ...[
          row * side + col,
          row * side + col + 1,
          (row + 1) * side + col,
          row * side + col + 1,
          (row + 1) * side + col + 1,
          (row + 1) * side + col,
        ],
    ];
  }

  /// The frame shown at [seconds] on a shared clock, shifted by [phase],
  /// a fraction of the loop (only its fractional part counts).
  int frameAt(double seconds, {double phase = 0}) {
    final turn = seconds * 1e6 / AbyssMotion.swimCycle.inMicroseconds + phase;
    final share = turn - turn.floorToDouble();
    return (share * frames).floor() % frames;
  }
}
