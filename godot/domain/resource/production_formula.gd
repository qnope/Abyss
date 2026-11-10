class_name ProductionFormula
extends RefCounted
## lib/domain/resource/production_formula.dart: the resource a building
## makes and how much of it at a level.

var resource_type: ResourceType.Value
## `int Function(int level)`.
var _compute: Callable


func _init(resource_type_: ResourceType.Value, compute_: Callable) -> void:
	resource_type = resource_type_
	_compute = compute_


func compute(level: int) -> int:
	if level <= 0:
		return 0
	var amount: int = _compute.call(level)
	return amount
