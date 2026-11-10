import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/combatant_builder.dart';
import 'package:abyss/domain/fight/unit_boost.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// The sides of a fight, built as the game builds them.
abstract final class FightSides {
  /// The combatants of [army], in the order of its entries.
  static List<Combatant> units(
    Map<UnitType, int> army, {
    UnitBoost boost = UnitBoost.none,
    CombatSide side = CombatSide.player,
  }) => CombatantBuilder.playerCombatantsFrom(army, boost: boost, side: side);

  /// The monsters of a lair, or of a raid when it has a second family.
  static List<Combatant> lair(
    MonsterDifficulty difficulty,
    MonsterFamily? family,
    int count, [
    MonsterFamily? secondFamily,
    int secondCount = 0,
  ]) => CombatantBuilder.monsterCombatantsFrom(
    MonsterLair(
      difficulty: difficulty,
      family: family,
      unitCount: count,
      secondFamily: secondFamily,
      secondCount: secondCount,
    ),
  );

  /// The rampart of a base attacked by a player: it defends on the
  /// monsters' side (see `BaseDefence`).
  static Combatant onMonsterSide(Combatant c) => Combatant(
    side: CombatSide.monster,
    typeKey: c.typeKey,
    maxHp: c.maxHp,
    atk: c.atk,
    def: c.def,
  );
}
