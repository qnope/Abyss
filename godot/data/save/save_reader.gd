class_name SaveReader
extends RefCounted
## Reads back the JSON a codec wrote, one value at a time, and never stops
## on a bad one: a missing field, a value of the wrong type or an unknown
## enum name is noted in `problem` (the first one only) and a default comes
## back in its place, so a codec reads a whole save without checking each
## step and the save is refused once it is read (SaveCodec).
##
## Godot's JSON reads every number as a float: a whole number is turned
## back into an int, and a number that is not a whole one, or too big for a
## float to hold it exactly (beyond 2^53), is a problem.

## The largest whole number a float holds exactly.
const MAX_WHOLE := 9007199254740992

## The first problem met, empty while none.
var problem := ""
## The values of each enumeration read so far, by their Dart names.
var _values_by_name := {}


func ok() -> bool:
	return problem.is_empty()


## Notes `what` went wrong, unless something already did.
func fail(what: String) -> void:
	if problem.is_empty():
		problem = what


## The value of `key` in `map`; a problem when it has none.
func at(map: Dictionary, key: String) -> Variant:
	if not map.has(key):
		fail("%s is missing" % key)
		return null
	return map[key]


func object(value: Variant, what: String) -> Dictionary:
	if value is Dictionary:
		return value
	fail("%s is not an object" % what)
	return {}


func list(value: Variant, what: String) -> Array:
	if value is Array:
		return value
	fail("%s is not a list" % what)
	return []


func whole(value: Variant, what: String) -> int:
	if value is int:
		return value
	if value is float:
		var number: float = value
		if number == floorf(number) and absf(number) <= MAX_WHOLE:
			return int(number)
	fail("%s is not a whole number" % what)
	return 0


func boolean(value: Variant, what: String) -> bool:
	if value is bool:
		return value
	fail("%s is not true or false" % what)
	return false


func text(value: Variant, what: String) -> String:
	if value is String:
		return value
	fail("%s is not a text" % what)
	return ""


## The value of `enumeration` Dart names `value`.
func enum_value(value: Variant, enumeration: Dictionary, what: String) -> int:
	if not _values_by_name.has(enumeration):
		var by_name := {}
		for constant: String in enumeration:
			by_name[DartEnum.dart_name(constant)] = enumeration[constant]
		_values_by_name[enumeration] = by_name
	var names: Dictionary = _values_by_name[enumeration]
	var found: Variant = names.get(value) if value is String else null
	if found == null:
		fail("%s: %s is no %s" % [what, JSON.stringify(value), "|".join(DartEnum.names(enumeration))])
		return 0
	return found


func object_at(map: Dictionary, key: String) -> Dictionary:
	return object(at(map, key), key)


func list_at(map: Dictionary, key: String) -> Array:
	return list(at(map, key), key)


func int_at(map: Dictionary, key: String) -> int:
	return whole(at(map, key), key)


func bool_at(map: Dictionary, key: String) -> bool:
	return boolean(at(map, key), key)


func text_at(map: Dictionary, key: String) -> String:
	return text(at(map, key), key)


func enum_at(map: Dictionary, key: String, enumeration: Dictionary) -> int:
	return enum_value(at(map, key), enumeration, key)


## An object, or null.
func object_or_null_at(map: Dictionary, key: String) -> Variant:
	var value: Variant = at(map, key)
	return null if value == null else object(value, key)


## An int, or null.
func int_or_null_at(map: Dictionary, key: String) -> Variant:
	var value: Variant = at(map, key)
	return null if value == null else whole(value, key)


## A String, or null.
func text_or_null_at(map: Dictionary, key: String) -> Variant:
	var value: Variant = at(map, key)
	return null if value == null else text(value, key)


## A value of `enumeration`, or null.
func enum_or_null_at(map: Dictionary, key: String, enumeration: Dictionary) -> Variant:
	var value: Variant = at(map, key)
	return null if value == null else enum_value(value, enumeration, key)
