class_name ExploreMoves
extends RefCounted
## lib/domain/script/strategies/explore_moves.dart: scouting moves, picking
## what to explore and picking up what was found. The Dart extension on
## ScriptTurn: each function takes the turn first.
##
## Scripts only act on what the player has revealed, like a real player.


## Revealed cells of `level` whose content passes `test` (a MapCell -> bool).
static func revealed_where(turn: ScriptTurn, level: int, test: Callable) -> Array[GridPosition]:
	var found: Array[GridPosition] = []
	var map: GameMap = turn.game.levels.get(level)
	if map == null:
		return found
	for p: GridPosition in turn.player.revealed_cells_on_level(level):
		if test.call(map.cell_at(p.x, p.y)):
			found.append(p)
	return found


## Picks up every revealed treasure (resources and ruins) of `level`.
static func collect_revealed(turn: ScriptTurn, level: int) -> void:
	var treasures := revealed_where(turn, level, func(c: MapCell) -> bool:
		return not c.is_collected() and (
			c.content == CellContentType.Value.RESOURCE_BONUS or c.content == CellContentType.Value.RUINS
		))
	for p: GridPosition in treasures:
		turn.try_perform(CollectTreasureAction.new(p.x, p.y, level, turn.random()))


## Sends up to `count` scouts of `level` to the frontier cells that reveal
## the most new cells, plus `bias` (a GridPosition -> float) of each target.
static func explore(turn: ScriptTurn, level: int, count: int, bias: Callable) -> void:
	var map: GameMap = turn.game.levels.get(level)
	if map == null:
		return
	var player := turn.player
	var revealed := player.revealed_cells_on_level(level)
	var known: Dictionary[Vector2i, bool] = {}
	for p: GridPosition in revealed:
		known[p.key()] = true
	var side := TechEffects.of(player).reveal_side()
	# Orders only queue explorations: the frontier holds for every scout.
	var frontier := _frontier(map, revealed)
	for i: int in count:
		var scouts: Unit = player.units_on_level(level).get(UnitType.Value.SCOUT)
		if scouts == null or scouts.count <= 0:
			return
		var best: GridPosition = null
		var best_score := 0.0
		for p: GridPosition in frontier:
			if known.has(p.key()):
				continue
			var fresh := 0
			for a: GridPosition in _area(map, p, side):
				if not known.has(a.key()):
					fresh += 1
			# Dart's `if (fresh == 0) continue;`, which no cell meets: the
			# area of a cell not known holds that cell.
			if fresh != 0:
				var score: float = fresh + bias.call(p)
				if best == null or score > best_score:
					best = p
					best_score = score
		if best == null:
			return
		var action := ExploreAction.new(best.x, best.y, level)
		if not turn.try_perform(action):
			return
		for a: GridPosition in _area(map, best, side):
			known[a.key()] = true


## Whether every cell of `level` has been revealed.
static func fully_explored(turn: ScriptTurn, level: int) -> bool:
	var map: GameMap = turn.game.levels.get(level)
	if map == null:
		return false
	return turn.player.revealed_cells_on_level(level).size() >= map.width * map.height


static func _area(map: GameMap, p: GridPosition, side: int) -> Array[GridPosition]:
	return RevealAreaCalculator.cells_to_reveal(p.x, p.y, side, map.width, map.height)


## Unrevealed cells of `map` touching a revealed one, in row-major order.
static func _frontier(map: GameMap, revealed: Array[GridPosition]) -> Array[GridPosition]:
	var mask := CellMask.new(map.width, map.height, revealed)
	var frontier: Array[GridPosition] = []
	for y: int in map.height:
		for x: int in map.width:
			if not mask.contains(x, y) and mask.touches(x, y):
				frontier.append(GridPosition.new(x, y))
	return frontier
