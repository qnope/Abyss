import 'package:hive_ce/hive.dart';

import '../map/monster_lair.dart';
import 'announced_attack.dart';

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

  /// Attacks of factions announced against this player, oldest first;
  /// empty for a player saved before the attacks.
  @HiveField(7)
  final List<AnnouncedAttack> attacks;

  // Fields 8 and 9 held the old gaps after a lost post and a hot kernel;
  // they stay unused so that old saves still load.

  /// Turn this player last lost a siege of its kernel, `null` when it
  /// never did; holds back the kraken wave of that turn.
  @HiveField(10)
  int? kernelSiegeLostTurn;

  /// Turn this player last attacked the posts of each player, by id;
  /// empty for a player saved before (`AttackCooldown`).
  @HiveField(11)
  final Map<String, int> postAttackTurns;

  /// Turn this player last besieged the kernel of each player, by id;
  /// empty for a player saved before (`AttackCooldown`).
  @HiveField(12)
  final Map<String, int> kernelAttackTurns;

  RaidState({
    this.noise = 0,
    this.totalNoise = 0,
    this.incoming,
    this.arrivalTurn,
    this.lostInARow = 0,
    this.raidsRepelled = 0,
    this.raidsLost = 0,
    List<AnnouncedAttack>? attacks,
    this.kernelSiegeLostTurn,
    Map<String, int>? postAttackTurns,
    Map<String, int>? kernelAttackTurns,
  }) : attacks = attacks ?? <AnnouncedAttack>[],
       postAttackTurns = postAttackTurns ?? <String, int>{},
       kernelAttackTurns = kernelAttackTurns ?? <String, int>{};

  bool get isIncoming => incoming != null && arrivalTurn != null;

  /// Whether the faction [attackerId] has an attack announced.
  bool hasAttackFrom(String attackerId) =>
      attacks.any((AnnouncedAttack a) => a.attackerId == attackerId);

  /// Whether an attack is announced for the end of [turn].
  bool isAttackedOn(int turn) =>
      attacks.any((AnnouncedAttack a) => a.arrivalTurn == turn);

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
