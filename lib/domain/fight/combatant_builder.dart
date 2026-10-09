import '../map/monster_family.dart';
import '../map/monster_lair.dart';
import '../unit/unit_stats.dart';
import '../unit/unit_type.dart';
import 'combat_side.dart';
import 'combatant.dart';
import 'unit_boost.dart';
import 'monster_unit_stats.dart';

class CombatantBuilder {
  const CombatantBuilder._();

  static List<Combatant> playerCombatantsFrom(
    Map<UnitType, int> selectedUnits, {
    UnitBoost boost = UnitBoost.none,
  }) {
    final List<Combatant> combatants = <Combatant>[];
    for (final MapEntry<UnitType, int> entry in selectedUnits.entries) {
      final int count = entry.value;
      if (count <= 0) {
        continue;
      }
      final UnitStats stats = UnitStats.forType(entry.key);
      final int atk = boost.atk(stats.atk);
      final int def = boost.def(stats.def);
      final int hp = boost.hp(stats.hp);
      for (int i = 0; i < count; i++) {
        combatants.add(
          Combatant(
            side: CombatSide.player,
            typeKey: entry.key.name,
            maxHp: hp,
            atk: atk,
            def: def,
          ),
        );
      }
    }
    return combatants;
  }

  /// One combatant per monster of [lair], family by family; colossi
  /// fight as bosses.
  static List<Combatant> monsterCombatantsFrom(MonsterLair lair) {
    final int level = lair.level;
    final List<Combatant> combatants = <Combatant>[];
    lair.groups.forEach((MonsterFamily? family, int count) {
      final MonsterUnitStats stats = MonsterUnitStats.of(family, level);
      final String typeKey = MonsterFamily.typeKeyOf(family, level);
      for (int i = 0; i < count; i++) {
        combatants.add(Combatant(
          side: CombatSide.monster,
          typeKey: typeKey,
          maxHp: stats.hp,
          atk: stats.atk,
          def: stats.def,
          isBoss: family == MonsterFamily.colossus,
        ));
      }
    });
    return combatants;
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
