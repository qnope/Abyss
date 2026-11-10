class_name UnitStats
extends RefCounted
## lib/domain/unit/unit_stats.dart: the health, attack and defence of a unit.

var hp: int
var atk: int
var def: int


func _init(hp_: int, atk_: int, def_: int) -> void:
	hp = hp_
	atk = atk_
	def = def_


static func for_type(type: UnitType.Value) -> UnitStats:
	match type:
		UnitType.Value.SCOUT: return UnitStats.new(10, 2, 1)
		UnitType.Value.HARPOONIST: return UnitStats.new(15, 5, 2)
		UnitType.Value.GUARDIAN: return UnitStats.new(25, 2, 6)
		UnitType.Value.DOME_BREAKER: return UnitStats.new(20, 8, 3)
		UnitType.Value.ABYSS_ADMIRAL: return UnitStats.new(100, 0, 0)
	# saboteur, the last unit.
	return UnitStats.new(8, 10, 1)
