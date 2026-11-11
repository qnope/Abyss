class_name TextKeys
extends RefCounted
## The ARB key of the text of an enum value, built the way the Dart
## extensions of lib/presentation/extensions name it: a prefix, the Dart name
## of the value with its first letter in capital, a suffix. Building
## algaeFarm's name is `buildingAlgaeFarmName`.
##
##     TextKeys.of("building", BuildingType.Value, type, "Name")


## `prefix` + the Dart name of `value` capitalised + `suffix`.
static func of(prefix: String, enumeration: Dictionary, value: int, suffix := "") -> StringName:
	return StringName(prefix + capitalised(DartEnum.name_of(enumeration, value)) + suffix)


## `text` with its first letter in capital: domeBreaker is DomeBreaker.
static func capitalised(text: String) -> String:
	return text.left(1).to_upper() + text.substr(1)
