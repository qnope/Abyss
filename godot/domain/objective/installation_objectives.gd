class_name InstallationObjectives
extends RefCounted
## lib/domain/objective/installation_objectives.dart: the tutorial, the
## first chapter, given one objective at a time.

const _Id := ObjectiveId.Value
const _Type := BuildingType.Value


## `installationObjectives`, a const list in Dart: new objects at each call.
static func installation_objectives() -> Array[Objective]:
	return [
		_step(_Id.HQ_LEVEL_1, BuildingLevelGoal.new(_Type.HEADQUARTERS, 1)),
		_step(_Id.ALGAE_FARM, BuildingLevelGoal.new(_Type.ALGAE_FARM, 1)),
		_step(_Id.MINES, AllOfGoal.new([
			BuildingLevelGoal.new(_Type.CORAL_MINE, 1),
			BuildingLevelGoal.new(_Type.ORE_EXTRACTOR, 1),
		])),
		_step(_Id.SOLAR_PANEL, BuildingLevelGoal.new(_Type.SOLAR_PANEL, 1)),
		_step(_Id.HQ_LEVEL_2, BuildingLevelGoal.new(_Type.HEADQUARTERS, 2)),
		_step(_Id.BARRACKS_AND_SCOUTS, AllOfGoal.new([
			BuildingLevelGoal.new(_Type.BARRACKS, 1),
			UnitCountGoal.new(UnitType.Value.SCOUT, 2),
		])),
		_step(_Id.EXPLORE, ExploredAroundBaseGoal.new()),
		_step(_Id.SOLAR_PANEL_LEVEL_2, BuildingLevelGoal.new(_Type.SOLAR_PANEL, 2)),
		_step(_Id.LABORATORY_AND_RESEARCH, AllOfGoal.new([
			BuildingLevelGoal.new(_Type.LABORATORY, 1),
			ResearchStartedGoal.new(),
		])),
		_step(_Id.FIRST_RAID, RaidsRepelledGoal.new(1)),
	]


## Not in the Dart file, which repeats the chapter and the reward: an
## objective of the tutorial.
static func _step(id: ObjectiveId.Value, goal: ObjectiveGoal) -> Objective:
	return Objective.new(id, ObjectiveChapter.Value.INSTALLATION, ObjectiveRewards.INSTALLATION, goal)
