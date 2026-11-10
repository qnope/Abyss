class_name Building
extends RefCounted
## lib/domain/building/building.dart: a building of a base and its level,
## 0 while it is not built.

var type: BuildingType.Value
var level: int


func _init(type_: BuildingType.Value, level_ := 0) -> void:
	type = type_
	level = level_
