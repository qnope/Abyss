class_name PearlIncome
extends RefCounted
## lib/domain/resource/pearl_income.dart: recurring pearl income granted by
## the transition bases a player holds.


static func of(game: Game, player_id: String) -> int:
	var total := 0
	for map: GameMap in game.levels.values():
		for cell: MapCell in map.cells:
			var base := cell.transition_base
			if base != null and base.captured_by == player_id:
				total += base.pearls_per_turn()
	return total


## The pearls of `player_id` as a production, empty when none.
static func as_production(game: Game, player_id: String) -> Dictionary[ResourceType.Value, int]:
	var pearls := of(game, player_id)
	if pearls > 0:
		return {ResourceType.Value.PEARL: pearls}
	return {}
