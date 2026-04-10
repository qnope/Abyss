import 'dart:math';

import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../fight/guardian_factory.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/map_cell.dart';
import '../map/transition_base.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'attack_transition_base_helpers.dart';
import 'attack_transition_base_result.dart';
import 'fight_casualty_breakdown.dart';
import 'fight_monster_helpers.dart';

class AttackTransitionBaseAction extends Action {
  final int targetX;
  final int targetY;
  final int level;
  final Map<UnitType, int> selectedUnits;
  final Random? random;

  AttackTransitionBaseAction({
    required this.targetX,
    required this.targetY,
    required this.level,
    required this.selectedUnits,
    this.random,
  });

  @override
  ActionType get type => ActionType.attackTransitionBase;

  @override
  String get description => 'Assaut base ($targetX, $targetY)';

  @override
  ActionResult validate(Game game, Player player) {
    final map = game.levels[level];
    if (map == null) {
      return const AttackTransitionBaseResult.failure('Carte non générée');
    }
    final MapCell cell = map.cellAt(targetX, targetY);
    if (cell.content != CellContentType.transitionBase) {
      return const AttackTransitionBaseResult.failure(
        'Pas de base de transition ici',
      );
    }
    final TransitionBase? base = cell.transitionBase;
    if (base == null) {
      return const AttackTransitionBaseResult.failure('Base introuvable');
    }
    if (base.isCaptured) {
      return const AttackTransitionBaseResult.failure('Base déjà capturée');
    }
    final buildingErr =
        AttackTransitionBaseHelpers.validateBuilding(player, base.type);
    if (buildingErr != null) return buildingErr;
    final unitErr = AttackTransitionBaseHelpers.validateUnits(
      player, level, selectedUnits,
    );
    if (unitErr != null) return unitErr;
    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final ActionResult validation = validate(game, player);
    if (!validation.isSuccess) return validation;

    final MapCell cell = game.levels[level]!.cellAt(targetX, targetY);
    final TransitionBase base = cell.transitionBase!;

    final int milLevel = FightMonsterHelpers.militaryResearchLevelOf(player);
    final List<Combatant> playerCombatants =
        CombatantBuilder.playerCombatantsFrom(
      selectedUnits, militaryResearchLevel: milLevel,
    );
    final List<Combatant> guardians = GuardianFactory.forType(base.type);

    AttackTransitionBaseHelpers.removeUnitsFromStock(
      player, level, selectedUnits,
    );

    final FightResult fightResult = FightEngine(random: random).resolve(
      playerSide: playerCombatants,
      monsterSide: guardians,
    );

    final FightCasualtyBreakdown breakdown =
        AttackTransitionBaseHelpers.resolveCasualties(
      player: player,
      level: level,
      fightResult: fightResult,
      random: random,
    );

    final Map<UnitType, int> sent = Map<UnitType, int>.from(selectedUnits)
      ..removeWhere((_, int v) => v <= 0);

    final bool victory = fightResult.isVictory;
    final bool admiralAlive =
        AttackTransitionBaseHelpers.isAdmiralAlive(
      fightResult.finalPlayerCombatants,
    );
    final bool captured = victory && admiralAlive;

    if (captured) {
      base.capturedBy = player.id;
    }

    return AttackTransitionBaseResult.success(
      victory: victory,
      captured: captured,
      fight: fightResult,
      sent: sent,
      survivorsIntact: breakdown.survivorsIntact,
      wounded: breakdown.wounded,
      dead: breakdown.dead,
    );
  }
}
