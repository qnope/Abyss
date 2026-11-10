class_name RivalTaker
extends RefCounted
## lib/domain/map/rival_taker.dart: who among the factions emptied a cell
## before the human.


## The faction that collected `cell`, or null when the human did, nobody
## did, or the collector is not a faction of `game`.
static func of(game: Game, cell: MapCell) -> Faction:
	var id: Variant = cell.collected_by
	if id == null or id == game.human_player_id:
		return null
	for faction: Faction in game.factions():
		if faction.id() == id and game.players.get(id) != null:
			return faction
	return null
