class_name DartEnum
extends RefCounted
## The names Dart gives the values of an enum, for a Dart enum ported as a
## GDScript one. The snapshots, the journals and the vectors write
## `BuildingType.algaeFarm` as "algaeFarm"; the port declares
## `enum Value { HEADQUARTERS, ALGAE_FARM }` in the Dart order, so a value is
## its Dart `index`, and its Dart name is its constant with every `_x` read
## as `X`: ALGAE_FARM is algaeFarm, HQ_LEVEL_1 is hqLevel1.
##
##     DartEnum.name_of(BuildingType.Value, type)        # type.name
##     DartEnum.by_name(BuildingType.Value, "algaeFarm") # values.asNameMap()[..]
##     DartEnum.names(BuildingType.Value)                # values, by name
##
## The first argument is the enum itself, which GDScript reads as the
## dictionary of its constants.


## `value.name`. A number that is no value of the enum logs an error and
## gives "": Dart has no such value.
static func name_of(enumeration: Dictionary, value: int) -> String:
	var constant: Variant = enumeration.find_key(value)
	if constant == null:
		push_error("DartEnum.name_of: %d is no value of %s" % [value, enumeration.keys()])
		return ""
	var text: String = constant
	return dart_name(text)


## `Enum.values.asNameMap()[name]`: the value Dart names so, or null.
static func by_name(enumeration: Dictionary, name: String) -> Variant:
	for constant: String in enumeration:
		if dart_name(constant) == name:
			return enumeration[constant]
	return null


## The Dart names of the values, in the order of the declaration.
static func names(enumeration: Dictionary) -> PackedStringArray:
	var found := PackedStringArray()
	for constant: String in enumeration:
		found.append(dart_name(constant))
	return found


## The Dart name of a GDScript constant: CORAL_CITADEL is coralCitadel.
static func dart_name(constant: String) -> String:
	var words := constant.to_lower().split("_")
	var name := words[0]
	for index: int in range(1, words.size()):
		name += words[index].left(1).to_upper() + words[index].substr(1)
	return name
