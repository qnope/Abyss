class_name ClassFields
extends RefCounted
## The state of a game as the port's classes declare it, for the
## completeness guard of the snapshots (snapshot_completeness_test.gd), as
## test/domain/reference/hive_source.dart reads the `@HiveField`s of the
## Dart model. GDScript has no annotation: the state is every class a Game
## reaches through its typed fields, and their subclasses, each with its
## fields in Dart names.

## The classes the port names otherwise (domain/README.md).
const GODOT_CLASSES: Dictionary[String, String] = {"Resource": "GameResource"}
## The fields the port names otherwise (`seed` is a function of Godot), by
## the Dart name of their class and their GDScript name.
const DART_FIELDS: Dictionary[String, String] = {"GameMap.map_seed": "seed", "AnnouncedAttack.fight_seed": "seed"}
## What a typed field cannot tell: the classes held in a collection inside a
## collection, which GDScript leaves untyped (`units_per_level`,
## `revealed_cells_per_level` of Player).
const HELD_UNTYPED: Array[String] = ["Unit", "GridPosition"]


## The fields of every class of the state, by the Dart name of the class.
## A class whose subclasses are reached (HistoryEntry) is written as them.
static func persisted() -> Dictionary[String, Array]:
	var reached: Array[String] = ["Game"]
	reached.append_array(HELD_UNTYPED)
	var i := 0
	while i < reached.size():
		for field: Dictionary in script_of(reached[i]).get_script_property_list():
			for found: String in _classes_in(field):
				if not reached.has(found):
					reached.append(found)
		for sub: Dictionary in ProjectSettings.get_global_class_list():
			var godot_class: String = sub["class"]
			var base: String = sub["base"]
			var name := _dart(godot_class)
			if base == _godot(reached[i]) and not reached.has(name):
				reached.append(name)
		i += 1
	var classes: Dictionary[String, Array] = {}
	for name: String in reached:
		if not _has_subclass(name):
			classes[name] = of(script_of(name), name)
	return classes


## The fields `script` declares, its bases' included, in Dart names; those
## of DART_FIELDS when it is the class Dart names `dart_class`.
static func of(script: Script, dart_class := "") -> Array[String]:
	var names: Array[String] = []
	for field: Dictionary in script.get_script_property_list():
		var usage: int = field["usage"]
		var name: String = field["name"]
		if usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			names.append(dart_name(name, dart_class))
	return names


## `max_storage` is `maxStorage`, `lost_in_a_row` is `lostInARow`.
static func dart_name(field: String, dart_class := "") -> String:
	var renamed: Variant = DART_FIELDS.get("%s.%s" % [dart_class, field])
	if renamed != null:
		return renamed
	var words := field.split("_")
	for w: int in range(1, words.size()):
		words[w] = words[w].left(1).to_upper() + words[w].substr(1)
	return "".join(words)


## The script of the class Dart names `dart_class`, or null.
static func script_of(dart_class: String) -> Script:
	for known: Dictionary in ProjectSettings.get_global_class_list():
		var godot_class: String = known["class"]
		var path: String = known["path"]
		if godot_class == _godot(dart_class):
			return load(path)
	return null


static func _classes_in(field: Dictionary) -> Array[String]:
	var types := PackedStringArray()
	var type_of: int = field["type"]
	var class_of: String = field["class_name"]
	var hint: String = field["hint_string"]
	match type_of:
		TYPE_OBJECT:
			types.append(class_of)
		TYPE_ARRAY, TYPE_DICTIONARY:
			types = hint.split(";")
	var classes: Array[String] = []
	for type: String in types:
		if script_of(_dart(type)) != null:
			classes.append(_dart(type))
	return classes


static func _has_subclass(dart_class: String) -> bool:
	for known: Dictionary in ProjectSettings.get_global_class_list():
		var base: String = known["base"]
		if base == _godot(dart_class):
			return true
	return false


static func _godot(dart_class: String) -> String:
	return GODOT_CLASSES.get(dart_class, dart_class)


static func _dart(godot_class: String) -> String:
	var dart: Variant = GODOT_CLASSES.find_key(godot_class)
	return godot_class if dart == null else dart
