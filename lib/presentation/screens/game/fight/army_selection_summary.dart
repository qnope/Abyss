import '../../../../domain/fight/unit_boost.dart';
import '../../../../domain/game/player.dart';
import '../../../../domain/tech/tech_effects.dart';
import '../../../../domain/unit/unit_stats.dart';
import '../../../../domain/unit/unit_type.dart';

/// Pure computation helpers for the [ArmySelectionScreen] summary card.
///
/// Uses the same [UnitBoost] as the domain's `CombatantBuilder`, so the
/// totals shown match the stats the units fight with.
class ArmySelectionSummary {
  const ArmySelectionSummary();

  /// Boost of the units on the attack, as every selection screen sends.
  UnitBoost boostOf(Player player) =>
      TechEffects(player.techBranches).unitBoost(attacking: true);

  int totalAtk(Map<UnitType, int> selected, UnitBoost boost) =>
      _total(selected, (UnitStats s) => boost.atk(s.atk));

  int totalDef(Map<UnitType, int> selected, UnitBoost boost) =>
      _total(selected, (UnitStats s) => boost.def(s.def));

  int _total(Map<UnitType, int> selected, int Function(UnitStats) stat) {
    int sum = 0;
    for (final MapEntry<UnitType, int> e in selected.entries) {
      if (e.value <= 0) continue;
      sum += stat(UnitStats.forType(e.key)) * e.value;
    }
    return sum;
  }
}
