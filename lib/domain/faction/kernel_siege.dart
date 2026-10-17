import 'dart:math';

import '../action/attack_held_kernel_action.dart';
import '../fight/army_planner.dart';
import '../game/difficulty.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import 'faction_personality.dart';

/// The rules of a faction's siege of a kernel held high by someone else:
/// from [hotLevel] the kernel comes before any base or post, and from
/// [steepLevel] the faction settles for a riskier win.
abstract final class KernelSiege {
  /// Kernel level from which a held kernel is a target before all others.
  static const int hotLevel = 7;

  /// Kernel level from which the faction accepts a riskier siege.
  static const int steepLevel = 8;

  /// Confidence given up from [steepLevel]: one rehearsal in eight.
  static const double steepDrop = 0.125;

  /// Lowest confidence a siege is ever accepted with: 5 wins out of 8.
  static const double minConfidence = 0.625;

  /// Off its war slots, a faction tries a hot siege once in so many turns.
  static const int offSlotEvery = 2;

  /// Whether a kernel at [level] is besieged before bases and posts.
  static bool isHot(int level) => level >= hotLevel;

  /// Whether [turn] is one where the faction of [personality] tries a hot
  /// siege off its war slots; the personalities are staggered.
  static bool isOffSlot(int turn, FactionPersonality personality) =>
      (turn + personality.index) % offSlotEvery == 0;

  /// [planner], [steepDrop] less confident against a kernel at [level] of
  /// [steepLevel] or more, never below [minConfidence].
  static ArmyPlanner plannerFor(ArmyPlanner planner, int level) {
    if (level < steepLevel) return planner;
    final double eased = max(minConfidence, planner.confidence - steepDrop);
    return ArmyPlanner(
      rehearsals: planner.rehearsals,
      confidence: min(planner.confidence, eased),
    );
  }

  /// Sieges a holder may lose a turn: each one costs it a kernel level.
  static int wonPerTurn(Difficulty difficulty) =>
      difficulty == Difficulty.easy ? 1 : 2;

  /// Whether [holder] already lost [wonPerTurn] sieges of its kernel on
  /// the current turn of [game], read from its history so a replay
  /// counts the same.
  static bool isCapped(Game game, Player holder) =>
      holder.historyEntries
          .where((HistoryEntry e) => _lost(e, game.turn))
          .length >=
      wonPerTurn(game.difficulty);

  static bool _lost(HistoryEntry e, int turn) =>
      e is BaseAssaultEntry &&
      e.turn == turn &&
      e.defending &&
      e.victory &&
      e.postName == AttackHeldKernelAction.kernelCode;
}
