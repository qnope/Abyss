class_name MapGenerationResult
extends RefCounted
## lib/domain/map/map_generation_result.dart: a generated level and where
## its players start.

var map: GameMap
var base_x: int
var base_y: int
## Starting base of every player, the first one at (`base_x`, `base_y`).
var bases: Array[GridPosition]


## Without `bases_` (Dart's null, an empty list here), the one base of a
## lone player.
func _init(
	map_: GameMap, base_x_: int, base_y_: int, bases_: Array[GridPosition] = []
) -> void:
	map = map_
	base_x = base_x_
	base_y = base_y_
	bases = bases_
	if bases.is_empty():
		bases = [GridPosition.new(base_x, base_y)]
