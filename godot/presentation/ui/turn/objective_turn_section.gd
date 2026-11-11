class_name ObjectiveTurnSection
extends RefCounted
## The objective lines of the end-of-turn summary
## (lib/presentation/widgets/turn/objective_turn_section.dart): each objective
## completed with the reward it credited, then each temporary objective ended,
## done or struck through when missed. A factory for `SummarySections`, not a
## node: a divider then one line each, or nothing when the turn had none.


## Whether the turn completed or ended an objective.
static func has_content(result: TurnResult) -> bool:
	return not result.objectives.is_empty() or not result.temporary_objectives.is_empty()


## The divider and the lines of [param result], none when [method has_content]
## is false.
static func of(result: TurnResult) -> Array[Control]:
	var found: Array[Control] = []
	if not has_content(result):
		return found
	found.append(HSeparator.new())
	for completion in result.objectives:
		var text := func() -> String: return _completed(completion)
		found.append(SummaryLine.new(&"flag", AbyssColors.SUCCESS, text))
	for ended in result.temporary_objectives:
		if ended.is_done():
			var title := func() -> String:
				return Texts.t(&"objectiveCompleted", {"title": TemporaryObjectiveTexts.display_title(ended.objective)})
			found.append(SummaryLine.new(&"flag", AbyssColors.SUCCESS, title))
		else:
			found.append(MissedObjectiveLine.new(ended.objective))
	return found


static func _completed(completion: ObjectiveCompletion) -> String:
	var gains := ResourceTexts.gain_label(completion.credited)
	var title := Texts.t(&"objectiveCompleted", {"title": ObjectiveTexts.display_title(completion.objective)})
	return title if gains.is_empty() else "%s (%s)" % [title, gains]
