import 'dart:math';

import 'package:hive_ce/hive.dart';

import '../map/grid_position.dart';

part 'leviathan_return.g.dart';

/// Bookkeeping of "the Léviathan comes back": once per game, the guardians
/// of the first Faille the human takes strike back [delay] turns after
/// the capture, or after its Module de descente first works, whichever
/// is later: nobody can defend the Faille before.
///
/// Only the human gets it. A game keeps one from its start; games saved
/// before it existed have none and never get it.
@HiveType(typeId: 60)
class LeviathanReturn {
  /// Turns between the capture (or the Module working) and the end of the
  /// turn the guardians strike; the end of the turn before announces them.
  static const int delay = 3;

  /// Code of the Faille the guardians come back to.
  @HiveField(0)
  String? postName;

  /// Level of the map the Faille stands on.
  @HiveField(1)
  int? level;

  /// Cell of the Faille on its [level].
  @HiveField(2)
  GridPosition? at;

  /// Earliest turn at the end of which the guardians strike, [delay]
  /// turns after the capture; `null` until the first Faille is taken.
  @HiveField(3)
  int? strikeTurn;

  /// Whether it is over: fought, or cancelled with the Faille lost.
  @HiveField(4, defaultValue: false)
  bool over;

  /// Turn the Module de descente was first seen working while the Faille
  /// was held; `null` until then.
  @HiveField(5)
  int? readyTurn;

  LeviathanReturn({
    this.postName,
    this.level,
    this.at,
    this.strikeTurn,
    this.over = false,
    this.readyTurn,
  });

  /// Whether no Faille scheduled it yet in this game.
  bool get isAvailable => strikeTurn == null;

  /// Whether the guardians are still to come.
  bool get isScheduled => strikeTurn != null && !over;

  /// Turn at the end of which the guardians strike: [delay] turns after
  /// the capture or after [readyTurn], the later; `null` while the Module
  /// has not worked yet, the strike postponed.
  int? get dueTurn {
    final int? earliest = strikeTurn, ready = readyTurn;
    if (earliest == null || ready == null) return null;
    return max(earliest, ready + delay);
  }

  /// The Module de descente works during [turn]: the first time sets the
  /// strike.
  void markReady(int turn) => readyTurn ??= turn;

  /// The Faille [postName] at [at] on [level] was taken during
  /// [capturedOn]: the guardians strike [delay] turns later.
  void schedule({
    required String postName,
    required int level,
    required GridPosition at,
    required int capturedOn,
  }) {
    this.postName = postName;
    this.level = level;
    this.at = at;
    strikeTurn = capturedOn + delay;
  }

  /// Ends it for good: it never comes back.
  void end() => over = true;
}
