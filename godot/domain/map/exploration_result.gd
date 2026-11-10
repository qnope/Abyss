class_name ExplorationResult
extends RefCounted
## lib/domain/map/exploration_result.dart: what a scout found around its
## target.

var target: GridPosition
var new_cells_revealed: int
## What the cells newly revealed hold, the empty ones left out.
var notable_content: Array[CellContentType.Value]


func _init(
	target_: GridPosition,
	new_cells_revealed_: int,
	notable_content_: Array[CellContentType.Value] = [],
) -> void:
	target = target_
	new_cells_revealed = new_cells_revealed_
	notable_content = notable_content_
