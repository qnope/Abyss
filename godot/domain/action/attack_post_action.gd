class_name AttackPostAction
extends Action
## lib/domain/action/attack_post_action.dart: sends `selected_units` of
## `level` against the Faille or the Cheminée at (`target_x`, `target_y`)
## that another player holds, defended by the units its owner has on the
## level it opens onto (kernel garrison apart), with no rampart; without
## any, it falls at once.
##
## A won attack destroys the owner's passage building and gives the post to
## the attacker (PostTakeover), with no pillage; a lost one only costs the
## army its casualties. Both players keep a BaseAssaultEntry.

var target_x: int
var target_y: int
var level: int
var selected_units: Dictionary[UnitType.Value, int]
## Null where Dart passes none: each step then rolls a generator of its own.
var random: DartRandom

var _owner_name := "" # Who held the post, for the attacker's history.


func _init(
	target_x_: int, target_y_: int, level_: int,
	selected_units_: Dictionary[UnitType.Value, int], random_: DartRandom = null,
) -> void:
	target_x = target_x_
	target_y = target_y_
	level = level_
	selected_units = selected_units_
	random = random_


func type() -> ActionType.Value:
	return ActionType.Value.ATTACK_POST


func description() -> String:
	return "Attaque poste (%d, %d)" % [target_x, target_y]


func _post(game: Game) -> TransitionBase:
	var map: GameMap = game.levels[level]
	return map.cell_at(target_x, target_y).transition_base


func validate(game: Game, player: Player) -> ActionResult:
	var failure: Variant = AttackPostValidator.check(game, player, level, target_x, target_y, selected_units)
	if failure == null:
		return ActionResult.success()
	var reason: ActionFailure.Value = failure
	return AttackBaseResult.failure(reason)


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var post := _post(game)
	var owner: Player = game.players[post.captured_by]
	_owner_name = owner.name
	var defence := BaseDefence.post(owner, post.target_level())
	AttackTransitionBaseHelpers.remove_units_from_stock(player, level, selected_units)
	var fight := FightEngine.new(random).resolve(
		CombatantBuilder.player_combatants_from(selected_units, FightMonsterHelpers.unit_boost_of(player, true)),
		defence.side,
	)
	var breakdown := FightMonsterHelpers.resolve_casualties(player, level, fight, random)
	var outcome := defence.settle(owner, random)
	var sent: Dictionary[UnitType.Value, int] = {}
	for type_: UnitType.Value in selected_units:
		if selected_units[type_] > 0:
			sent[type_] = selected_units[type_]
	var result := AttackBaseResult.success(
		fight.is_victory(), fight, sent, breakdown.survivors_intact, breakdown.wounded, breakdown.dead,
		outcome, BaseDamage.none(owner),
	)
	PostAssaultSettlement.settle(game.turn, post, player, player.name, owner, result)
	return result


func make_history_entry(game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	if not result is AttackBaseResult or not result.is_success:
		return null
	var assault: AttackBaseResult = result
	return AttackBaseEntries.for_attacker(turn, _owner_name, assault, _post(game).name)


func noise_made(player: Player) -> int:
	return TechEffects.of(player).muffle(NoiseRules.PER_FIGHT)
