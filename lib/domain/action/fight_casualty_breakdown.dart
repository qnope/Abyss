import '../unit/unit_type.dart';

/// Summary of the post-fight unit outcome for the player side.
///
/// Produced by `FightMonsterHelpers.resolveCasualties` so the fight action
/// can populate its result and history entry from a single value.
class FightCasualtyBreakdown {
  final Map<UnitType, int> survivorsIntact;
  final Map<UnitType, int> wounded;
  final Map<UnitType, int> dead;

  const FightCasualtyBreakdown({
    required this.survivorsIntact,
    required this.wounded,
    required this.dead,
  });
}
