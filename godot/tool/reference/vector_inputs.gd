class_name VectorInputs
extends RefCounted
## Builds the objects the rules take from what a vector case writes, and
## writes what they answer as a case does: tool/vectors/domain/
## vector_inputs.dart on the Godot side. A case writes an enum value by its
## Dart name, and a JSON object carries no order: a map built here follows
## the order of the enum. What comes from a case is a Variant, so a test hands
## it over as it is.

## Storage of the stocks of a new player (`PlayerDefaults.resources`).
const STORAGE: Dictionary[ResourceType.Value, int] = {
	ResourceType.Value.ALGAE: 5000,
	ResourceType.Value.CORAL: 5000,
	ResourceType.Value.ORE: 5000,
	ResourceType.Value.ENERGY: 2000,
	ResourceType.Value.PEARL: 100,
}


## The value of the enum a case names.
static func value(enumeration: Dictionary, name: Variant) -> int:
	var text: String = name
	var found: Variant = DartEnum.by_name(enumeration, text)
	if found == null:
		push_error('VectorInputs: no "%s" among %s' % [text, DartEnum.names(enumeration)])
		return -1
	return found


## `{name: whole number}` as the `Dictionary[Enum.Value, int]` a rule takes:
## the values of the enum the case names, in the order of the enum.
static func amounts(enumeration: Dictionary, named_amounts: Variant) -> Dictionary:
	var given: Dictionary = named_amounts
	var typed := Dictionary({}, TYPE_INT, &"", null, TYPE_INT, &"", null)
	for name: String in DartEnum.names(enumeration):
		if given.has(name):
			typed[value(enumeration, name)] = given[name]
	return typed


## A map keyed by the values of an enum, keyed by their Dart names as a case
## writes it.
static func named(enumeration: Dictionary, map: Dictionary) -> Dictionary:
	var written := {}
	for key: int in map:
		written[DartEnum.name_of(enumeration, key)] = map[key]
	return written


## A list of values of an enum as the list of their Dart names.
static func names(enumeration: Dictionary, values: Array) -> Array:
	return values.map(func(key: int) -> String: return DartEnum.name_of(enumeration, key))


## The five stocks in the order of ResourceType, holding the amounts the
## case names (0 otherwise) under the STORAGE of a new player.
static func resources(named_amounts: Variant) -> Dictionary[ResourceType.Value, GameResource]:
	var given: Dictionary = named_amounts
	var stocks: Dictionary[ResourceType.Value, GameResource] = {}
	for type: ResourceType.Value in ResourceType.Value.values():
		var amount: int = given.get(DartEnum.name_of(ResourceType.Value, type), 0)
		stocks[type] = GameResource.new(type, amount, STORAGE[type])
	return stocks
