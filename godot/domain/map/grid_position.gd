class_name GridPosition
extends RefCounted
## lib/domain/map/grid_position.dart: a cell of a map, by its column and its
## row.
##
## Dart compares two positions by their coordinates, and keys maps and sets
## with them. GDScript compares objects by identity: `equals` compares two
## positions, and a map or a set of positions is keyed by `key()`, a
## Vector2i, which Godot compares by content (`Dictionary[Vector2i, String]`
## for a `Map<GridPosition, String>`).

var x: int
var y: int


func _init(x_: int, y_: int) -> void:
	x = x_
	y = y_


## `operator ==`: another position of the same coordinates.
func equals(other: Variant) -> bool:
	if not other is GridPosition:
		return false
	var position: GridPosition = other
	return position.x == x and position.y == y


## What stands for this position as the key of a map or the member of a set.
## Not in the Dart class, where the position itself does.
func key() -> Vector2i:
	return Vector2i(x, y)


## The position a key stands for. Not in the Dart class.
static func of_key(key_: Vector2i) -> GridPosition:
	return GridPosition.new(key_.x, key_.y)


## The keys of the positions, in their order. Not in the Dart class.
static func keys(positions: Array[GridPosition]) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	for position: GridPosition in positions:
		found.append(position.key())
	return found


func _to_string() -> String:
	return "GridPosition(%d, %d)" % [x, y]
