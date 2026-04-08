import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../game/player.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import '../unit/unit_type.dart';

class FightMonsterHelpers {
  const FightMonsterHelpers._();

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

  /// Restores the given wounded combatants to `player.units`.
  static void restoreWounded(Player player, List<Combatant> wounded) {
    for (final Combatant combatant in wounded) {
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
}
