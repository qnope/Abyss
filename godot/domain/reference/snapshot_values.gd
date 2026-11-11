class_name SnapshotValues
extends RefCounted
## lib/domain/reference/snapshot_values.dart: shapes shared by the snapshots
## of the model's collections. An enum is written by its Dart name, so the
## functions that write one take the enum itself (`ResourceType.Value`).


## A map as the list of its `[key, value]` pairs, in the order it iterates:
## that order is part of the state (a fight lines the units up in it), and
## a canonical map would lose it by sorting its keys. `key` and `value`
## take an entry and give what is written.
static func pairs(map: Dictionary, key: Callable, value: Callable) -> Array:
	var written: Array = []
	for k: Variant in map:
		written.append([key.call(k), value.call(map[k])])
	return written


## A count by enum value (units by type, resources by type), as pairs.
static func counts(map: Dictionary, enumeration: Dictionary) -> Array:
	var written: Array = []
	for k: int in map:
		written.append([name(enumeration, k), map[k]])
	return written


static func names(values: Array, enumeration: Dictionary) -> Array:
	var written: Array = []
	for value: int in values:
		written.append(name(enumeration, value))
	return written


static func name(enumeration: Dictionary, value: int) -> String:
	return DartEnum.name_of(enumeration, value)


## Not in the Dart class: `value?.name`, for an enum field that may be
## null.
static func name_or_null(enumeration: Dictionary, value: Variant) -> Variant:
	if value == null:
		return null
	var known: int = value
	return name(enumeration, known)


## A decoded JSON value where every object becomes the list of its pairs,
## so the order of its keys is kept.
static func ordered(json: Variant) -> Variant:
	if json is Dictionary:
		var map: Dictionary = json
		return pairs(map, func(k: Variant) -> Variant: return k, ordered)
	if json is Array:
		var list: Array = json
		return list.map(ordered)
	return json
