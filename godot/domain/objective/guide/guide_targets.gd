class_name GuideTargets
extends RefCounted
## lib/domain/objective/guide/guide_targets.dart: where the halo of the
## guide points for each objective of the tutorial, step by step: the
## building to raise, then the unit to recruit or the research to start.

const _Id := ObjectiveId.Value
const _Type := BuildingType.Value


## What `player` should touch next towards the tutorial objective `id`,
## null past the tutorial.
static func of(player: Player, id: ObjectiveId.Value) -> GuideTarget:
	match id:
		_Id.HQ_LEVEL_1, _Id.HQ_LEVEL_2:
			return GuideTarget.for_building(_Type.HEADQUARTERS)
		_Id.ALGAE_FARM:
			return GuideTarget.for_building(_Type.ALGAE_FARM)
		_Id.MINES:
			var mine_built := _built(player, _Type.CORAL_MINE)
			return GuideTarget.for_building(_Type.ORE_EXTRACTOR if mine_built else _Type.CORAL_MINE)
		_Id.SOLAR_PANEL, _Id.SOLAR_PANEL_LEVEL_2:
			return GuideTarget.for_building(_Type.SOLAR_PANEL)
		_Id.BARRACKS_AND_SCOUTS:
			if _built(player, _Type.BARRACKS):
				return GuideTarget.for_unit(UnitType.Value.SCOUT)
			return GuideTarget.for_building(_Type.BARRACKS)
		_Id.EXPLORE:
			return GuideTarget.for_map()
		_Id.LABORATORY_AND_RESEARCH:
			return _research(player)
		_Id.FIRST_RAID:
			return GuideTarget.for_unit(UnitType.Value.HARPOONIST)
	# `_ => null`, the last case.
	return null


static func _built(player: Player, type: BuildingType.Value) -> bool:
	return Building.level_in(player.buildings, type) > 0


## The laboratory, then the medallions to unlock a branch, then the first
## node of the branches unlocked.
static func _research(player: Player) -> GuideTarget:
	if not _built(player, _Type.LABORATORY):
		return GuideTarget.for_building(_Type.LABORATORY)
	var unlocked: Dictionary[TechBranch.Value, bool] = {}
	for branch: TechBranch.Value in player.tech_branches:
		if player.tech_branches[branch].unlocked:
			unlocked[branch] = true
	if not unlocked.is_empty():
		return GuideTarget.for_research(unlocked)
	var every: Dictionary[TechBranch.Value, bool] = {}
	for branch: TechBranch.Value in TechBranch.Value.values():
		every[branch] = true
	return GuideTarget.for_unlock(every)
