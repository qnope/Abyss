import 'package:hive_ce/hive.dart';

import 'random_event_type.dart';

part 'event_state.g.dart';

/// Per-player bookkeeping of the random events: when the next one is
/// drawn, the one waiting for a choice and the effect that lasts.
@HiveType(typeId: 51)
class EventState {
  /// End of the turn of the next draw, or `null` when none is scheduled
  /// yet (new game, or save made before the events).
  @HiveField(0)
  int? nextDrawTurn;

  /// Drawn event waiting for the player's choice, or `null`.
  @HiveField(1)
  RandomEventType? pending;

  /// Turn during which the player chooses for [pending].
  @HiveField(2)
  int? pendingTurn;

  /// Last drawn event, never drawn twice in a row.
  @HiveField(3)
  RandomEventType? lastDrawn;

  /// Event whose effect lasts (currents, storm), or `null`.
  @HiveField(4)
  RandomEventType? active;

  /// Last turn, inclusive, of the [active] effect.
  @HiveField(5)
  int? activeUntilTurn;

  /// Whether the player heats the farms during a cold current.
  @HiveField(6)
  bool heating;

  /// Events drawn since the start of the game.
  @HiveField(7)
  int eventsSeen;

  EventState({
    this.nextDrawTurn,
    this.pending,
    this.pendingTurn,
    this.lastDrawn,
    this.active,
    this.activeUntilTurn,
    this.heating = false,
    this.eventsSeen = 0,
  });

  bool get hasPending => pending != null && pendingTurn != null;

  /// Whether the effect of [type] applies during [turn].
  bool isActive(RandomEventType type, int turn) =>
      active == type && activeUntilTurn != null && turn <= activeUntilTurn!;

  void schedule(int turn) => nextDrawTurn = turn;

  /// Records the draw of [type], waiting for a choice during [turn].
  void setPending(RandomEventType type, int turn) {
    pending = type;
    pendingTurn = turn;
    lastDrawn = type;
    eventsSeen++;
  }

  void clearPending() {
    pending = null;
    pendingTurn = null;
  }

  /// Starts the lasting effect of [type], through [untilTurn] inclusive.
  void activate(RandomEventType type, {required int untilTurn}) {
    active = type;
    activeUntilTurn = untilTurn;
    heating = false;
  }

  /// Ends the lasting effect once [turn] is past its last turn.
  void expireEffects(int turn) {
    final until = activeUntilTurn;
    if (until == null || turn <= until) return;
    active = null;
    activeUntilTurn = null;
    heating = false;
  }
}
