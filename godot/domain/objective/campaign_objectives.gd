class_name CampaignObjectives
extends RefCounted
## lib/domain/objective/campaign_objectives.dart: the chapters after the
## tutorial, up to the victory.

const _Id := ObjectiveId.Value
const _Chapter := ObjectiveChapter.Value
const _HQ := BuildingType.Value.HEADQUARTERS
const _KERNEL := BuildingType.Value.VOLCANIC_KERNEL


## `campaignObjectives`, a final list in Dart: new objects at each call.
static func campaign_objectives() -> Array[Objective]:
	return [
		_step(_Id.TAKE_LAIR, _Chapter.REEF, LairTakenGoal.new()),
		_step(_Id.HQ_LEVEL_5, _Chapter.REEF, BuildingLevelGoal.new(_HQ, 5)),
		_step(_Id.CORAL_CITADEL, _Chapter.REEF, BuildingLevelGoal.new(BuildingType.Value.CORAL_CITADEL, 1)),
		_step(_Id.TAKE_FAILLE, _Chapter.RIFT, TransitionBaseCapturedGoal.new(TransitionBaseType.Value.FAILLE)),
		_step(_Id.DESCENT_MODULE, _Chapter.RIFT, BuildingLevelGoal.new(BuildingType.Value.DESCENT_MODULE, 1)),
		_step(_Id.DESCEND_LEVEL_2, _Chapter.RIFT, LevelReachedGoal.new(2)),
		_step(_Id.HQ_LEVEL_8, _Chapter.CHIMNEY, BuildingLevelGoal.new(_HQ, 8)),
		_step(_Id.TAKE_CHEMINEE, _Chapter.CHIMNEY, TransitionBaseCapturedGoal.new(TransitionBaseType.Value.CHEMINEE)),
		_step(_Id.PRESSURE_CAPSULE, _Chapter.CHIMNEY, BuildingLevelGoal.new(BuildingType.Value.PRESSURE_CAPSULE, 1)),
		_step(_Id.DESCEND_LEVEL_3, _Chapter.CHIMNEY, LevelReachedGoal.new(3)),
		_step(_Id.HQ_LEVEL_10, _Chapter.KERNEL, BuildingLevelGoal.new(_HQ, 10)),
		_step(_Id.TAKE_KERNEL, _Chapter.KERNEL, KernelCapturedGoal.new()),
		_step(_Id.KERNEL_LEVEL_1, _Chapter.KERNEL, BuildingLevelGoal.new(_KERNEL, 1)),
		_step(_Id.KERNEL_LEVEL_5, _Chapter.AWAKENING, BuildingLevelGoal.new(_KERNEL, 5)),
		_step(
			_Id.KERNEL_LEVEL_10, _Chapter.AWAKENING, BuildingLevelGoal.new(_KERNEL, 10),
			ObjectiveRewards.VICTORY,
		),
	]


## An objective of `chapter` paying the ObjectiveRewards of its chapter,
## unless `reward` (a `Dictionary[ResourceType.Value, int]`) is given.
static func _step(
	id: ObjectiveId.Value, chapter: ObjectiveChapter.Value, goal: ObjectiveGoal, reward: Variant = null,
) -> Objective:
	var paid: Dictionary[ResourceType.Value, int] = (
		reward if reward != null else ObjectiveRewards.of_chapter(chapter)
	)
	return Objective.new(id, chapter, paid, goal)
