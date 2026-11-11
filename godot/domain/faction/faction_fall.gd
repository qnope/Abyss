class_name FactionFall
extends RefCounted
## lib/domain/faction/faction_fall.dart: a faction falls like the human base
## does, after three raids lost in a row. It stops playing and its posts are
## free again; the game goes on, as only the human's defeat ends it.


## Drops the factions that have just lost their third raid in a row.
static func apply(game: Game) -> void:
	for faction: Faction in game.factions():
		var player: Player = game.players.get(faction.id())
		if player == null or player.has_fallen():
			continue
		if player.raid_state.lost_in_a_row < DefeatChecker.LOST_RAIDS_LIMIT:
			continue
		player.saved_fallen = true
		_free_posts_of(game, player.id)


static func _free_posts_of(game: Game, player_id: String) -> void:
	for map: GameMap in game.levels.values():
		for i: int in map.cells.size():
			var cell := map.cells[i]
			if cell.transition_base != null and cell.transition_base.captured_by == player_id:
				cell.transition_base.captured_by = null
			if (
				cell.content == CellContentType.Value.VOLCANIC_KERNEL
				and cell.collected_by == player_id
			):
				map.cells[i] = cell.copy_with({"collected_by": null})
