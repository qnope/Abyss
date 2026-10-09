import '../fight/fight_result.dart';
import '../map/monster_lair.dart';
import '../unit/unit_type.dart';

/// Outcome of a kraken wave on the kernel, for the turn summary and the
/// history.
class VolcanoReport {
  final int turn;
  final bool victory;
  final MonsterLair wave;
  final FightResult fight;

  /// Kernel level when the wave hit; it also sets the magma rampart.
  final int kernelLevel;
  final Map<UnitType, int> defenders;
  final Map<UnitType, int> survivorsIntact;
  final Map<UnitType, int> wounded;
  final Map<UnitType, int> dead;

  const VolcanoReport({
    required this.turn,
    required this.victory,
    required this.wave,
    required this.fight,
    required this.kernelLevel,
    required this.defenders,
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
  });

  /// Kernel level once the wave is over: one less when it won.
  int get kernelLevelAfter => victory ? kernelLevel : kernelLevel - 1;
}
