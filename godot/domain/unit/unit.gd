class_name Unit
extends RefCounted
## lib/domain/unit/unit.dart: the units of one type a player holds on a
## level.

var type: UnitType.Value
var count: int


func _init(type_: UnitType.Value, count_ := 0) -> void:
	type = type_
	count = count_


## `units[type]?.count ?? 0`, which GDScript cannot write in one go: how
## many `type` the map holds, 0 when it holds no such entry. Not in the
## Dart class.
static func count_in(units: Dictionary[UnitType.Value, Unit], type_: UnitType.Value) -> int:
	var unit: Unit = units.get(type_)
	return unit.count if unit != null else 0
