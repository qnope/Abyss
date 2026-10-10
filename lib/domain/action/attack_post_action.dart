import 'dart:math';

import '../fight/combatant_builder.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/transition_base.dart';
import '../raid/noise_rules.dart';
import '../tech/tech_effects.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'attack_base_defence.dart';
import 'attack_base_entries.dart';
import 'attack_base_result.dart';
import 'attack_post_validator.dart';
import 'attack_transition_base_helpers.dart';
import 'base_damage.dart';
import 'fight_casualty_breakdown.dart';
import 'fight_monster_helpers.dart';
import 'post_takeover.dart';

/// Sends [selectedUnits] of [level] against the Faille or the Cheminée at
/// ([targetX], [targetY]) that another player holds, defended by the units
/// its owner has on the level it opens onto (kernel garrison apart), with
/// no rampart; without any, it falls at once.
///
/// A won attack destroys the owner's passage building and gives the post
/// to the attacker ([PostTakeover]), with no pillage; a lost one only
/// costs the army its casualties. Both players keep a [BaseAssaultEntry].
class AttackPostAction extends Action {
  final int targetX;
  final int targetY;
  final int level;
  final Map<UnitType, int> selectedUnits;
  final Random? random;

  String _ownerName = ''; // Who held the post, for the attacker's history.

  AttackPostAction({
    required this.targetX,
    required this.targetY,
    required this.level,
    required this.selectedUnits,
    this.random,
  });

  @override
  ActionType get type => ActionType.attackPost;

  @override
  String get description => 'Attaque poste ($targetX, $targetY)';

  TransitionBase _post(Game game) =>
      game.levels[level]!.cellAt(targetX, targetY).transitionBase!;

  @override
  ActionResult validate(Game game, Player player) {
    final ActionFailure? failure = AttackPostValidator.check(
      game,
      player,
      level,
      targetX,
      targetY,
      selectedUnits,
    );
    if (failure == null) return const ActionResult.success();
    return AttackBaseResult.failure(failure);
  }

  @override
  ActionResult execute(Game game, Player player) {
    final ActionResult validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final TransitionBase post = _post(game);
    final Player owner = game.players[post.capturedBy]!;
    _ownerName = owner.name;

    final BaseDefence defence = BaseDefence.post(owner, post.targetLevel);
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
    final DefenceOutcome outcome = defence.settle(owner, random: random);
    if (fight.isVictory) {
      PostTakeover.apply(post: post, attacker: player, owner: owner);
    }

    final AttackBaseResult result = AttackBaseResult.success(
      victory: fight.isVictory,
      fight: fight,
      sent: Map<UnitType, int>.from(selectedUnits)
        ..removeWhere((_, int n) => n <= 0),
      survivorsIntact: breakdown.survivorsIntact,
      wounded: breakdown.wounded,
      dead: breakdown.dead,
      defence: outcome,
      damage: BaseDamage.none(owner),
    );
    owner.addHistoryEntry(
      AttackBaseEntries.forDefender(
        game.turn,
        player.name,
        result,
        postName: post.name,
      ),
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
      _ownerName,
      result,
      postName: _post(game).name,
    );
  }

  @override
  int noiseMade(Player player) =>
      TechEffects.of(player).muffle(NoiseRules.perFight);
}
