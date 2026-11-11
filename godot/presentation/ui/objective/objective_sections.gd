class_name ObjectiveSections
extends RefCounted
## What the objectives sheet lists (lib/.../objectives_sheet.dart): the
## temporary objectives of the events, then the six chapters in order, each
## objective done, current or to do. Only the current objective has its
## progress computed. A factory of controls, not a node.


## The headers and rows for the human player of [param game], top to bottom.
static func of(game: Game) -> Array[Control]:
	var player := game.human_player()
	var state := ObjectiveMigration.state_of(game, player)
	var current := CurrentObjective.of(game, player)
	var found: Array[Control] = []
	var temporary := TemporaryObjectives.active_of(game, player)
	if not temporary.is_empty():
		found.append(ObjectiveSectionHeader.new(Texts.t(&"objectiveEventHeader")))
		for objective in temporary:
			found.append(ObjectiveRow.new(TemporaryObjectiveTexts.display_title(objective),
				ObjectiveStatus.Value.TEMPORARY))
	for chapter: ObjectiveChapter.Value in ObjectiveChapter.Value.values():
		found.append(ObjectiveSectionHeader.new(ChapterTexts.numbered_title(chapter), ChapterTexts.lore(chapter)))
		for objective in ObjectiveCatalog.of_chapter(chapter):
			found.append(_row(game, objective, state, current))
	return found


static func _row(game: Game, objective: Objective, state: ObjectiveState, current: Objective) -> ObjectiveRow:
	var is_current := current != null and objective.id == current.id
	var status := ObjectiveStatus.Value.TO_DO
	if state.is_completed(objective.id):
		status = ObjectiveStatus.Value.DONE
	elif is_current:
		status = ObjectiveStatus.Value.CURRENT
	var progress := objective.progress_of(game, game.human_player()) if is_current else null
	return ObjectiveRow.new(ObjectiveTexts.display_title(objective), status, progress, objective.reward)
