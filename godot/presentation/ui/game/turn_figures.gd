class_name TurnFigures
extends RefCounted
## What the base will make and spend at the end of the current turn, the
## figures of the resource bar
## (lib/presentation/screens/game/game_screen_turn_helpers.dart:
## computeProduction, computeConsumption). The end of the turn itself and
## these previews share TurnProduction, so they agree.


## What the base will make: the buildings' production, scaled by the
## difficulty and changed by the lasting event, and the pearls the posts
## hold bring.
static func production(game: Game, player: Player) -> Dictionary[ResourceType.Value, int]:
	var made := TurnProduction.of(player, game.turn, game.difficulty())
	var pearls := PearlIncome.of(game, player.id)
	if pearls > 0:
		made[ResourceType.Value.PEARL] = made.get(ResourceType.Value.PEARL, 0) + pearls
	return made


## What the base will spend: the energy of its buildings and the algae its
## units eat, the resources spent nothing left out.
static func consumption(game: Game, player: Player) -> Dictionary[ResourceType.Value, int]:
	var spent: Dictionary[ResourceType.Value, int] = {}
	var energy := TurnProduction.energy_consumption(player, game.turn)
	if energy > 0:
		spent[ResourceType.Value.ENERGY] = energy
	var algae := ConsumptionCalculator.total_unit_consumption_all_levels(player.units_per_level)
	if algae > 0:
		spent[ResourceType.Value.ALGAE] = algae
	return spent
