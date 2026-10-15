import 'package:flutter/animation.dart';

/// Durations and curves of every animation of the game, so the sea moves
/// with one rhythm.
///
/// Three families: short feedback answering a touch, slow ambient cycles
/// that make the world breathe, and the steps of a staged event (a scout
/// swimming, a fight, the story of a turn).
abstract final class AbyssMotion {
  // Short feedback.

  /// A press, a highlight: barely noticed.
  static const tap = Duration(milliseconds: 150);

  /// A counter bouncing, a value appearing.
  static const quick = Duration(milliseconds: 250);

  /// A change worth a glance, such as a floating "+N".
  static const emphasis = Duration(milliseconds: 400);

  // Ambient cycles: each divides [ambientLoop], so they all loop together.

  /// A creature floating up and down.
  static const bobCycle = Duration(seconds: 4);

  /// A building swelling and settling.
  static const breatheCycle = Duration(seconds: 5);

  /// A wreck or a weed leaning from side to side.
  static const swayCycle = Duration(seconds: 6);

  /// A glow brightening and dimming.
  static const pulseCycle = Duration(seconds: 3);

  /// Every ambient cycle.
  static const ambientCycles = [bobCycle, breatheCycle, swayCycle, pulseCycle];

  /// After this long, every ambient motion is back where it started.
  static const ambientLoop = Duration(seconds: 60);

  /// Shortest gap between two ambient repaints: about 30 per second.
  static const ambientFrame = Duration(microseconds: 33334);

  // Event steps.

  /// A token swimming from one cell to another.
  static const swim = Duration(milliseconds: 900);

  /// One beat of a staged event: a wind-up, a flash, a shake.
  static const eventStep = Duration(milliseconds: 300);

  /// Fog lifting, a defeated monster fading away.
  static const fade = Duration(milliseconds: 600);

  /// Rest between two steps of a story, so each one reads.
  static const storyPause = Duration(milliseconds: 400);

  // Curves.

  /// Things arriving: fast, then settling.
  static const Curve enter = Curves.easeOutCubic;

  /// Things leaving: slow start, fast end.
  static const Curve exit = Curves.easeInCubic;

  /// A move from one place to another.
  static const Curve travel = Curves.easeInOutCubic;

  /// A small overshoot, for a bounce or a pop.
  static const Curve pop = Curves.easeOutBack;

  /// [duration], or nothing when the player asked for fewer animations:
  /// the final state then shows at once.
  static Duration orInstant(Duration duration, {required bool reduced}) =>
      reduced ? Duration.zero : duration;
}
