import 'dart:math' as math;

import '../../theme/abyss_motion.dart';
import 'sprite_motion.dart';

/// The idle motions that keep the sea alive, as pure functions of time.
///
/// Each one loops seamlessly over its cycle (and so over
/// [AbyssMotion.ambientLoop]) with small amplitudes, so a sprite only
/// seems to live, never to wander. A per-sprite phase from [phaseOf]
/// keeps neighbours from moving in step.
enum AmbientMotion {
  /// Does not move.
  still(Duration.zero),

  /// Floats up and down by 3% of its height.
  bob(AbyssMotion.bobCycle),

  /// Swells to 104% and settles back.
  breathe(AbyssMotion.breatheCycle),

  /// Leans 3 degrees each way around its bottom.
  sway(AbyssMotion.swayCycle),

  /// Stays still while its glow goes from 0.2 to 0.6 opacity.
  pulse(AbyssMotion.pulseCycle);

  /// Time to go through one whole motion.
  final Duration cycle;

  const AmbientMotion(this.cycle);

  static const _bobAmplitude = 0.03;
  static const _breatheAmplitude = 0.04;
  static const _swayAmplitude = 3 * math.pi / 180;
  static const _glowLow = 0.2;
  static const _glowHigh = 0.6;

  /// The pose at [seconds] on a shared clock, shifted by [phase], a
  /// fraction of the cycle (only its fractional part counts).
  SpriteMotion at(double seconds, {double phase = 0}) {
    if (this == still) return SpriteMotion.rest;
    final turn = seconds * 1e6 / cycle.inMicroseconds + phase;
    final wave = math.sin(2 * math.pi * turn);
    final rise = (1 - math.cos(2 * math.pi * turn)) / 2;
    return switch (this) {
      still => SpriteMotion.rest,
      bob => SpriteMotion(dy: _bobAmplitude * wave),
      breathe => SpriteMotion(scale: 1 + _breatheAmplitude * rise),
      sway => SpriteMotion(
        rotation: _swayAmplitude * wave,
        pivot: SpritePivot.bottom,
      ),
      pulse => SpriteMotion(glow: _glowLow + (_glowHigh - _glowLow) * rise),
    };
  }

  /// A stable phase in [0, 1) for the sprite at ([x], [y]), or at index
  /// [x] of a list: the plastic ratio spreads neighbours far apart,
  /// along rows, columns and diagonals alike.
  static double phaseOf(int x, [int y = 0]) {
    final value = x * 0.7548776662 + y * 0.5698402910;
    return value - value.floorToDouble();
  }
}
