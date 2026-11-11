class_name ActionFields
extends RefCounted
## lib/domain/script/action_codec.dart, its private class `_Fields`: reads
## the fields of one action of a JSON scenario.
##
## Where Dart throws a FormatException, this logs an error with
## `push_error`, notes it in `failed` and returns a value of the right type
## (0, "", false, an empty map), which `ActionCodec.decode` refuses. Only
## the first error is logged, as Dart stops at the first throw.

var json: Dictionary
## Whether a field was missing or malformed. Not in the Dart class, which
## throws instead.
var failed := false


func _init(json_: Dictionary) -> void:
	json = json_


## The action's own generator when the JSON names its seed.
func rng(fallback: DartRandom) -> DartRandom:
	var seed_: Variant = json.get("seed")
	if seed_ is not int:
		return fallback
	var whole: int = seed_
	return DartRandom.new(whole)


func level() -> int:
	return integer("level") if json.has("level") else 1


func units() -> Dictionary[UnitType.Value, int]:
	var units_: Dictionary[UnitType.Value, int] = {}
	var raw: Variant = json.get("units")
	if raw is not Dictionary:
		_refuse('Champ "units" attendu')
		return units_
	var entries: Dictionary = raw
	for key: Variant in entries:
		var count: Variant = entries[key]
		if count is not int:
			_refuse("Nombre attendu pour %s" % key)
			continue
		units_[_enum_named(UnitType.Value, str(key)) as UnitType.Value] = count
	return units_


func text(key: String) -> String:
	var value: Variant = json.get(key)
	if value is String:
		return value
	_refuse('Champ "%s" attendu' % key)
	return ""


func boolean(key: String) -> bool:
	var value: Variant = json.get(key)
	if value is bool:
		return value
	_refuse('Champ booléen "%s" attendu' % key)
	return false


func integer(key: String) -> int:
	var value: Variant = json.get(key)
	if value is int:
		return value
	_refuse('Champ entier "%s" attendu' % key)
	return 0


## `enumOf(values, key)`: the value of `enumeration` named by the field.
func enum_of(enumeration: Dictionary, key: String) -> int:
	return _enum_named(enumeration, text(key))


func _enum_named(enumeration: Dictionary, name: String) -> int:
	var value: Variant = DartEnum.by_name(enumeration, name)
	if value == null:
		_refuse("Valeur inconnue : %s" % name)
		return 0
	return value


func _refuse(message: String) -> void:
	if not failed:
		push_error(message)
	failed = true
