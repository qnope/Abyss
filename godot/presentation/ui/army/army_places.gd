class_name ArmyPlaces
extends RefCounted
## Where the army serves: the units of each type at each place, a level of the
## map (1 to 3) or the kernel's stock ([constant KernelGarrison.STOCK_KEY]), as
## the player keeps them (lib/presentation/widgets/army/army_places.dart). A
## place is named by its key, the whole army by [constant ALL].

## The whole army, every place together (no level is 0).
const ALL := 0

## Units of each type at each place: a place's `{UnitType.Value: int}`; a
## missing type has none there.
var units: Dictionary[int, Dictionary]


func _init(units_: Dictionary[int, Dictionary] = {}) -> void:
	units = units_


## Where [param player] has its units: every level of the map and the kernel's
## garrison (game_screen_army_tab.dart: armyPlacesOf).
static func of(player: Player) -> ArmyPlaces:
	var found: Dictionary[int, Dictionary] = {}
	for place: int in player.units_per_level:
		var here: Dictionary[UnitType.Value, int] = {}
		for type: UnitType.Value in player.units_per_level[place]:
			var unit: Unit = player.units_per_level[place][type]
			here[type] = unit.count
		found[place] = here
	return ArmyPlaces.new(found)


## The places holding at least one unit, in the order of their keys: the levels
## from the top down, then the kernel.
func held() -> Array[int]:
	var keys: Array[int] = []
	for place: int in units:
		if total_at(place) > 0:
			keys.append(place)
	keys.sort()
	return keys


## Whether the army serves in more than one place.
func is_split() -> bool:
	return held().size() > 1


## Units of each type at [param place], every place for [constant ALL]; the
## types with none left out.
func counts_at(place: int) -> Dictionary[UnitType.Value, int]:
	var counts: Dictionary[UnitType.Value, int] = {}
	for at: int in units:
		if place != ALL and at != place:
			continue
		for type: UnitType.Value in units[at]:
			var count: int = units[at][type]
			if count > 0:
				counts[type] = counts.get(type, 0) + count
	return counts


## Units of [param type] at [param place], every place for [constant ALL].
func count_of(type: UnitType.Value, place: int) -> int:
	return counts_at(place).get(type, 0)


## Units of every type at [param place], every place for [constant ALL].
func total_at(place: int) -> int:
	var total := 0
	for count: int in counts_at(place).values():
		total += count
	return total
