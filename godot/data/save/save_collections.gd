class_name SaveCollections
extends RefCounted
## Reads the collections SaveValues writes, through a SaveReader that notes
## what is wrong. A map or a list of whole numbers or of enum values comes
## back typed `int` at run time, which an `Array[UnitType.Value]` or a
## `Dictionary[UnitType.Value, int]` takes as it is.


## `read(reader, value)` for each item of the list `value`, in order.
static func list_of(r: SaveReader, value: Variant, what: String, read: Callable) -> Array:
	var found: Array = []
	for item: Variant in r.list(value, what):
		found.append(read.call(r, item))
	return found


## A count by enum value, written by the Dart names of its keys in order.
static func counts_at(r: SaveReader, map: Dictionary, key: String, enumeration: Dictionary) -> Dictionary:
	return counts(r, r.at(map, key), enumeration, key)


static func counts(r: SaveReader, value: Variant, enumeration: Dictionary, what: String) -> Dictionary:
	var found: Dictionary[int, int] = {}
	var written := r.object(value, what)
	for name: Variant in written:
		found[r.enum_value(name, enumeration, what)] = r.whole(written[name], what)
	return found


## A list of enum values, written by their Dart names.
static func names_at(r: SaveReader, map: Dictionary, key: String, enumeration: Dictionary) -> Array:
	var found: Array[int] = []
	for name: Variant in r.list_at(map, key):
		found.append(r.enum_value(name, enumeration, key))
	return found


static func ints_at(r: SaveReader, map: Dictionary, key: String) -> Array:
	var found: Array[int] = []
	for number: Variant in r.list_at(map, key):
		found.append(r.whole(number, key))
	return found


## Turns by player id.
static func turns_by_id_at(r: SaveReader, map: Dictionary, key: String) -> Dictionary[String, int]:
	var found: Dictionary[String, int] = {}
	var written := r.object_at(map, key)
	for id: Variant in written:
		found[r.text(id, key)] = r.whole(written[id], key)
	return found


## The whole number a key of a map by level or by turn is written as: "3"
## is 3, but neither "03", "+3" nor "3.0".
static func number_key(r: SaveReader, key: String, what: String) -> int:
	var parsed: Variant = DartInt.try_parse(key)
	if parsed == null or str(parsed) != key:
		r.fail("%s: %s is not a whole number" % [what, JSON.stringify(key)])
		return 0
	return parsed
