import '../../action/garrison_kernel_action.dart';
import '../../fight/combatant.dart';
import '../../fight/combatant_builder.dart';
import '../../map/monster_lair.dart';
import '../../unit/unit_type.dart';
import '../../volcano/kernel_garrison.dart';
import '../../volcano/magma_rampart.dart';
import '../../volcano/volcano_wave_factory.dart';
import '../script_turn.dart';
import 'army_planner.dart';
import 'expedition_moves.dart';
import 'recruit_moves.dart';

/// Guarding the captured kernel against the kraken waves.
extension KernelGuardMoves on ScriptTurn {
  /// Units that hold the kernel: Briseurs against the kraken bosses,
  /// Gardiens to soak their tentacles.
  static const List<Map<UnitType, int>> guardMixes = <Map<UnitType, int>>[
    <UnitType, int>{UnitType.domeBreaker: 2, UnitType.guardian: 1},
    <UnitType, int>{UnitType.domeBreaker: 1},
    <UnitType, int>{UnitType.harpoonist: 1},
  ];

  /// Shuts every fighter of the volcano level in the garrison, then
  /// recruits and brings down what it needs to beat the wave of the
  /// kernel's current level, with [share] of the stocks at most.
  void guardKernel(ArmyPlanner planner, {double share = 1}) {
    if (!game.isVolcanicKernelCapturedBy(player.id)) return;
    final int level = KernelGarrison.kernelLevelOf(player);
    if (level < 1) return;
    _garrisonVolcanoFighters();
    final MonsterLair wave = VolcanoWaveFactory.fromKernelLevel(
      level,
      monsterPercent: game.difficulty.monsterPercent,
    );
    final Map<UnitType, int> before = _homeCounts();
    topUp(
      base: KernelGarrison.of(player),
      enemy: () => CombatantBuilder.monsterCombatantsFrom(wave),
      allies: () => <Combatant>[MagmaRampart.combatantFor(level)!],
      mixes: guardMixes,
      planner: planner,
      boost: defenceBoost,
      share: share,
    );
    final Map<UnitType, int> recruits = <UnitType, int>{
      for (final e in _homeCounts().entries)
        if (e.value > (before[e.key] ?? 0)) e.key: e.value - before[e.key]!,
    };
    if (recruits.isEmpty || !descend(1, recruits)) return;
    descend(2, recruits);
    _garrisonVolcanoFighters();
  }

  void _garrisonVolcanoFighters() {
    final Map<UnitType, int> fighters = fightersOn(KernelGarrison.volcanoLevel)
      ..remove(UnitType.abyssAdmiral);
    if (fighters.isEmpty) return;
    tryPerform(GarrisonKernelAction(selectedUnits: fighters));
  }

  Map<UnitType, int> _homeCounts() => <UnitType, int>{
    for (final e in player.unitsOnLevel(1).entries) e.key: e.value.count,
  };
}
