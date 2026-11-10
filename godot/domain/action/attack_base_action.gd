class_name AttackBaseAction
extends Action
## lib/domain/action/attack_base_action.dart: sends `selected_units` of the
## base level against the base of another player, who defends with the
## units standing on its own base level and its rampart. The fight is
## settled at once, like every attack.
##
## A won attack breaks the rampart (or, with none, the headquarters) and
## pillages the stocks; a lost one only costs the army its casualties. Both
## players keep a BaseAssaultEntry, and the attack never counts among the
## raids the target loses.

const LEVEL := RaidBattle.BASE_LEVEL
## Names the human player as a target, for a script or a replay that cannot
## know the id of the player's game.
const HUMAN := "human"

var target_player_id: String
var selected_units: Dictionary[UnitType.Value, int]
## Null where Dart passes none: each step then rolls a generator of its own.
var random: DartRandom


func _init(
	target_player_id_: String, selected_units_: Dictionary[UnitType.Value, int], random_: DartRandom = null
) -> void:
	target_player_id = target_player_id_
	selected_units = selected_units_
	random = random_


func _target_id(game: Game) -> String:
	return game.human_player_id if target_player_id == HUMAN else target_player_id


func type() -> ActionType.Value:
	return ActionType.Value.ATTACK_BASE


func description() -> String:
	return "Attaque base %s" % target_player_id


func validate(game: Game, player: Player) -> ActionResult:
	var failure: Variant = AttackBaseValidator.check(game, player, _target_id(game), selected_units)
	if failure == null:
		return ActionResult.success()
	var reason: ActionFailure.Value = failure
	return AttackBaseResult.failure(reason)


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var target: Player = game.players[_target_id(game)]
	var defence := BaseDefence.of(target)
	AttackTransitionBaseHelpers.remove_units_from_stock(player, LEVEL, selected_units)
	var fight := FightEngine.new(random).resolve(
		CombatantBuilder.player_combatants_from(selected_units, FightMonsterHelpers.unit_boost_of(player, true)),
		defence.side,
	)
	var breakdown := FightMonsterHelpers.resolve_casualties(player, LEVEL, fight, random)
	var outcome := defence.settle(target, random)
	var damage := BaseRaze.apply(player, target) if fight.is_victory() else BaseDamage.none(target)
	var sent: Dictionary[UnitType.Value, int] = {}
	for type_: UnitType.Value in selected_units:
		if selected_units[type_] > 0:
			sent[type_] = selected_units[type_]
	var result := AttackBaseResult.success(
		fight.is_victory(), fight, sent, breakdown.survivors_intact, breakdown.wounded, breakdown.dead,
		outcome, damage,
	)
	target.add_history_entry(AttackBaseEntries.for_defender(game.turn, player.name, result))
	return result


func make_history_entry(game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	if not result is AttackBaseResult or not result.is_success:
		return null
	var target: Player = game.players[_target_id(game)]
	var assault: AttackBaseResult = result
	return AttackBaseEntries.for_attacker(turn, target.name, assault)


func noise_made(player: Player) -> int:
	return TechEffects.of(player).muffle(NoiseRules.PER_FIGHT)
