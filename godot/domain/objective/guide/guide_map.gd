class_name GuideMap
extends RefCounted
## lib/domain/objective/guide/guide_map.dart: finds on the maps of a game
## the cells the guide's halo points at: a post to take, a post held, the
## kernel held.


## The cell of `level` holding the `target` (an AssaultTarget.Value) still
## to take that `player` sees nearest to their base, the anchor for the
## kernel; null when they see none.
static func nearest(game: Game, player: Player, target: AssaultTarget.Value, level: int) -> GuideTarget:
	var map: GameMap = game.levels.get(level)
	if map == null:
		return null
	var found: Dictionary[Vector2i, bool] = {}
	for p: GridPosition in player.revealed_cells_on_level(level):
		if AssaultTarget.at(game, level, p.x, p.y) == target:
			var anchor := VolcanoFootprint.anchor_of(map, p.x, p.y)
			found[(anchor if anchor != null else p).key()] = true
	if found.is_empty():
		return null
	var sorted: Array[Vector2i] = found.keys()
	var distance := func(p: Vector2i) -> int:
		var dx := p.x - player.base_x
		var dy := p.y - player.base_y
		return dx * dx + dy * dy
	DartSort.sort(sorted, func(a: Vector2i, b: Vector2i) -> int:
		var da: int = distance.call(a)
		var db: int = distance.call(b)
		if da != db:
			return DartSort.compare_ints(da, db)
		if a.y != b.y:
			return DartSort.compare_ints(a.y, b.y)
		return DartSort.compare_ints(a.x, b.x))
	return GuideTarget.for_cell(level, GridPosition.of_key(sorted[0]))


## The post `player` holds on `level`, null without one.
static func held_post_on(game: Game, player: Player, level: int) -> GuideTarget:
	var held := CapturedBaseFinder.on(game, level, player.id)
	return null if held == null else GuideTarget.for_cell(level, held.position)


## The cell of `post`, null when no map holds it.
static func post_cell(game: Game, post: TransitionBase) -> GuideTarget:
	for level: int in game.levels:
		var found := _first(game, level, func(cell: MapCell) -> bool:
			return cell.transition_base == post)
		if found != null:
			return found
	return null


## The kernel `player` holds and the button of its garrison, null when they
## hold none.
static func held_kernel(game: Game, player: Player) -> GuideTarget:
	for level: int in game.levels:
		var found := _first(game, level, func(cell: MapCell) -> bool:
			return cell.content == CellContentType.Value.VOLCANIC_KERNEL and cell.collected_by == player.id)
		if found != null:
			return GuideTarget.for_garrison(level, found.cell)
	return null


## The first cell of `level` that `matches`, in the order of the cells. Both
## callers pass a level of the game: the check Dart makes for a missing map
## never fails, and is left out.
static func _first(game: Game, level: int, matches: Callable) -> GuideTarget:
	var map: GameMap = game.levels.get(level)
	for i: int in map.cells.size():
		var matched: bool = matches.call(map.cells[i])
		if matched:
			return GuideTarget.for_cell(level, GridPosition.new(i % map.width, DartMath.trunc_div(i, map.width)))
	return null
