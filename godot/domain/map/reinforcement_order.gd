class_name ReinforcementOrder
extends RefCounted
## lib/domain/map/reinforcement_order.dart: units sent from a level to
## another, which arrive the turn after they leave.

var from_level: int
var to_level: int
var units: Dictionary[UnitType.Value, int]
var depart_turn: int
var arrival_point: GridPosition


func _init(
	from_level_: int,
	to_level_: int,
	units_: Dictionary[UnitType.Value, int],
	depart_turn_: int,
	arrival_point_: GridPosition,
) -> void:
	from_level = from_level_
	to_level = to_level_
	units = units_
	depart_turn = depart_turn_
	arrival_point = arrival_point_


func is_ready_to_arrive(current_turn: int) -> bool:
	return current_turn > depart_turn
