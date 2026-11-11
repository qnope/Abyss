class_name TurnForecast
extends RefCounted
## What the end of the current turn will do to the player's base, for the
## confirmation that comes before it
## (lib/presentation/screens/game/game_screen_turn_helpers.dart:
## computeProduction, computeBuildingsToDeactivate, computeUnitsToLose). It
## shares TurnProduction with the end of the turn itself, so they agree.

## The turn about to end.
var turn: int
## What the base will make, the pearls of its posts included.
var production: Dictionary[ResourceType.Value, int]
## The buildings the lack of energy will shut down.
var buildings_to_deactivate: Array[BuildingType.Value]
## The units the lack of algae will take, by type.
var units_to_lose: Dictionary[UnitType.Value, int]
## The scouts sent and not yet back.
var pending_explorations: int


func _init(
	turn_: int,
	production_: Dictionary[ResourceType.Value, int],
	deactivated: Array[BuildingType.Value],
	lost: Dictionary[UnitType.Value, int],
	pending_explorations_ := 0,
) -> void:
	turn = turn_
	production = production_
	buildings_to_deactivate = deactivated
	units_to_lose = lost
	pending_explorations = pending_explorations_


## The forecast of the human's turn in [param game].
static func of(game: Game) -> TurnForecast:
	var human := game.human_player()
	var made := TurnFigures.production(game, human)
	var deactivated := TurnProduction.deactivated(human, made, game.turn)
	var kept := TurnProduction.of(human, game.turn, game.difficulty(), deactivated)
	var algae: int = kept.get(ResourceType.Value.ALGAE, 0)
	var lost := UnitLossCalculator.calculate_losses_all_levels(
		human.units_per_level,
		algae,
		GameResource.amount_in(human.resources, ResourceType.Value.ALGAE),
	)
	return TurnForecast.new(game.turn, made, deactivated, lost, human.pending_explorations.size())
