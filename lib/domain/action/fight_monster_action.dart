import 'dart:math';

import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../fight/loot_calculator.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/cell_content_type.dart';
import '../map/map_cell.dart';
import '../map/monster_lair.dart';
import '../resource/resource_type.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'fight_casualty_breakdown.dart';
import 'fight_monster_helpers.dart';
import 'fight_monster_result.dart';

class FightMonsterAction extends Action {
  final int targetX;
  final int targetY;
  final Map<UnitType, int> selectedUnits;
  final Random? random;
  MonsterLair? _capturedLair;

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
    if (game.levels[1] == null) {
      return const FightMonsterResult.failure('Carte non générée');
    }
    final MapCell cell = game.levels[1]!.cellAt(targetX, targetY);
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
      final int stock = player.unitsOnLevel(1)[entry.key]?.count ?? 0;
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

    final MapCell cell = game.levels[1]!.cellAt(targetX, targetY);
    final MonsterLair lair = cell.lair!;
    _capturedLair = lair;
    final int militaryLevel =
        FightMonsterHelpers.militaryResearchLevelOf(player);
    final List<Combatant> playerCombatants = CombatantBuilder
        .playerCombatantsFrom(selectedUnits, militaryResearchLevel: militaryLevel);
    final List<Combatant> monsterCombatants =
        CombatantBuilder.monsterCombatantsFrom(lair);

    for (final MapEntry<UnitType, int> entry in selectedUnits.entries) {
      player.unitsOnLevel(1)[entry.key]!.count -= entry.value;
    }

    final FightEngine engine = FightEngine(random: random);
    final FightResult fightResult = engine.resolve(
      playerSide: playerCombatants,
      monsterSide: monsterCombatants,
    );

    final FightCasualtyBreakdown breakdown =
        FightMonsterHelpers.resolveCasualties(
      player: player,
      fightResult: fightResult,
      random: random,
    );

    final Map<UnitType, int> sent = Map<UnitType, int>.from(selectedUnits)
      ..removeWhere((_, int v) => v <= 0);

    Map<ResourceType, int> loot = const <ResourceType, int>{};
    if (fightResult.isVictory) {
      final Map<ResourceType, int> rolled =
          LootCalculator(random: random).compute(lair.difficulty);
      loot = FightMonsterHelpers.applyLoot(player, rolled);
      game.levels[1]!.setCell(
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
      survivorsIntact: breakdown.survivorsIntact,
      wounded: breakdown.wounded,
      dead: breakdown.dead,
    );
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) {
    if (result is! FightMonsterResult || !result.isSuccess) return null;
    return FightMonsterHelpers.buildCombatEntry(
      turn: turn,
      targetX: targetX,
      targetY: targetY,
      lair: _capturedLair,
      result: result,
    );
  }
}
