class_name TransitionBaseName
extends RefCounted
## lib/domain/map/transition_base_name.dart: which transition base of its
## `type` a base is. The presentation words it in the player's language
## ("Faille Alpha", "Alpha Rift"...).
##
## Saves store it as its `code()`. Older saves stored the French name
## itself: `parse` reads both. A set of names is keyed by their code.

## How many bases of each type a map holds.
const _COUNTS: Dictionary[TransitionBaseType.Value, int] = {
	TransitionBaseType.Value.FAILLE: 4,
	TransitionBaseType.Value.CHEMINEE: 3,
}
## The French names of older saves, by the code of the name each stands for.
const _LEGACY: Dictionary[String, String] = {
	"Faille Alpha": "faille:0",
	"Faille Beta": "faille:1",
	"Faille Gamma": "faille:2",
	"Faille Delta": "faille:3",
	"Cheminee Primaire": "cheminee:0",
	"Cheminee Secondaire": "cheminee:1",
	"Cheminee Tertiaire": "cheminee:2",
}

var type: TransitionBaseType.Value
## Order among the bases of `type`: 0 for Alpha or the primary vent.
var rank: int


func _init(type_: TransitionBaseType.Value, rank_: int) -> void:
	type = type_
	rank = rank_


## How many bases of each type a map holds.
static func count_of(type_: TransitionBaseType.Value) -> int:
	return _COUNTS[type_]


## Every name of `type_`, by rank, with `extra` more for a larger map.
static func all_of(type_: TransitionBaseType.Value, extra := 0) -> Array[TransitionBaseName]:
	var names: Array[TransitionBaseName] = []
	for rank_: int in count_of(type_) + extra:
		names.append(TransitionBaseName.new(type_, rank_))
	return names


## The level its passage opens onto.
func target_level() -> int:
	return 2 if type == TransitionBaseType.Value.FAILLE else 3


## What a save stores, such as `faille:0`.
func code() -> String:
	return "%s:%d" % [DartEnum.name_of(TransitionBaseType.Value, type), rank]


## The name a save `stored`, as a code or as an older French name; null for
## any other text.
static func parse(stored: String) -> TransitionBaseName:
	var code_: String = _LEGACY.get(stored, stored)
	return _from_code(code_)


static func _from_code(code_: String) -> TransitionBaseName:
	var parts := code_.split(":")
	if parts.size() != 2:
		return null
	var read_rank: Variant = DartInt.try_parse(parts[1])
	var named_type: Variant = DartEnum.by_name(TransitionBaseType.Value, parts[0])
	if named_type == null or read_rank == null:
		return null
	var type_: TransitionBaseType.Value = named_type
	var rank_: int = read_rank
	return TransitionBaseName.new(type_, rank_)


## `operator ==`: another name of the same type and rank.
func equals(other: Variant) -> bool:
	if not other is TransitionBaseName:
		return false
	var name: TransitionBaseName = other
	return name.type == type and name.rank == rank


func _to_string() -> String:
	return code()
