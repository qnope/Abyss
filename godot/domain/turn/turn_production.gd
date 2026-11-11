class_name TurnProduction
extends RefCounted
## lib/domain/turn/turn_production.dart: what a player's base makes and
## spends at the end of a turn, for the end of turn itself and for every
## prediction of it. Ported ahead of the `turn` module: the scripts predict
## their stocks with it.


## What the buildings make at the end of `turn`, `deactivated` ones apart:
## scaled by `difficulty`, then changed by the random event lasting during
## `turn`; a faction (`is_faction`) by the difficulty's faction percent. The
## pearl income comes on top.
static func of(
	player: Player,
	turn: int,
	difficulty: Difficulty.Value,
	deactivated: Array[BuildingType.Value] = [],
	is_faction := false,
) -> Dictionary[ResourceType.Value, int]:
	var buildings: Dictionary[BuildingType.Value, Building] = player.buildings.duplicate()
	for type: BuildingType.Value in deactivated:
		buildings[type] = Building.new(type, 0)
	return EventProduction.adjust(
		Difficulty.scale_production(
			difficulty,
			ProductionCalculator.from_buildings(buildings, player.tech_branches),
			is_faction,
		),
		player.event_state,
		turn,
	)


## Energy spent at the end of `turn`: the buildings still running, plus the
## heating of a cold current.
static func energy_consumption(
	player: Player, turn: int, deactivated: Array[BuildingType.Value] = []
) -> int:
	var excluded: Dictionary[BuildingType.Value, bool] = {}
	for type: BuildingType.Value in deactivated:
		excluded[type] = true
	return (
		ConsumptionCalculator.total_building_consumption(player.buildings, excluded)
		+ EventProduction.heating_energy(player.event_state, turn)
	)


## Buildings shut down at the end of `turn` for lack of energy, given the
## `production` of the turn. The heating is paid first.
static func deactivated(
	player: Player, production: Dictionary[ResourceType.Value, int], turn: int
) -> Array[BuildingType.Value]:
	var energy: int = production.get(ResourceType.Value.ENERGY, 0)
	return BuildingDeactivator.deactivate(
		player.buildings,
		energy - EventProduction.heating_energy(player.event_state, turn),
		GameResource.amount_in(player.resources, ResourceType.Value.ENERGY),
	)
