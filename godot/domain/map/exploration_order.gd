class_name ExplorationOrder
extends RefCounted
## lib/domain/map/exploration_order.dart: a scout sent to a cell of a level,
## which the end of the turn reveals.

var target: GridPosition
var level: int


func _init(target_: GridPosition, level_ := 1) -> void:
	target = target_
	level = level_
