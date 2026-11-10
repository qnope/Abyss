class_name Building
extends RefCounted
## lib/domain/building/building.dart: a building of a base and its level,
## 0 while it is not built.

var type: BuildingType.Value
var level: int


func _init(type_: BuildingType.Value, level_ := 0) -> void:
	type = type_
	level = level_


## `buildings[type]?.level ?? 0`, which GDScript cannot write in one go: the
## level of the building of `type`, 0 when the map does not hold it. Not in
## the Dart class.
static func level_in(
	buildings: Dictionary[BuildingType.Value, Building], type_: BuildingType.Value
) -> int:
	var building: Building = buildings.get(type_)
	return building.level if building != null else 0
