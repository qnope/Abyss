import 'dart:math';

import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../fight/guardian_factory.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../tech/tech_effects.dart';
import '../map/cell_content_type.dart';
import '../map/map_cell.dart';
import '../unit/unit_type.dart';
import '../history/history_entry.dart';
import 'action.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'attack_transition_base_helpers.dart';
import 'attack_volcanic_kernel_helpers.dart';
import 'attack_volcanic_kernel_result.dart';
import 'fight_casualty_breakdown.dart';
import 'fight_monster_helpers.dart';
import '../raid/noise_rules.dart';

class AttackVolcanicKernelAction extends Action {
  final int targetX;
  final int targetY;
  final int level;
  final Map<UnitType, int> selectedUnits;
  final Random? random;

  AttackVolcanicKernelAction({
    required this.targetX,
    required this.targetY,
    required this.level,
    required this.selectedUnits,
    this.random,
  });

  @override
  ActionType get type => ActionType.attackVolcanicKernel;

  @override
  String get description => 'Assaut Noyau Volcanique';

  @override
  ActionResult validate(Game game, Player player) {
    final map = game.levels[level];
    if (map == null) {
      return const AttackVolcanicKernelResult.failure(
        ActionFailure.mapNotGenerated,
      );
    }
    final MapCell cell = map.cellAt(targetX, targetY);
    if (cell.content != CellContentType.volcanicKernel) {
      return const AttackVolcanicKernelResult.failure(
        ActionFailure.noVolcanicKernelHere,
      );
    }
    if (cell.isCollected) {
      return const AttackVolcanicKernelResult.failure(
        ActionFailure.kernelAlreadyCaptured,
      );
    }
    final unitErr = AttackVolcanicKernelHelpers.validateUnits(
      player, level, selectedUnits,
    );
    if (unitErr != null) return unitErr;
    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final ActionResult validation = validate(game, player);
    if (!validation.isSuccess) return validation;

    final List<Combatant> playerCombatants =
        CombatantBuilder.playerCombatantsFrom(
      selectedUnits,
      boost: FightMonsterHelpers.unitBoostOf(player, attacking: true),
    );
    final List<Combatant> guardians = GuardianFactory.forVolcanicKernel();

    AttackTransitionBaseHelpers.removeUnitsFromStock(
      player, level, selectedUnits,
    );

    final FightResult fightResult = FightEngine(random: random).resolve(
      playerSide: playerCombatants,
      monsterSide: guardians,
    );

    final FightCasualtyBreakdown breakdown =
        AttackTransitionBaseHelpers.resolveCasualties(
      player: player, level: level, fightResult: fightResult, random: random,
    );

    final Map<UnitType, int> sent = Map<UnitType, int>.from(selectedUnits)
      ..removeWhere((_, int v) => v <= 0);

    final bool victory = fightResult.isVictory;
    final bool admiralAlive = AttackTransitionBaseHelpers.isAdmiralAlive(
      fightResult.finalPlayerCombatants,
    );
    final bool captured = victory && admiralAlive;

    if (captured) {
      final map = game.levels[level]!;
      final cell = map.cellAt(targetX, targetY);
      map.setCell(targetX, targetY, cell.copyWith(collectedBy: player.id));
    }

    return AttackVolcanicKernelResult.success(
      victory: victory, captured: captured, fight: fightResult,
      sent: sent, survivorsIntact: breakdown.survivorsIntact,
      wounded: breakdown.wounded, dead: breakdown.dead,
    );
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game, Player player, ActionResult result, int turn,
  ) {
    if (result is! AttackVolcanicKernelResult) return null;
    if (!result.captured || result.fight == null) return null;
    return CaptureEntry(
      turn: turn,
      transitionBaseName: CaptureEntry.volcanicKernel,
      fightResult: result.fight!,
    );
  }

  @override
  int noiseMade(Player player) =>
      TechEffects.of(player).muffle(NoiseRules.perFight);
}
