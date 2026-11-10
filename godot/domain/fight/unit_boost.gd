class_name UnitBoost
extends RefCounted
## lib/domain/fight/unit_boost.dart: stat boosts the player's units fight
## with, in percent, granted by the Military research branch.

var atk_percent: int
var def_percent: int
var hp_percent: int


func _init(atk_percent_ := 0, def_percent_ := 0, hp_percent_ := 0) -> void:
	atk_percent = atk_percent_
	def_percent = def_percent_
	hp_percent = hp_percent_


## `UnitBoost.none`, a const object in Dart, which no GDScript constant can
## hold: a boost that changes nothing, built at each call.
static func none() -> UnitBoost:
	return UnitBoost.new()


func atk(stat: int) -> int:
	return _apply(stat, atk_percent)


func def(stat: int) -> int:
	return _apply(stat, def_percent)


func hp(stat: int) -> int:
	return _apply(stat, hp_percent)


static func _apply(stat: int, percent: int) -> int:
	return roundi(DartMath.quotient(stat * (100 + percent), 100))
