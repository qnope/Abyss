import 'dart:math';

import '../fight/casualty_calculator.dart';
import '../fight/casualty_split.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../fight/loot_calculator.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/map_cell.dart';
import '../map/monster_lair.dart';
import '../resource/resource_type.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'fight_monster_helpers.dart';
import 'fight_monster_result.dart';

class FightMonsterAction extends Action {
  final int targetX;
  final int targetY;
  final Map<UnitType, int> selectedUnits;
  final Random? random;

  FightMonsterAction({
    required this.targetX,
    required this.targetY,
    required this.selectedUnits,
    this.random,
  });

  @override
  ActionType get type => ActionType.fightMonster;

  @override
  String get description => 'Combat ($targetX, $targetY)';

  @override
  ActionResult validate(Game game, Player player) {
    if (game.gameMap == null) {
      return const FightMonsterResult.failure('Carte non générée');
    }
    final MapCell cell = game.gameMap!.cellAt(targetX, targetY);
    if (cell.content != CellContentType.monsterLair) {
      return const FightMonsterResult.failure('Pas de monstre ici');
    }
    if (cell.isCollected) {
      return const FightMonsterResult.failure('Tanière déjà vaincue');
    }
    if (cell.lair == null) {
      return const FightMonsterResult.failure('Tanière vide');
    }
    int total = 0;
    for (final MapEntry<UnitType, int> entry in selectedUnits.entries) {
      if (entry.value <= 0) {
        continue;
      }
      final int stock = player.units[entry.key]?.count ?? 0;
      if (entry.value > stock) {
        return const FightMonsterResult.failure('Unités insuffisantes');
      }
      total += entry.value;
    }
    if (total <= 0) {
      return const FightMonsterResult.failure('Aucune unité sélectionnée');
    }
    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final ActionResult validation = validate(game, player);
    if (!validation.isSuccess) return validation;

    final MapCell cell = game.gameMap!.cellAt(targetX, targetY);
    final MonsterLair lair = cell.lair!;

    final int militaryLevel =
        FightMonsterHelpers.militaryResearchLevelOf(player);
    final List<Combatant> playerCombatants = CombatantBuilder
        .playerCombatantsFrom(selectedUnits, militaryResearchLevel: militaryLevel);
    final List<Combatant> monsterCombatants =
        CombatantBuilder.monsterCombatantsFrom(lair);

    for (final MapEntry<UnitType, int> entry in selectedUnits.entries) {
      player.units[entry.key]!.count -= entry.value;
    }

    final FightEngine engine = FightEngine(random: random);
    final FightResult fightResult = engine.resolve(
      playerSide: playerCombatants,
      monsterSide: monsterCombatants,
    );

    final double pctLost = FightMonsterHelpers.computePctLost(
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

    FightMonsterHelpers.restoreToStock(player, alive);
    FightMonsterHelpers.restoreToStock(player, split.wounded);

    final Map<UnitType, int> sent = Map<UnitType, int>.from(selectedUnits)
      ..removeWhere((_, int v) => v <= 0);
    final Map<UnitType, int> survivorsIntact =
        FightMonsterHelpers.combatantsByType(alive);
    final Map<UnitType, int> wounded =
        FightMonsterHelpers.combatantsByType(split.wounded);
    final Map<UnitType, int> dead =
        FightMonsterHelpers.combatantsByType(split.dead);

    Map<ResourceType, int> loot = const <ResourceType, int>{};
    if (fightResult.isVictory) {
      final Map<ResourceType, int> rolled =
          LootCalculator(random: random).compute(lair.difficulty);
      loot = FightMonsterHelpers.applyLoot(player, rolled);
      game.gameMap!.setCell(
        targetX,
        targetY,
        cell.copyWith(collectedBy: player.id),
      );
    }

    return FightMonsterResult.success(
      victory: fightResult.isVictory,
      fight: fightResult,
      loot: loot,
      sent: sent,
      survivorsIntact: survivorsIntact,
      wounded: wounded,
      dead: dead,
    );
  }
}
