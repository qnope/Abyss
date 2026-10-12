import 'dart:math';

import '../action/post_takeover.dart';
import '../faction/faction_attack_report.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/grid_position.dart';
import '../map/transition_base.dart';
import '../map/transition_base_type.dart';
import 'leviathan_announcement.dart';
import 'leviathan_battle.dart';
import 'leviathan_return.dart';

export 'leviathan_announcement.dart';

/// What the guardians did while a turn ended.
class LeviathanTurnOutcome {
  /// Their attack on the Faille fought this turn, if any.
  final FactionAttackReport? report;

  /// Their attack announced this turn; it strikes at the end of the next.
  final LeviathanAnnouncement? announced;

  const LeviathanTurnOutcome({this.report, this.announced});
}

/// "The Léviathan comes back" ([LeviathanReturn]): scheduled by the first
/// Faille the human takes, postponed while its Module de descente does
/// not work (nobody could defend it), announced by the end of the turn
/// before it strikes, fought at the end of the turn it strikes, like a
/// volcano wave. It is cancelled when the human no longer holds the Faille.
abstract final class LeviathanResolver {
  /// [player] took [base] at [at] on [level] during the current turn.
  static void onCapture(
    Game game,
    Player player, {
    required TransitionBase base,
    required int level,
    required GridPosition at,
  }) {
    final LeviathanReturn? state = game.leviathanReturn;
    if (state == null ||
        !state.isAvailable ||
        player.id != game.humanPlayerId ||
        base.type != TransitionBaseType.faille) {
      return;
    }
    state.schedule(
      postName: base.name,
      level: level,
      at: at,
      capturedOn: game.turn,
    );
    _markReady(game, state);
  }

  /// The attack the human faces at the end of the current turn, if any.
  static LeviathanAnnouncement? announcedNow(Game game) {
    final LeviathanReturn? state = game.leviathanReturn;
    if (state == null || state.dueTurn != game.turn) return null;
    return _postOf(game, state) == null ? null : _announcement(state);
  }

  /// End-of-turn step, before the turn counter moves on: fights the
  /// guardians due at the end of this turn, or announces them for the
  /// next one.
  static LeviathanTurnOutcome resolve(Game game, {Random? random}) {
    final LeviathanReturn? state = game.leviathanReturn;
    if (state == null || !state.isScheduled) {
      return const LeviathanTurnOutcome();
    }
    final int ended = game.turn;
    _markReady(game, state);
    final int? strike = state.dueTurn;
    if (strike == null || strike > ended + 1) {
      return const LeviathanTurnOutcome();
    }
    final TransitionBase? post = _postOf(game, state);
    if (post == null) {
      state.end();
      return const LeviathanTurnOutcome();
    }
    if (strike == ended + 1) {
      return LeviathanTurnOutcome(announced: _announcement(state));
    }
    state.end();
    return LeviathanTurnOutcome(
      report: LeviathanBattle.fight(game, post, turn: ended, random: random),
    );
  }

  /// Records the turn the Module first works while the Faille is held.
  static void _markReady(Game game, LeviathanReturn state) {
    if (state.readyTurn != null || _postOf(game, state) == null) return;
    if (PostTakeover.passageWorks(
      game.humanPlayer,
      TransitionBaseType.faille,
    )) {
      state.markReady(game.turn);
    }
  }

  /// The Faille, while the human still holds it.
  static TransitionBase? _postOf(Game game, LeviathanReturn state) {
    if (!state.isScheduled) return null;
    final GridPosition at = state.at!;
    final TransitionBase? post =
        game.levels[state.level]?.cellAt(at.x, at.y).transitionBase;
    return post?.capturedBy == game.humanPlayerId ? post : null;
  }

  static LeviathanAnnouncement _announcement(LeviathanReturn state) =>
      LeviathanAnnouncement(
        postName: state.postName!,
        level: state.level!,
        at: state.at!,
        turn: state.dueTurn!,
      );
}
