import 'dart:math';

import '../action/fight_casualty_breakdown.dart';
import '../action/fight_monster_helpers.dart';
import '../building/coral_citadel_rampart.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../game/player.dart';
import '../map/monster_lair.dart';
import '../resource/resource_type.dart';
import '../tech/tech_effects.dart';
import '../unit/unit_type.dart';
import 'raid_report.dart';
import 'raid_spoils.dart';

/// Fights a raid wave with every unit standing on the base level, backed
/// by the Coral Citadel rampart.
abstract final class RaidBattle {
  static const int baseLevel = 1;

  static RaidReport fight({
    required Player player,
    required MonsterLair wave,
    required int turn,
    Random? random,
  }) {
    final Map<UnitType, int> defenders = defendersOf(player);
    final int rampartLevel = CoralCitadelRampart.levelOf(player.buildings);
    final Combatant? rampart = CoralCitadelRampart.combatantFor(rampartLevel);
    final List<Combatant> playerSide = <Combatant>[
      ...CombatantBuilder.playerCombatantsFrom(
        defenders,
        boost: FightMonsterHelpers.unitBoostOf(player, defendingBase: true),
      ),
      if (rampart != null) rampart,
    ];
    for (final UnitType type in defenders.keys) {
      player.unitsOnLevel(baseLevel)[type]!.count = 0;
    }
    final FightResult result = FightEngine(random: random).resolve(
      playerSide: playerSide,
      monsterSide: CombatantBuilder.monsterCombatantsFrom(wave),
    );
    final FightCasualtyBreakdown breakdown =
        FightMonsterHelpers.resolveCasualties(
      player: player,
      level: baseLevel,
      fightResult: result,
      random: random,
    );
    final bool victory = result.isVictory;
    final TechEffects tech = TechEffects(player.techBranches);
    return RaidReport(
      turn: turn,
      victory: victory,
      wave: wave,
      fight: result,
      rampartLevel: rampartLevel,
      defenders: defenders,
      survivorsIntact: breakdown.survivorsIntact,
      wounded: breakdown.wounded,
      dead: breakdown.dead,
      loot: victory
          ? FightMonsterHelpers.applyLoot(player, tech.boostLoot(
              RaidSpoils.loot(wave.difficulty, random: random)))
          : const <ResourceType, int>{},
      pillaged: victory
          ? const <ResourceType, int>{}
          : RaidSpoils.pillage(player.resources, rate: tech.pillageRate),
    );
  }

  /// Units currently standing on the base level, by type.
  static Map<UnitType, int> defendersOf(Player player) {
    final Map<UnitType, int> defenders = <UnitType, int>{};
    player.unitsOnLevel(baseLevel).forEach((UnitType type, unit) {
      if (unit.count > 0) defenders[type] = unit.count;
    });
    return defenders;
  }
}
