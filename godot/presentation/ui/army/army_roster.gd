class_name ArmyRoster
extends RefCounted
## The army as the parade ground shows it: the barracks' level, which unlocks
## the units, how many units of each type serve, and the types that can
## recruit right now (lib/presentation/widgets/army/army_roster.dart). The
## figures a squad stands as are the world's ([SquadSize]).

var barracks_level: int
## Units of each type, wherever they serve; a missing type has none.
var counts: Dictionary[UnitType.Value, int]
## The types the player can recruit at least one of this turn, as a set.
var recruitable: Dictionary[UnitType.Value, bool]
var _units := UnitCostCalculator.new()


func _init(
	barracks_level_: int,
	counts_: Dictionary[UnitType.Value, int] = {},
	recruitable_: Dictionary[UnitType.Value, bool] = {},
) -> void:
	barracks_level = barracks_level_
	counts = counts_
	recruitable = recruitable_


## Units of [param type] serving.
func count_of(type: UnitType.Value) -> int:
	return counts.get(type, 0)


## The barracks level that unlocks [param type].
func unlock_level_of(type: UnitType.Value) -> int:
	return _units.unlock_level(type)


## Whether the barracks is still too low for [param type].
func is_locked(type: UnitType.Value) -> bool:
	return not _units.is_unlocked(type, barracks_level)


## The types the barracks lets recruit.
func unlocked() -> Array[UnitType.Value]:
	var found: Array[UnitType.Value] = []
	for type: UnitType.Value in UnitType.Value.values():
		if not is_locked(type):
			found.append(type)
	return found


## Whether [param type] shows the green plus: unlocked and recruitable now.
func can_recruit(type: UnitType.Value) -> bool:
	return not is_locked(type) and recruitable.has(type)
