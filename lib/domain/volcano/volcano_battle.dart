import 'dart:math';

import '../action/fight_casualty_breakdown.dart';
import '../action/fight_monster_helpers.dart';
import '../building/building_type.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../game/player.dart';
import '../map/monster_lair.dart';
import '../unit/unit_type.dart';
import 'kernel_garrison.dart';
import 'magma_rampart.dart';
import 'volcano_report.dart';

/// Fights a kraken wave with the kernel's garrison, backed by the magma
/// rampart. A won wave takes one level off the kernel.
abstract final class VolcanoBattle {
  static VolcanoReport fight({
    required Player player,
    required MonsterLair wave,
    required int turn,
    Random? random,
  }) {
    final Map<UnitType, int> defenders = KernelGarrison.of(player);
    final int kernelLevel = KernelGarrison.kernelLevelOf(player);
    final Combatant? rampart = MagmaRampart.combatantFor(kernelLevel);
    final List<Combatant> playerSide = <Combatant>[
      ...CombatantBuilder.playerCombatantsFrom(
        defenders,
        boost: FightMonsterHelpers.unitBoostOf(player, defendingBase: true),
      ),
      if (rampart != null) rampart,
    ];
    final stock = KernelGarrison.stockOf(player);
    for (final UnitType type in defenders.keys) {
      stock[type]!.count = 0;
    }
    final FightResult result = FightEngine(random: random).resolve(
      playerSide: playerSide,
      monsterSide: CombatantBuilder.monsterCombatantsFrom(wave),
    );
    final FightCasualtyBreakdown breakdown =
        FightMonsterHelpers.resolveCasualties(
      player: player,
      level: KernelGarrison.stockKey,
      fightResult: result,
      random: random,
    );
    if (!result.isVictory && kernelLevel > 0) {
      player.buildings[BuildingType.volcanicKernel]!.level = kernelLevel - 1;
    }
    return VolcanoReport(
      turn: turn,
      victory: result.isVictory,
      wave: wave,
      fight: result,
      kernelLevel: kernelLevel,
      defenders: defenders,
      survivorsIntact: breakdown.survivorsIntact,
      wounded: breakdown.wounded,
      dead: breakdown.dead,
    );
  }
}
