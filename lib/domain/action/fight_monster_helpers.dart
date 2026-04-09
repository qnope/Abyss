import 'dart:math';

import '../fight/casualty_calculator.dart';
import '../fight/casualty_split.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/fight_result.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/monster_lair.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import '../tech/tech_branch.dart';
import '../tech/tech_branch_state.dart';
import '../unit/unit_type.dart';
import 'fight_casualty_breakdown.dart';
import 'fight_monster_result.dart';

class FightMonsterHelpers {
  const FightMonsterHelpers._();

  /// Returns the player's military research level, or `0` if the branch is
  /// missing or still locked.
  static int militaryResearchLevelOf(Player player) {
    final TechBranchState? state = player.techBranches[TechBranch.military];
    if (state == null || !state.unlocked) return 0;
    return state.researchLevel;
  }

  /// Guarded pct lost calculator.
  static double computePctLost(List<Combatant> initial, List<Combatant> finalC) {
    final int initialHp =
        initial.fold<int>(0, (int acc, Combatant c) => acc + c.maxHp);
    if (initialHp <= 0) {
      return 0;
    }
    final int finalHp =
        finalC.fold<int>(0, (int acc, Combatant c) => acc + c.currentHp);
    return (initialHp - finalHp) / initialHp;
  }

  /// Restores the given combatants to `player.units` (one stock increment
  /// per combatant).
  static void restoreToStock(Player player, List<Combatant> combatants) {
    for (final Combatant combatant in combatants) {
      final UnitType? type =
          CombatantBuilder.unitTypeFromKey(combatant.typeKey);
      if (type == null) {
        continue;
      }
      final int current = player.units[type]?.count ?? 0;
      player.units[type]!.count = current + 1;
    }
  }

  /// Applies loot deltas to player resources clamped to maxStorage. Returns
  /// the actual delta map (after clamping).
  static Map<ResourceType, int> applyLoot(
    Player player,
    Map<ResourceType, int> loot,
  ) {
    final Map<ResourceType, int> applied = <ResourceType, int>{};
    for (final MapEntry<ResourceType, int> entry in loot.entries) {
      final Resource? resource = player.resources[entry.key];
      if (resource == null) {
        applied[entry.key] = 0;
        continue;
      }
      final int before = resource.amount;
      resource.amount =
          (resource.amount + entry.value).clamp(0, resource.maxStorage);
      applied[entry.key] = resource.amount - before;
    }
    return applied;
  }

  /// Converts a list of combatants grouped by unit type to a count map.
  static Map<UnitType, int> combatantsByType(List<Combatant> combatants) {
    final Map<UnitType, int> map = <UnitType, int>{};
    for (final Combatant c in combatants) {
      final UnitType? type = CombatantBuilder.unitTypeFromKey(c.typeKey);
      if (type == null) continue;
      map[type] = (map[type] ?? 0) + 1;
    }
    return map;
  }

  /// Resolves the post-fight casualty breakdown: splits the player's fallen
  /// combatants into wounded/dead using [CasualtyCalculator], restores
  /// unharmed and wounded survivors to the player's stock, and returns the
  /// per-[UnitType] counts for intact survivors, wounded, and dead.
  static FightCasualtyBreakdown resolveCasualties({
    required Player player,
    required FightResult fightResult,
    Random? random,
  }) {
    final double pctLost = computePctLost(
      fightResult.initialPlayerCombatants,
      fightResult.finalPlayerCombatants,
    );
    final List<Combatant> fallen = <Combatant>[];
    final List<Combatant> alive = <Combatant>[];
    for (int i = 0; i < fightResult.finalPlayerCombatants.length; i++) {
      final Combatant initial = fightResult.initialPlayerCombatants[i];
      final bool down = fightResult.finalPlayerCombatants[i].currentHp <= 0;
      (down ? fallen : alive).add(initial);
    }
    final CasualtySplit split =
        CasualtyCalculator(random: random).partition(fallen, pctLost);
    restoreToStock(player, alive);
    restoreToStock(player, split.wounded);
    return FightCasualtyBreakdown(
      survivorsIntact: combatantsByType(alive),
      wounded: combatantsByType(split.wounded),
      dead: combatantsByType(split.dead),
    );
  }

  /// Builds a [CombatEntry] for the history log from the captured lair and
  /// the successful [FightMonsterResult]. Returns `null` if either is
  /// missing.
  static CombatEntry? buildCombatEntry({
    required int turn,
    required int targetX,
    required int targetY,
    required MonsterLair? lair,
    required FightMonsterResult result,
  }) {
    if (lair == null || result.fight == null) return null;
    return CombatEntry(
      turn: turn,
      victory: result.victory,
      targetX: targetX,
      targetY: targetY,
      lair: lair,
      fightResult: result.fight!,
      loot: result.loot,
      sent: result.sent,
      survivorsIntact: result.survivorsIntact,
      wounded: result.wounded,
      dead: result.dead,
    );
  }
}
