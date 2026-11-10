class_name Unit
extends RefCounted
## lib/domain/unit/unit.dart: the units of one type a player holds on a
## level.

var type: UnitType.Value
var count: int


func _init(type_: UnitType.Value, count_ := 0) -> void:
	type = type_
	count = count_
