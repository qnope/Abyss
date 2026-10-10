import 'dart:math';

import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import 'event_drawer.dart';
import 'event_effects.dart';
import 'event_state.dart';
import 'random_event_choice.dart';
import 'random_event_type.dart';

/// What the random events did while a turn ended.
class EventTurnOutcome {
  /// Event drawn this turn, if any; one with a choice waits for it
  /// during the next turn.
  final RandomEventType? drawn;

  /// Event left without a choice, settled with its prudent option.
  final RandomEventType? defaulted;

  const EventTurnOutcome({this.drawn, this.defaulted});
}

/// End-of-turn step of the random events, after the production: upkeeps
/// the lasting effect, settles the event left without a choice, ends the
/// lasting effects, then draws the next event when due.
abstract final class EventResolver {
  static EventTurnOutcome resolve(
    Game game,
    Player player,
    int endedTurn, {
    Random? random,
  }) {
    final Random dice = random ?? Random();
    _upkeep(game, player, endedTurn);
    final RandomEventType? defaulted = _settle(game, player, endedTurn, dice);
    player.eventState.expireEffects(endedTurn + 1);
    return EventTurnOutcome(
      drawn: _draw(game, player, endedTurn, dice),
      defaulted: defaulted,
    );
  }

  /// Upkeep of the effect lasting through [endedTurn].
  static void _upkeep(Game game, Player player, int endedTurn) {
    final RandomEventType? active = player.eventState.active;
    if (active == null || !player.eventState.isActive(active, endedTurn)) {
      return;
    }
    EventEffects.of(active).onTurnEnd(game, player, turn: endedTurn);
  }

  /// Applies the prudent option of an event whose turn of choice is over,
  /// from the next turn on.
  static RandomEventType? _settle(
    Game game,
    Player player,
    int endedTurn,
    Random dice,
  ) {
    final EventState state = player.eventState;
    if (!state.hasPending || state.pendingTurn! > endedTurn) return null;
    final RandomEventType type = state.pending!;
    EventEffects.apply(
      game,
      player,
      type,
      accept: false,
      turn: endedTurn + 1,
      random: dice,
    );
    state.clearPending();
    player.addHistoryEntry(
      EventEntry(turn: endedTurn, type: type, accepted: false, defaulted: true),
    );
    return type;
  }

  static RandomEventType? _draw(
    Game game,
    Player player,
    int endedTurn,
    Random dice,
  ) {
    final EventState state = player.eventState;
    final int? due = state.nextDrawTurn;
    if (due == null) {
      state.schedule(EventDrawer.firstDrawTurn(endedTurn, dice));
      return null;
    }
    if (endedTurn < due) return null;
    if (state.hasPending || state.active != null) {
      state.schedule(endedTurn + 1);
      return null;
    }
    final RandomEventType? type = EventDrawer.pick(
      random: dice,
      endedTurn: endedTurn,
      lastDrawn: state.lastDrawn,
      excluded: EventEffects.excludedAt(game, player, endedTurn),
    );
    if (type != null) _start(game, player, type, endedTurn, dice);
    state.schedule(EventDrawer.nextDrawTurn(endedTurn, dice));
    return type;
  }

  /// Announces [type], or plays it out at once when it has no choice.
  static void _start(
    Game game,
    Player player,
    RandomEventType type,
    int endedTurn,
    Random dice,
  ) {
    EventEffects.onDraw(game, player, type, turn: endedTurn, random: dice);
    if (type.hasChoice) {
      player.eventState.setPending(type, endedTurn + 1);
      return;
    }
    player.eventState.recordDraw(type);
    EventEffects.apply(
      game,
      player,
      type,
      accept: true,
      turn: endedTurn + 1,
      random: dice,
    );
    player.addHistoryEntry(
      EventEntry(turn: endedTurn, type: type, accepted: true, defaulted: false),
    );
  }
}
