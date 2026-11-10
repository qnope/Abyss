class_name GameResource
extends RefCounted
## lib/domain/resource/resource.dart, `Resource` in Dart: Godot has a class
## of that name. The stock of one resource of a player.

## Energy storage: the dearest research (1048 with three branches open) must
## fit. Saves made with the old 1000 cap are lifted on load.
const MIN_ENERGY_STORAGE := 2000

var type: ResourceType.Value
var amount: int
var max_storage: int


func _init(type_: ResourceType.Value, amount_: int, max_storage_ := 500) -> void:
	type = type_
	amount = amount_
	var lifted := type == ResourceType.Value.ENERGY and max_storage_ < MIN_ENERGY_STORAGE
	max_storage = MIN_ENERGY_STORAGE if lifted else max_storage_
