class_name ObjectiveTexts
extends RefCounted
## lib/presentation/extensions/objective_extensions.dart (ObjectiveDisplay):
## what the player is asked to do, with the level or the count its goal names.

## The objectives whose title is one sentence.
const PLAIN: Dictionary[ObjectiveId.Value, StringName] = {
	ObjectiveId.Value.ALGAE_FARM: &"objectiveAlgaeFarm",
	ObjectiveId.Value.MINES: &"objectiveMines",
	ObjectiveId.Value.SOLAR_PANEL: &"objectiveSolarPanel",
	ObjectiveId.Value.SOLAR_PANEL_LEVEL_2: &"objectiveSolarPanelLevel2",
	ObjectiveId.Value.EXPLORE: &"objectiveExplore",
	ObjectiveId.Value.LABORATORY_AND_RESEARCH: &"objectiveLaboratoryAndResearch",
	ObjectiveId.Value.FIRST_RAID: &"objectiveFirstRaid",
	ObjectiveId.Value.TAKE_LAIR: &"objectiveTakeLair",
	ObjectiveId.Value.CORAL_CITADEL: &"objectiveCoralCitadel",
	ObjectiveId.Value.TAKE_FAILLE: &"objectiveTakeFaille",
	ObjectiveId.Value.DESCENT_MODULE: &"objectiveDescentModule",
	ObjectiveId.Value.TAKE_CHEMINEE: &"objectiveTakeCheminee",
	ObjectiveId.Value.PRESSURE_CAPSULE: &"objectivePressureCapsule",
	ObjectiveId.Value.TAKE_KERNEL: &"objectiveTakeKernel",
}
## The ones that name a level, with their sentence.
const WITH_LEVEL: Dictionary[ObjectiveId.Value, StringName] = {
	ObjectiveId.Value.HQ_LEVEL_1: &"objectiveRaiseHq",
	ObjectiveId.Value.HQ_LEVEL_2: &"objectiveRaiseHq",
	ObjectiveId.Value.HQ_LEVEL_5: &"objectiveRaiseHq",
	ObjectiveId.Value.HQ_LEVEL_8: &"objectiveRaiseHq",
	ObjectiveId.Value.HQ_LEVEL_10: &"objectiveRaiseHq",
	ObjectiveId.Value.DESCEND_LEVEL_2: &"objectiveDescend",
	ObjectiveId.Value.DESCEND_LEVEL_3: &"objectiveDescend",
	ObjectiveId.Value.KERNEL_LEVEL_1: &"objectiveRaiseKernel",
	ObjectiveId.Value.KERNEL_LEVEL_5: &"objectiveRaiseKernel",
	ObjectiveId.Value.KERNEL_LEVEL_10: &"objectiveRaiseKernel",
}


## `objective.displayTitle(l10n)`: "Monte le QG au niveau 5".
static func display_title(objective: Objective) -> String:
	if PLAIN.has(objective.id):
		return Texts.t(PLAIN[objective.id])
	if WITH_LEVEL.has(objective.id):
		return Texts.t(WITH_LEVEL[objective.id], {"level": figure(objective)})
	return Texts.t(&"objectiveBarracksAndScouts", {"count": figure(objective)})


## `objective.figure`: the number the goal names: the level to reach, or the
## units or raids to count; a goal made of several names its last one's.
static func figure(objective: Objective) -> int:
	return _figure_of(objective.goal)


static func _figure_of(goal: ObjectiveGoal) -> int:
	if goal is BuildingLevelGoal:
		return (goal as BuildingLevelGoal).level
	if goal is LevelReachedGoal:
		return (goal as LevelReachedGoal).level
	if goal is UnitCountGoal:
		return (goal as UnitCountGoal).count
	if goal is RaidsRepelledGoal:
		return (goal as RaidsRepelledGoal).count
	if goal is AllOfGoal:
		var last: ObjectiveGoal = (goal as AllOfGoal).goals.back()
		return _figure_of(last)
	return 1
