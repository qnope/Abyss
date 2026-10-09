import 'package:hive_ce/hive.dart';

import '../map/monster_lair.dart';

part 'volcano_state.g.dart';

/// Per-player bookkeeping of the waves that try to take the kernel back.
@HiveType(typeId: 47)
class VolcanoState {
  /// Announced wave, or `null` when none is coming.
  @HiveField(0)
  MonsterLair? incoming;

  /// Turn at the end of which [incoming] hits the kernel.
  @HiveField(1)
  int? arrivalTurn;

  /// Waves the garrison pushed back since the start of the game.
  @HiveField(2)
  int wavesRepelled;

  /// Kernel levels the waves took since the start of the game.
  @HiveField(3)
  int levelsLost;

  VolcanoState({
    this.incoming,
    this.arrivalTurn,
    this.wavesRepelled = 0,
    this.levelsLost = 0,
  });

  bool get isIncoming => incoming != null && arrivalTurn != null;

  void announce(MonsterLair wave, int turn) {
    incoming = wave;
    arrivalTurn = turn;
  }

  void clearIncoming() {
    incoming = null;
    arrivalTurn = null;
  }

  /// Records the outcome of a wave fought on the kernel.
  void recordOutcome({required bool victory}) {
    if (victory) {
      wavesRepelled++;
    } else {
      levelsLost++;
    }
  }
}
