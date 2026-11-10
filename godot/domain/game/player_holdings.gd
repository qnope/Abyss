class_name PlayerHoldings
extends RefCounted
## Not in the Dart class: the pure helpers of Player, out of player.gd to
## keep it under 150 lines. They read the maps of maps and of lists a Player
## holds, whose inner values GDScript cannot type, back into typed values.


## `unitsPerLevel[level] ?? {}`: the map kept, or a new empty one.
static func units_on(units_per_level: Dictionary[int, Dictionary], level: int) -> Dictionary[UnitType.Value, Unit]:
	if not units_per_level.has(level):
		return {}
	var units: Dictionary[UnitType.Value, Unit] = units_per_level[level]
	return units


## The count of each type of `units`, the empty types left out.
static func unit_counts(units: Dictionary[UnitType.Value, Unit]) -> Dictionary[UnitType.Value, int]:
	var counts: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in units:
		if units[type].count > 0:
			counts[type] = units[type].count
	return counts


## `revealedCellsPerLevel[level] ?? []`: the list kept, or a new empty one.
static func cells_on(cells_per_level: Dictionary[int, Array], level: int) -> Array[GridPosition]:
	if not cells_per_level.has(level):
		return []
	var cells: Array[GridPosition] = cells_per_level[level]
	return cells


## `cells.toSet()`: the keys of the positions (GridPosition.key()), a set.
static func key_set(cells: Array[GridPosition]) -> Dictionary[Vector2i, bool]:
	var keys: Dictionary[Vector2i, bool] = {}
	for key: Vector2i in GridPosition.keys(cells):
		keys[key] = true
	return keys
