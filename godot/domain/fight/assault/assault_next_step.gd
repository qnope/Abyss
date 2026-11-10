class_name AssaultNextStep
extends RefCounted
## lib/domain/fight/assault/assault_next_step.dart: the passage building to
## raise once a post is captured, and whether the headquarters already
## allow it.

var building: BuildingType.Value
var required_hq: int
var current_hq: int


func _init(building_: BuildingType.Value, required_hq_: int, current_hq_: int) -> void:
	building = building_
	required_hq = required_hq_
	current_hq = current_hq_


## Whether the headquarters are high enough to build it now.
func is_ready() -> bool:
	return current_hq >= required_hq
