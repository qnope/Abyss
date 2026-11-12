class_name PortraitFiles
extends RefCounted
## Where the renders of the 3D models are, and what they are called: the one
## place that maps a building, a unit or a monster family to its portrait. A
## portrait is the file `assets/portraits/<name>.png` that
## tool/models/portraits.sh renders from a model that declares one, and its
## name is the lower-case name of the type's enum value (`headquarters`,
## `solar_panel`, `scout`, `swarm`): a model lot adds a model and its
## render, and no code. Without the file the interface shows initials.

const FOLDER := "res://assets/portraits/"


## The portrait name of the building [param type].
static func building(type: BuildingType.Value) -> String:
	return _lower(BuildingType.Value, type)


## The portrait name of the unit [param type].
static func unit(type: UnitType.Value) -> String:
	return _lower(UnitType.Value, type)


## The portrait name of the monster family [param family] (a
## MonsterFamily.Value, as a lair holds it), empty for none.
static func monster(family: Variant) -> String:
	if family == null:
		return ""
	var value: MonsterFamily.Value = family
	return _lower(MonsterFamily.Value, value)


## Every name a portrait may have: what a file of `assets/portraits/` must be
## called (a test holds the folder to it).
static func names() -> Array[String]:
	var all: Array[String] = []
	for type: BuildingType.Value in BuildingType.Value.values():
		all.append(building(type))
	for type: UnitType.Value in UnitType.Value.values():
		all.append(unit(type))
	for family: MonsterFamily.Value in MonsterFamily.Value.values():
		all.append(monster(family))
	return all


## The file of the portrait [param name].
static func path(name_: String) -> String:
	return FOLDER + name_ + ".png"


## The render named [param name_], or null when there is none (no such
## portrait yet, or an empty name).
static func texture(name_: String) -> Texture2D:
	if name_.is_empty() or not ResourceLoader.exists(path(name_)):
		return null
	return load(path(name_)) as Texture2D


static func _lower(values: Dictionary, value: int) -> String:
	var key: String = values.find_key(value)
	return key.to_lower()
