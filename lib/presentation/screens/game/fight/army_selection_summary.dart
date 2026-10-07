import '../../../../domain/fight/military_bonus.dart';
import '../../../../domain/game/player.dart';
import '../../../../domain/tech/tech_branch.dart';
import '../../../../domain/tech/tech_branch_state.dart';
import '../../../../domain/unit/unit_stats.dart';
import '../../../../domain/unit/unit_type.dart';

/// Pure computation helpers for the [ArmySelectionScreen] summary card.
///
/// Uses the same [MilitaryBonus] as the domain's `CombatantBuilder`, so the
/// totals shown match the stats the units fight with.
class ArmySelectionSummary {
  const ArmySelectionSummary();

  int militaryLevelOf(Player player) {
    final TechBranchState? s = player.techBranches[TechBranch.military];
    if (s == null || !s.unlocked) return 0;
    return s.researchLevel;
  }

  int totalAtk(Map<UnitType, int> selected, int militaryLevel) =>
      _total(selected, (UnitStats s) => s.atk, militaryLevel);

  int totalDef(Map<UnitType, int> selected, int militaryLevel) =>
      _total(selected, (UnitStats s) => s.def, militaryLevel);

  int _total(
    Map<UnitType, int> selected,
    int Function(UnitStats) stat,
    int militaryLevel,
  ) {
    int sum = 0;
    for (final MapEntry<UnitType, int> e in selected.entries) {
      if (e.value <= 0) continue;
      final int base = stat(UnitStats.forType(e.key));
      sum += MilitaryBonus.boost(base, militaryLevel) * e.value;
    }
    return sum;
  }
}
