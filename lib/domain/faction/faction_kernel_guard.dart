import '../building/coral_citadel_rampart.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../game/player.dart';
import '../map/monster_lair.dart';
import '../script/script_turn.dart';
import '../script/strategies/expedition_moves.dart';
import '../unit/unit_type.dart';
import '../volcano/kernel_garrison.dart';
import '../volcano/magma_rampart.dart';
import '../volcano/volcano_wave_factory.dart';
import 'faction_war.dart';

/// What a faction does for the kernel it holds: when its garrison would
/// lose to the next kraken wave, half of the fighters idling on its base go
/// down to reinforce it. The conquest strategy only sends the units it has
/// just recruited, which leaves a big home army useless while the kernel
/// falls.
abstract final class FactionKernelGuard {
  /// Share of the home fighters sent down to the kernel in one turn.
  static const double share = 0.5;

  static void play(ScriptTurn turn, [double share = FactionKernelGuard.share]) {
    final Player me = turn.player;
    if (!turn.game.isVolcanicKernelCapturedBy(me.id)) return;
    final int level = KernelGarrison.kernelLevelOf(me);
    if (level < 1 || level >= 10) return;
    final MonsterLair wave = VolcanoWaveFactory.fromKernelLevel(
      level,
      monsterPercent: turn.game.difficulty.monsterPercentFor(faction: true),
    );
    final Map<UnitType, int> guard = _guardOf(me);
    if (FactionWar.planner.wins(
      guard,
      () => CombatantBuilder.monsterCombatantsFrom(wave),
      allies: () => <Combatant>[MagmaRampart.combatantFor(level)!],
      boost: turn.defenceBoost,
    )) {
      return;
    }
    final Map<UnitType, int> sent = _spare(turn, share);
    if (!turn.descend(1, sent)) return;
    turn.descend(2, sent);
  }

  /// Half of the home fighters, less what the base needs to hold the raid
  /// announced for this turn.
  static Map<UnitType, int> _spare(ScriptTurn turn, double share) {
    final Map<UnitType, int> home = turn.fightersOn(1)
      ..remove(UnitType.abyssAdmiral);
    final MonsterLair? raid = turn.player.raidState.incoming;
    for (final double part in <double>[share, share / 2, 0.1]) {
      final Map<UnitType, int> sent = <UnitType, int>{
        for (final MapEntry<UnitType, int> e in home.entries)
          e.key: (e.value * part).floor(),
      };
      if (raid == null) return sent;
      final Map<UnitType, int> kept = <UnitType, int>{
        for (final MapEntry<UnitType, int> e in home.entries)
          e.key: e.value - sent[e.key]!,
      };
      if (FactionWar.planner.wins(
        kept,
        () => CombatantBuilder.monsterCombatantsFrom(raid),
        allies: _rampart(turn.player),
        boost: turn.defenceBoost,
      )) {
        return sent;
      }
    }
    return const <UnitType, int>{};
  }

  static List<Combatant> Function()? _rampart(Player me) {
    final Combatant? c = CoralCitadelRampart.combatantOf(me.buildings);
    return c == null
        ? null
        : () => <Combatant>[CoralCitadelRampart.combatantOf(me.buildings)!];
  }

  /// The garrison and the fighters waiting on the volcano level.
  static Map<UnitType, int> _guardOf(Player me) {
    final Map<UnitType, int> guard = KernelGarrison.of(me);
    me.unitsOnLevel(KernelGarrison.volcanoLevel).forEach((t, u) {
      if (u.count > 0 && t != UnitType.scout && t != UnitType.abyssAdmiral) {
        guard[t] = (guard[t] ?? 0) + u.count;
      }
    });
    return guard;
  }
}
