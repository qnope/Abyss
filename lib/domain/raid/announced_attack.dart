import 'package:hive_ce/hive.dart';

import '../unit/unit_type.dart';

part 'announced_attack.g.dart';

/// An attack of a faction on the human base, announced two turns before it
/// is fought, with the army it will send.
///
/// The army stays on the attacker's base until the fight, and goes with
/// the units it still has then. The [seed] drives the fight, so the same
/// game always plays the same battle.
@HiveType(typeId: 58)
class AnnouncedAttack {
  /// Id of the faction's player.
  @HiveField(0)
  final String attackerId;

  /// The units sent, by type: the composition shown to the human.
  @HiveField(1)
  final Map<UnitType, int> units;

  /// Turn at the end of which the attack is fought.
  @HiveField(2)
  final int arrivalTurn;

  @HiveField(3)
  final int seed;

  AnnouncedAttack({
    required this.attackerId,
    required this.units,
    required this.arrivalTurn,
    required this.seed,
  });
}
