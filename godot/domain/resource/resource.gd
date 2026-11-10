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


## `resources[type]?.amount ?? 0`, which GDScript cannot write in one go: the
## amount in stock of `type`, 0 when the map does not hold it. Not in the
## Dart class.
static func amount_in(
	resources: Dictionary[ResourceType.Value, GameResource], type_: ResourceType.Value
) -> int:
	var resource: GameResource = resources.get(type_)
	return resource.amount if resource != null else 0
