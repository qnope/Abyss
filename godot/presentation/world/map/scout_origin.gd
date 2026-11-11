class_name ScoutOrigin
extends RefCounted
## The cell a scout sent to a target sets off from (lib/presentation/widgets/
## map/scout_origin.dart): on the first level the player's base; deeper, the
## units of a level came down through the passages under the posts the player
## holds, so the nearest of those; without one, the nearest cell seen; with
## nothing seen, the target itself.


## Where the scout of [param target] sets off from. [param base] is the
## player's base (a Vector2i, or null away from the first level),
## [param holders] who holds the post above each passage of the level, and
## [param revealed] the cells seen.
static func of(
	target: Vector2i, base: Variant, holders: Dictionary[Vector2i, PostHolder.Value],
	revealed: Dictionary[Vector2i, bool]
) -> Vector2i:
	if base != null:
		var home: Vector2i = base
		return home
	var held: Array[Vector2i] = []
	for cell: Vector2i in holders:
		if holders[cell] == PostHolder.Value.HUMAN:
			held.append(cell)
	if held.is_empty():
		for cell: Vector2i in revealed:
			if cell != target:
				held.append(cell)
	return _nearest(target, held)


## The cell of [param cells] nearest to [param target]; between cells as near,
## the upper one, then the left one, so that the answer never depends on the
## order. The target itself when there is none.
static func _nearest(target: Vector2i, cells: Array[Vector2i]) -> Vector2i:
	var best := target
	var best_distance := -1
	for cell in cells:
		var distance := (cell - target).length_squared()
		if best_distance < 0 or distance < best_distance \
				or (distance == best_distance and _before(cell, best)):
			best = cell
			best_distance = distance
	return best


static func _before(cell: Vector2i, other: Vector2i) -> bool:
	return cell.y < other.y or (cell.y == other.y and cell.x < other.x)
