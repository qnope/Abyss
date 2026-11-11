class_name SaveSummary
extends RefCounted
## lib/domain/game/save_summary.dart: what a save card tells about a game
## without opening it.

var player_name: String
## The turn being played, or the turn the base fell on for a lost game.
var turn: int
var difficulty: Difficulty.Value
var outcome: SaveOutcome.Value
## The deepest map generated: 1 surface, 2 depths, 3 core.
var deepest_level: int
var headquarters_level: int
## Every resource amount, in ResourceType order; read-only.
var resources: Dictionary[ResourceType.Value, int]
## A date, as Game holds one.
var last_played_at: int
## Whether the player holds the volcanic kernel at the core.
var volcanic_kernel_captured: bool


func _init(
	player_name_: String,
	turn_: int,
	difficulty_: Difficulty.Value,
	outcome_: SaveOutcome.Value,
	deepest_level_: int,
	headquarters_level_: int,
	resources_: Dictionary[ResourceType.Value, int],
	last_played_at_: int,
	volcanic_kernel_captured_ := false,
) -> void:
	player_name = player_name_
	turn = turn_
	difficulty = difficulty_
	outcome = outcome_
	deepest_level = deepest_level_
	headquarters_level = headquarters_level_
	resources = resources_
	last_played_at = last_played_at_
	volcanic_kernel_captured = volcanic_kernel_captured_


static func of(game: Game) -> SaveSummary:
	var player := game.human_player()
	var deepest := 1
	for level: int in game.levels:
		deepest = maxi(deepest, level)
	var amounts: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in ResourceType.Value.values():
		amounts[type] = GameResource.amount_in(player.resources, type)
	amounts.make_read_only()
	return SaveSummary.new(
		player.name,
		# A lost game already moved past the turn the base fell on.
		game.turn - 1 if game.status == GameStatus.Value.DEFEAT else game.turn,
		game.difficulty(),
		SaveOutcome.of(game.status),
		deepest,
		Building.level_in(player.buildings, BuildingType.Value.HEADQUARTERS),
		amounts,
		game.last_played_at(),
		game.is_volcanic_kernel_captured_by(player.id),
	)
