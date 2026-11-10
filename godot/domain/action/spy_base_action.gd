class_name SpyBaseAction
extends Action
## lib/domain/action/spy_base_action.dart: sends a Scout to the base of
## another player, who has to be one the spy has seen. The Scout does not
## come back, and brings a BaseIntel of the base as it stands now:
## headquarters, rampart, army, stocks.
##
## The target is never told. Spying again renews the report.

## Names the human player as a target, for a script or a replay that cannot
## know the id of the player's game.
const HUMAN := "human"

var target_player_id: String


func _init(target_player_id_: String) -> void:
	target_player_id = target_player_id_


func _target_id(game: Game) -> String:
	return game.human_player_id if target_player_id == HUMAN else target_player_id


func type() -> ActionType.Value:
	return ActionType.Value.SPY_BASE


func description() -> String:
	return "Espionne la base %s" % target_player_id


## Why `player` may not spy on `target_id` now, null if it may; the part of
## `validate` a screen can tell before the Scout leaves.
static func refusal(game: Game, player: Player, target_id: String) -> Variant:
	var target: Player = game.players.get(target_id)
	if target == null:
		return ActionFailure.Value.NO_SUCH_PLAYER
	if target.id == player.id:
		return ActionFailure.Value.CANNOT_ATTACK_SELF
	if target.has_fallen():
		return ActionFailure.Value.PLAYER_FALLEN
	var seen := player.revealed_cells_set_on_level(RaidBattle.BASE_LEVEL).has(Vector2i(target.base_x, target.base_y))
	if not seen:
		return ActionFailure.Value.BASE_NOT_REVEALED
	var scouts := Unit.count_in(player.units_on_level(RaidBattle.BASE_LEVEL), UnitType.Value.SCOUT)
	return null if scouts > 0 else ActionFailure.Value.NOT_ENOUGH_UNITS


func validate(game: Game, player: Player) -> ActionResult:
	return ActionResult.new(refusal(game, player, _target_id(game)))


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var target: Player = game.players[_target_id(game)]
	player.units_on_level(RaidBattle.BASE_LEVEL)[UnitType.Value.SCOUT].count -= 1
	var stocks: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in target.resources:
		stocks[type] = target.resources[type].amount
	player.intel()[target.id] = BaseIntel.new(
		game.turn,
		target.buildings[BuildingType.Value.HEADQUARTERS].level,
		CoralCitadelRampart.level_of(target.buildings),
		RaidBattle.defenders_of(target),
		stocks,
	)
	return ActionResult.success()
