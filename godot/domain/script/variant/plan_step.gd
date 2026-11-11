class_name PlanStep
extends RefCounted
## lib/domain/script/variant/plan_step.dart: one action of an exported
## replay, as the human played it, waiting to be played again by a
## `PlanScript`.

## Steps that move the game towards the volcano: a player keeps to them
## until they succeed, whatever the variant's patience.
const _ROAD: Array[String] = ["attackBase", "attackKernel", "descend"]
## Units no variant scales: scouts only explore, one admiral leads.
const _FIXED: Array[String] = ["scout", "abyssAdmiral"]

## Turn the step is due on in this variant.
var turn: int
## Rank of the step in the original game, which keeps the order of the
## actions of a turn.
var rank: int
## The action as the replay wrote it (`{"do": "recruit", ...}`).
var json: Dictionary


func _init(turn_: int, rank_: int, json_: Dictionary) -> void:
	turn = turn_
	rank = rank_
	json = json_


func verb() -> String:
	return json["do"]


func level() -> int:
	return json.get("level", 1)


## Whether the step moves the game towards the volcano.
func persistent() -> bool:
	return _ROAD.has(verb())


## Whether the step aims at a cell of the map.
func on_map() -> bool:
	return json.has("x")


## The action adapted to `variant` (a Dictionary): recruits of fighters
## scaled, unit selections cut to `available` on the step's level, and the
## replay's dice dropped unless the variant keeps them. A descent keeps its
## seed on the same map, since it draws the level below. Null when nothing
## is left to send.
func adapt(variant: ReplayVariant, available: Dictionary[UnitType.Value, int]) -> Variant:
	var out := json.duplicate()
	var draws_map := verb() == "descend" and variant.same_map
	if not variant.same_dice and not draws_map or not variant.same_map:
		out.erase("seed")
	if verb() == "recruit":
		var count: int = json["count"]
		out["count"] = count if _FIXED.has(json["unit"]) else clampi(roundi(count * variant.army), 1, count * 4)
	if json.get("units") is Dictionary:
		var units: Dictionary = json["units"]
		var cut := {}
		for key: Variant in units:
			var type: Variant = DartEnum.by_name(UnitType.Value, str(key))
			var have: int = available.get(type, 0) if type != null else 0
			var wanted: int = units[key]
			var n := wanted if wanted < have else have
			if n > 0:
				cut[str(key)] = n
		if cut.is_empty():
			return null
		out["units"] = cut
	return out
