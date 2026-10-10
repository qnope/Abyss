import '../../action/fight_monster_action.dart';
import '../../building/coral_citadel_rampart.dart';
import '../../fight/combatant.dart';
import '../../fight/combatant_builder.dart';
import '../../map/cell_content_type.dart';
import '../../map/grid_position.dart';
import '../../map/map_cell.dart';
import '../../map/monster_lair.dart';
import '../../raid/raid_battle.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';
import '../../fight/army_planner.dart';
import 'expedition_moves.dart';
import 'explore_moves.dart';
import 'recruit_moves.dart';

/// Fights on the base level: holding raids and clearing monster lairs.
extension BattleMoves on ScriptTurn {
  /// Units that hold the base: one Gardien for two Harponneurs once the
  /// barracks trains Gardiens, Harponneurs before.
  static const List<Map<UnitType, int>> defenceMixes = <Map<UnitType, int>>[
    <UnitType, int>{UnitType.guardian: 1, UnitType.harpoonist: 2},
    <UnitType, int>{UnitType.guardian: 1, UnitType.harpoonist: 1},
    <UnitType, int>{UnitType.harpoonist: 1},
  ];

  /// Recruits what the base needs to beat the announced raid, with
  /// [share] of the stocks at most. Returns whether it should hold.
  bool defendBase(ArmyPlanner planner, {double share = 1}) {
    final MonsterLair? wave = player.raidState.incoming;
    if (wave == null) return true;
    return topUp(
      base: RaidBattle.defendersOf(player),
      enemy: () => CombatantBuilder.monsterCombatantsFrom(wave),
      allies: _rampart,
      mixes: defenceMixes,
      planner: planner,
      boost: defenceBoost,
      share: share,
    );
  }

  /// Whether the units on the base level and the rampart beat [wave],
  /// with [planner]'s confidence, as they stand now.
  bool holds(MonsterLair wave, ArmyPlanner planner) => planner.wins(
        RaidBattle.defendersOf(player),
        () => CombatantBuilder.monsterCombatantsFrom(wave),
        allies: _rampart,
        boost: defenceBoost,
      );

  /// The Coral Citadel rampart that backs the base, if built.
  List<Combatant> Function()? get _rampart {
    final int level = CoralCitadelRampart.levelOf(player.buildings);
    final Combatant? rampart = CoralCitadelRampart.combatantFor(level);
    return rampart == null
        ? null
        : () => <Combatant>[CoralCitadelRampart.combatantFor(level)!];
  }

  /// Clears the revealed lairs of the base level that a share of the
  /// home army beats with [planner]'s confidence.
  void huntLairs(ArmyPlanner planner) {
    final List<GridPosition> lairs = revealedWhere(
        1,
        (MapCell c) =>
            c.content == CellContentType.monsterLair &&
            !c.isCollected &&
            c.lair != null);
    for (final GridPosition p in lairs) {
      final MonsterLair lair = game.levels[1]!.cellAt(p.x, p.y).lair!;
      final Map<UnitType, int> home = fightersOn(1)
        ..remove(UnitType.abyssAdmiral);
      if (home.isEmpty) return;
      Map<UnitType, int> share(int k) => <UnitType, int>{
            for (final e in home.entries) e.key: (e.value * k / 20).ceil(),
          };
      final int? k = planner.smallestWinning(
          20, share, () => CombatantBuilder.monsterCombatantsFrom(lair),
          boost: attackBoost);
      if (k == null) continue;
      tryPerform(FightMonsterAction(
        targetX: p.x,
        targetY: p.y,
        level: 1,
        selectedUnits: share(k),
        random: random,
      ));
    }
  }
}
