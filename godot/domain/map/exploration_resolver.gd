class_name ExplorationResolver
extends RefCounted
## lib/domain/map/exploration_resolver.dart: at the end of a turn, each
## scout sent reveals the square around its target, as wide as the research
## of its player allows.


## The finds of the human's scouts, in the order sent. Every player's
## orders are carried out and cleared, a faction's too.
static func resolve(game: Game) -> Array[ExplorationResult]:
	var results: Array[ExplorationResult] = []
	for player: Player in game.players.values():
		if player.pending_explorations.is_empty():
			continue
		var reveal_side := TechEffects.of(player).reveal_side()
		for order: ExplorationOrder in player.pending_explorations:
			var map: GameMap = game.levels.get(order.level)
			if map == null:
				continue
			var positions := RevealAreaCalculator.cells_to_reveal(
				order.target.x, order.target.y, reveal_side, map.width, map.height
			)
			var new_cells := 0
			var notable: Array[CellContentType.Value] = []
			for pos: GridPosition in positions:
				if player.add_revealed_cell(order.level, pos):
					new_cells += 1
					var cell := map.cell_at(pos.x, pos.y)
					if cell.content != CellContentType.Value.EMPTY:
						notable.append(cell.content)
			VolcanoFootprint.reveal_whole(map, player, order.level)
			# Factions reveal too, but only the human's finds are reported.
			if player.id != game.human_player_id:
				continue
			results.append(ExplorationResult.new(order.target, new_cells, notable))
		player.pending_explorations.clear()
	return results
