import 'dart:math';

import '../fight/combatant_builder.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../raid/noise_rules.dart';
import '../raid/raid_battle.dart';
import '../tech/tech_effects.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'attack_base_defence.dart';
import 'attack_base_entries.dart';
import 'attack_base_result.dart';
import 'attack_base_validator.dart';
import 'attack_transition_base_helpers.dart';
import 'base_damage.dart';
import 'fight_casualty_breakdown.dart';
import 'fight_monster_helpers.dart';

/// Sends [selectedUnits] of the base level against the base of another
/// player, who defends with the units standing on its own base level and
/// its rampart. The fight is settled at once, like every attack.
///
/// A won attack breaks the rampart (or, with none, the headquarters) and
/// pillages the stocks; a lost one only costs the army its casualties.
/// Both players keep a [BaseAssaultEntry], and the attack never counts
/// among the raids the target loses.
class AttackBaseAction extends Action {
  static const int level = RaidBattle.baseLevel;

  /// Names the human player as a target, for a script or a replay that
  /// cannot know the id of the player's game.
  static const String human = 'human';

  final String targetPlayerId;
  final Map<UnitType, int> selectedUnits;
  final Random? random;

  AttackBaseAction({
    required this.targetPlayerId,
    required this.selectedUnits,
    this.random,
  });

  String _targetId(Game game) =>
      targetPlayerId == human ? game.humanPlayerId : targetPlayerId;

  @override
  ActionType get type => ActionType.attackBase;

  @override
  String get description => 'Attaque base $targetPlayerId';

  @override
  ActionResult validate(Game game, Player player) {
    final ActionFailure? failure = AttackBaseValidator.check(
      game,
      player,
      _targetId(game),
      selectedUnits,
    );
    return failure == null
        ? const ActionResult.success()
        : AttackBaseResult.failure(failure);
  }

  @override
  ActionResult execute(Game game, Player player) {
    final ActionResult validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final Player target = game.players[_targetId(game)]!;

    final BaseDefence defence = BaseDefence.of(target);
    AttackTransitionBaseHelpers.removeUnitsFromStock(
      player,
      level,
      selectedUnits,
    );
    final FightResult fight = FightEngine(random: random).resolve(
      playerSide: CombatantBuilder.playerCombatantsFrom(
        selectedUnits,
        boost: FightMonsterHelpers.unitBoostOf(player, attacking: true),
      ),
      monsterSide: defence.side,
    );
    final FightCasualtyBreakdown breakdown =
        FightMonsterHelpers.resolveCasualties(
          player: player,
          level: level,
          fightResult: fight,
          random: random,
        );
    final DefenceOutcome outcome = defence.settle(target, random: random);
    final BaseDamage damage =
        fight.isVictory
            ? BaseRaze.apply(attacker: player, target: target)
            : BaseDamage.none(target);

    final AttackBaseResult result = AttackBaseResult.success(
      victory: fight.isVictory,
      fight: fight,
      sent: Map<UnitType, int>.from(selectedUnits)
        ..removeWhere((_, int n) => n <= 0),
      survivorsIntact: breakdown.survivorsIntact,
      wounded: breakdown.wounded,
      dead: breakdown.dead,
      defence: outcome,
      damage: damage,
    );
    target.addHistoryEntry(
      AttackBaseEntries.forDefender(game.turn, player.name, result),
    );
    return result;
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) {
    if (result is! AttackBaseResult || !result.isSuccess) return null;
    return AttackBaseEntries.forAttacker(
      turn,
      game.players[_targetId(game)]!.name,
      result,
    );
  }

  @override
  int noiseMade(Player player) =>
      TechEffects.of(player).muffle(NoiseRules.perFight);
}
