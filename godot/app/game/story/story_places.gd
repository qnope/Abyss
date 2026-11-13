class_name StoryPlaces
extends RefCounted
## Where the places fought over at the end of a turn stand on the maps
## (lib/presentation/screens/game/story/story_places.dart).


## The top left cell of the volcano of [param map] that [param player_id] holds,
## else the first one: a Vector2i, or null when the map has none.
static func kernel_of(map: GameMap, player_id: String) -> Variant:
	if map == null:
		return null
	var first: Variant = null
	for y in map.height:
		for x in map.width:
			var cell := map.cell_at(x, y)
			if cell.content != CellContentType.Value.VOLCANIC_KERNEL:
				continue
			if cell.collected_by == player_id:
				return Vector2i(x, y)
			if first == null:
				first = Vector2i(x, y)
	return first


## The level and the cell of the post named [param post] in [param game]: a
## Vector3i of (level, x, y), or null when no map holds it.
static func post_of(game: Game, post: TransitionBaseName) -> Variant:
	var levels: Array[int] = []
	for level: int in game.levels:
		levels.append(level)
	levels.sort()
	for level in levels:
		var map := game.levels[level]
		for y in map.height:
			for x in map.width:
				var base := map.cell_at(x, y).transition_base
				var named := base.base_name() if base != null else null
				if named != null and named.code() == post.code():
					return Vector3i(level, x, y)
	return null
