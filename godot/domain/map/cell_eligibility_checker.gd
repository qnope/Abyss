class_name CellEligibilityChecker
extends RefCounted
## lib/domain/map/cell_eligibility_checker.dart: the cells a scout can be
## sent to: a revealed one, or one next to it, never the base. A set of
## cells is the set of their keys (GridPosition.key()).


static func is_eligible(map: GameMap, player: Player, x: int, y: int, level := 1) -> bool:
	return is_eligible_among(map, player, player.revealed_cells_set_on_level(level), x, y, level)


## is_eligible() with the `revealed` cells of `level` already gathered, to
## test many cells at the cost of one lookup each.
static func is_eligible_among(
	map: GameMap, player: Player, revealed: Dictionary[Vector2i, bool], x: int, y: int, level := 1
) -> bool:
	if level == 1 and x == player.base_x and y == player.base_y:
		return false
	# Revealed cells are eligible
	if revealed.has(Vector2i(x, y)):
		return true
	# Unrevealed cells adjacent to a revealed cell are eligible
	return _has_revealed_neighbor(map, revealed, x, y)


static func _has_revealed_neighbor(
	map: GameMap, revealed: Dictionary[Vector2i, bool], x: int, y: int
) -> bool:
	for dy: int in range(-1, 2):
		for dx: int in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx := x + dx
			var ny := y + dy
			if nx < 0 or nx >= map.width or ny < 0 or ny >= map.height:
				continue
			if revealed.has(Vector2i(nx, ny)):
				return true
	return false
