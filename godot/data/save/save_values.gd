class_name SaveValues
extends RefCounted
## Shapes shared by the codecs when they write: an enum by its Dart name, a
## map keyed by an enum as an object keyed by those names, a map keyed by a
## whole number (a level, a turn) as an object keyed by its digits, each in
## the order the map iterates, which is part of the state.


static func name(enumeration: Dictionary, value: int) -> String:
	return DartEnum.name_of(enumeration, value)


## The name of an enum value that may be null, or null.
static func name_or_null(enumeration: Dictionary, value: Variant) -> Variant:
	if value == null:
		return null
	var known: int = value
	return name(enumeration, known)


static func names(values: Array, enumeration: Dictionary) -> Array:
	var written: Array = []
	for value: int in values:
		written.append(name(enumeration, value))
	return written


## A count by enum value (units by type, resources by type).
static func counts(map: Dictionary, enumeration: Dictionary) -> Dictionary:
	var written := {}
	for value: int in map:
		written[name(enumeration, value)] = map[value]
	return written


## `write(item)` for each item, in order.
static func list_of(items: Array, write: Callable) -> Array:
	var written: Array = []
	for item: Variant in items:
		written.append(write.call(item))
	return written


## `write(value)`, or null for a missing object.
static func or_null(value: Object, write: Callable) -> Variant:
	return null if value == null else write.call(value)


## A map keyed by whole numbers, `write(value)` for each value.
static func by_number(map: Dictionary, write: Callable) -> Dictionary:
	var written := {}
	for key: int in map:
		written[str(key)] = write.call(map[key])
	return written
