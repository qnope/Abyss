import '../../../../domain/game/player.dart';
import '../../../../domain/tech/tech_branch.dart';
import '../../../../domain/tech/tech_branch_state.dart';
import '../../../../domain/unit/unit_stats.dart';
import '../../../../domain/unit/unit_type.dart';

/// Pure computation helpers for the [ArmySelectionScreen] summary card.
///
/// Duplicates the `(atk * (1 + 0.20 * level)).round()` formula from the
/// domain's `CombatantBuilder` on purpose: keeping the UI math local
/// avoids a shared helper for a single line of arithmetic. Update both
/// if the formula changes.
class ArmySelectionSummary {
  const ArmySelectionSummary();

  int militaryLevelOf(Player player) {
    final TechBranchState? s = player.techBranches[TechBranch.military];
    if (s == null || !s.unlocked) return 0;
    return s.researchLevel;
  }

  int totalAtk(Map<UnitType, int> selected, int militaryLevel) {
    int sum = 0;
    for (final MapEntry<UnitType, int> e in selected.entries) {
      if (e.value <= 0) continue;
      final UnitStats stats = UnitStats.forType(e.key);
      final int boosted =
          (stats.atk * (1 + 0.20 * militaryLevel)).round();
      sum += boosted * e.value;
    }
    return sum;
  }

  int totalDef(Map<UnitType, int> selected) {
    int sum = 0;
    for (final MapEntry<UnitType, int> e in selected.entries) {
      if (e.value <= 0) continue;
      sum += UnitStats.forType(e.key).def * e.value;
    }
    return sum;
  }
}
