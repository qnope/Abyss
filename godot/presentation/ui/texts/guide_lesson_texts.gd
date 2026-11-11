class_name GuideLessonTexts
extends RefCounted
## lib/presentation/extensions/guide_message_extensions.dart
## (GuideLessonText): the lessons of the tutorial objectives, which the guide
## gives while the player is on one. The objectives it does not follow have
## none.

const Id := ObjectiveId.Value

## The lesson of each objective the guide follows.
const KEYS: Dictionary[ObjectiveId.Value, StringName] = {
	Id.HQ_LEVEL_1: &"guideLessonHqLevel1",
	Id.ALGAE_FARM: &"guideLessonAlgaeFarm",
	Id.MINES: &"guideLessonMines",
	Id.SOLAR_PANEL: &"guideLessonSolarPanel",
	Id.SOLAR_PANEL_LEVEL_2: &"guideLessonSolarPanelLevel2",
	Id.HQ_LEVEL_2: &"guideLessonHqLevel2",
	Id.BARRACKS_AND_SCOUTS: &"guideLessonBarracksAndScouts",
	Id.EXPLORE: &"guideLessonExplore",
	Id.LABORATORY_AND_RESEARCH: &"guideLessonLaboratoryAndResearch",
	Id.FIRST_RAID: &"guideLessonFirstRaid",
	Id.DESCENT_MODULE: &"guideLessonDescentModule",
	Id.DESCEND_LEVEL_2: &"guideLessonDescendLevel2",
	Id.HQ_LEVEL_8: &"guideLessonHqLevel8",
	Id.PRESSURE_CAPSULE: &"guideLessonPressureCapsule",
	Id.DESCEND_LEVEL_3: &"guideLessonDescendLevel3",
	Id.HQ_LEVEL_10: &"guideLessonHqLevel10",
	Id.KERNEL_LEVEL_1: &"guideLessonKernelLevel1",
}


## `objective.lesson(l10n)`: the lesson on [param id], empty for an objective
## the guide does not follow (Dart's null).
static func lesson(id: ObjectiveId.Value) -> String:
	if not KEYS.has(id):
		return ""
	return Texts.t(KEYS[id], _args(id))


## The figures a lesson names.
static func _args(id: ObjectiveId.Value) -> Dictionary:
	var figure := ObjectiveTexts.figure(ObjectiveCatalog.by_id(id))
	match id:
		Id.HQ_LEVEL_2:
			return {"level": figure}
		Id.BARRACKS_AND_SCOUTS:
			return {"count": figure}
		Id.FIRST_RAID:
			return {"turns": NoiseRules.WARNING_TURNS}
	return {}
