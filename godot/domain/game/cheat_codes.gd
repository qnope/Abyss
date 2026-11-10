class_name CheatCodes
extends RefCounted
## lib/domain/game/cheat_codes.dart: the name that fills a base, to try the
## later stages of the game.

const _LEVELS: Dictionary[BuildingType.Value, int] = {
	BuildingType.Value.HEADQUARTERS: 7,
	BuildingType.Value.ALGAE_FARM: 3,
	BuildingType.Value.CORAL_MINE: 3,
	BuildingType.Value.ORE_EXTRACTOR: 3,
	BuildingType.Value.SOLAR_PANEL: 3,
	BuildingType.Value.LABORATORY: 3,
	BuildingType.Value.BARRACKS: 3,
}
const _UNITS: Dictionary[UnitType.Value, int] = {
	UnitType.Value.SCOUT: 200,
	UnitType.Value.HARPOONIST: 200,
	UnitType.Value.ABYSS_ADMIRAL: 10,
}


static func apply(player: Player) -> void:
	if player.name != "qnope":
		return
	for resource: GameResource in player.resources.values():
		resource.amount = 5000
	for type: BuildingType.Value in _LEVELS:
		if player.buildings.has(type):
			player.buildings[type].level = _LEVELS[type]
	for branch: TechBranch.Value in TechBranch.Value.values():
		var state: TechBranchState = player.tech_branches.get(branch)
		if state == null:
			continue
		state.unlocked = true
		state.research_level = 3
	var units := player.units_on_level(1)
	for type: UnitType.Value in _UNITS:
		if units.has(type):
			units[type].count = _UNITS[type]
