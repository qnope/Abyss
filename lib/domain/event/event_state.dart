import 'package:hive_ce/hive.dart';

import '../map/monster_lair.dart';
import '../resource/resource_type.dart';
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

  /// Survivors met by the [pending] survivors event, who join as
  /// harpoonists if welcomed.
  @HiveField(8)
  int? survivors;

  /// Resource the [pending] caravan takes, the most abundant at its draw.
  @HiveField(9)
  ResourceType? tradeFrom;

  /// Resource the [pending] caravan gives, the scarcest at its draw.
  @HiveField(10)
  ResourceType? tradeTo;

  /// Wave of the predators drawn, kept until they are fought or baited.
  @HiveField(11)
  MonsterLair? predatorWave;

  /// Turn at the end of which the faced [predatorWave] strikes the base.
  @HiveField(12)
  int? predatorsTurn;

  EventState({
    this.nextDrawTurn,
    this.pending,
    this.pendingTurn,
    this.lastDrawn,
    this.active,
    this.activeUntilTurn,
    this.heating = false,
    this.eventsSeen = 0,
    this.survivors,
    this.tradeFrom,
    this.tradeTo,
    this.predatorWave,
    this.predatorsTurn,
  });

  bool get hasPending => pending != null && pendingTurn != null;

  /// Whether the effect of [type] applies during [turn].
  bool isActive(RandomEventType type, int turn) =>
      active == type && activeUntilTurn != null && turn <= activeUntilTurn!;

  void schedule(int turn) => nextDrawTurn = turn;

  /// Records the draw of [type], never drawn twice in a row.
  void recordDraw(RandomEventType type) {
    lastDrawn = type;
    eventsSeen++;
  }

  /// Records the draw of [type], waiting for a choice during [turn].
  void setPending(RandomEventType type, int turn) {
    recordDraw(type);
    pending = type;
    pendingTurn = turn;
  }

  /// Settles the [pending] event, forgetting its offer.
  void clearPending() {
    pending = null;
    pendingTurn = null;
    survivors = null;
    tradeFrom = null;
    tradeTo = null;
  }

  /// Forgets the predators, fought or baited away.
  void clearPredators() {
    predatorWave = null;
    predatorsTurn = null;
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
