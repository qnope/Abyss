import 'package:hive_ce/hive.dart';

import '../map/monster_lair.dart';

part 'raid_state.g.dart';

/// Per-player raid bookkeeping: the noise gauge and the announced raid.
@HiveType(typeId: 38)
class RaidState {
  /// Current gauge level, emptied each time a raid is announced.
  @HiveField(0)
  int noise;

  /// Noise made since the start of the game; drives the wave strength.
  @HiveField(1)
  int totalNoise;

  /// Announced wave, or `null` when no raid is coming.
  @HiveField(2)
  MonsterLair? incoming;

  /// Turn at the end of which [incoming] hits the base.
  @HiveField(3)
  int? arrivalTurn;

  /// Raids lost in a row, reset by a victory.
  @HiveField(4)
  int lostInARow;

  /// Raids pushed back since the start of the game.
  @HiveField(5)
  int raidsRepelled;

  /// Raids lost since the start of the game.
  @HiveField(6)
  int raidsLost;

  RaidState({
    this.noise = 0,
    this.totalNoise = 0,
    this.incoming,
    this.arrivalTurn,
    this.lostInARow = 0,
    this.raidsRepelled = 0,
    this.raidsLost = 0,
  });

  bool get isIncoming => incoming != null && arrivalTurn != null;

  void addNoise(int amount) {
    if (amount <= 0) return;
    noise += amount;
    totalNoise += amount;
  }

  /// Takes up to [amount] points off the gauge, never below zero; the
  /// noise already made still counts in [totalNoise].
  void quiet(int amount) {
    noise = noise > amount ? noise - amount : 0;
  }

  void announce(MonsterLair wave, int turn) {
    incoming = wave;
    arrivalTurn = turn;
    noise = 0;
  }

  /// Records the outcome of a raid fought on the base.
  void recordOutcome({required bool victory}) {
    if (victory) {
      raidsRepelled++;
      lostInARow = 0;
    } else {
      raidsLost++;
      lostInARow++;
    }
  }

  void clearIncoming() {
    incoming = null;
    arrivalTurn = null;
  }
}
