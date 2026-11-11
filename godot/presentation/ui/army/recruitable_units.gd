class_name RecruitableUnits
extends RefCounted
## The unit types a player can recruit at least one of right now, by the rules
## of the unit's sheet (game_screen_army_tab.dart: recruitableUnitsOf):
## unlocked by the barracks, not recruited yet this turn, and paid for at the
## barracks' price (doubled while it is degraded).


## The types [param player] can recruit at least one of, as a set.
static func of(player: Player) -> Dictionary[UnitType.Value, bool]:
	var units := UnitCostCalculator.new()
	var level := Building.level_in(player.buildings, BuildingType.Value.BARRACKS)
	var degraded := player.is_degraded(BuildingType.Value.BARRACKS)
	var found: Dictionary[UnitType.Value, bool] = {}
	for type: UnitType.Value in UnitType.Value.values():
		if units.is_unlocked(type, level) and not player.recruited_unit_types.has(type) \
				and units.max_recruitable_count(type, level, player.resources, degraded) >= 1:
			found[type] = true
	return found
