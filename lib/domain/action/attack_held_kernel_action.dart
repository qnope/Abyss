import 'dart:math';

import '../fight/combatant_builder.dart';
import '../fight/fight_engine.dart';
import '../fight/fight_result.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../raid/noise_rules.dart';
import '../tech/tech_effects.dart';
import '../unit/unit_type.dart';
import '../volcano/kernel_garrison.dart';
import 'action.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'attack_base_defence.dart';
import 'attack_base_entries.dart';
import 'attack_base_result.dart';
import 'attack_held_kernel_validator.dart';
import 'attack_transition_base_helpers.dart';
import 'base_damage.dart';
import 'fight_casualty_breakdown.dart';
import 'fight_monster_helpers.dart';
import 'kernel_assault_settlement.dart';

/// Sends [selectedUnits] of the volcano level against the volcanic kernel
/// that another player holds, defended by its garrison and the magma
/// rampart; without either it falls at once.
///
/// A won attack takes one level off the kernel. When the kernel reaches
/// level 0 the attacker holds it (and the garrison is lost with it), but
/// can put no garrison there before it has built the kernel up to level
/// 1. There is no pillage. Both players keep a [BaseAssaultEntry] whose
/// rampart levels are the kernel's.
class AttackHeldKernelAction extends Action {
  /// Code of the post in the history entries of this attack.
  static const String kernelCode = 'volcanicKernel';

  final int targetX;
  final int targetY;
  final Map<UnitType, int> selectedUnits;
  final Random? random;

  String _ownerName = '';

  AttackHeldKernelAction({
    required this.targetX,
    required this.targetY,
    required this.selectedUnits,
    this.random,
  });

  @override
  ActionType get type => ActionType.attackHeldKernel;

  @override
  String get description => 'Assaut Noyau tenu ($targetX, $targetY)';

  @override
  ActionResult validate(Game game, Player player) {
    final ActionFailure? failure = AttackHeldKernelValidator.check(
      game,
      player,
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
    final map = game.levels[KernelGarrison.volcanoLevel]!;
    final Player owner =
        game.players[map.cellAt(targetX, targetY).collectedBy]!;
    _ownerName = owner.name;

    final BaseDefence defence = BaseDefence.kernel(owner);
    AttackTransitionBaseHelpers.removeUnitsFromStock(
      player,
      KernelGarrison.volcanoLevel,
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
          level: KernelGarrison.volcanoLevel,
          fightResult: fight,
          random: random,
        );
    final DefenceOutcome outcome = defence.settle(owner, random: random);
    final int before = KernelGarrison.kernelLevelOf(owner);
    final int after = fight.isVictory ? max(0, before - 1) : before;
    final AttackBaseResult result = AttackBaseResult.success(
      victory: fight.isVictory,
      fight: fight,
      sent: Map<UnitType, int>.from(selectedUnits)
        ..removeWhere((_, int n) => n <= 0),
      survivorsIntact: breakdown.survivorsIntact,
      wounded: breakdown.wounded,
      dead: breakdown.dead,
      defence: outcome,
      damage: BaseDamage.kernel(before: before, after: after),
    );
    KernelAssaultSettlement.settle(
      game: game,
      x: targetX,
      y: targetY,
      attacker: player,
      owner: owner,
      result: result,
      postName: kernelCode,
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
      postName: kernelCode,
    );
  }

  @override
  int noiseMade(Player player) =>
      TechEffects.of(player).muffle(NoiseRules.perFight);
}
