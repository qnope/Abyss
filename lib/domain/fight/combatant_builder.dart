import '../map/monster_lair.dart';
import '../unit/unit_stats.dart';
import '../unit/unit_type.dart';
import 'combat_side.dart';
import 'combatant.dart';
import 'monster_unit_stats.dart';

class CombatantBuilder {
  const CombatantBuilder._();

  static List<Combatant> playerCombatantsFrom(
    Map<UnitType, int> selectedUnits,
  ) {
    final List<Combatant> combatants = <Combatant>[];
    for (final MapEntry<UnitType, int> entry in selectedUnits.entries) {
      final int count = entry.value;
      if (count <= 0) {
        continue;
      }
      final UnitStats stats = UnitStats.forType(entry.key);
      for (int i = 0; i < count; i++) {
        combatants.add(
          Combatant(
            side: CombatSide.player,
            typeKey: entry.key.name,
            maxHp: stats.hp,
            atk: stats.atk,
            def: stats.def,
          ),
        );
      }
    }
    return combatants;
  }

  static List<Combatant> monsterCombatantsFrom(MonsterLair lair) {
    final int level = lair.level;
    final MonsterUnitStats stats = MonsterUnitStats.forLevel(level);
    final String typeKey = 'monsterL$level';
    return List<Combatant>.generate(
      lair.unitCount,
      (_) => Combatant(
        side: CombatSide.monster,
        typeKey: typeKey,
        maxHp: stats.hp,
        atk: stats.atk,
        def: stats.def,
      ),
    );
  }

  static UnitType? unitTypeFromKey(String key) {
    for (final UnitType type in UnitType.values) {
      if (type.name == key) {
        return type;
      }
    }
    return null;
  }
}
