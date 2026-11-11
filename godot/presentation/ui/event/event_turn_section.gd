class_name EventTurnSection
extends RefCounted
## The event lines of the end-of-turn summary: the predators just fought, the
## event settled with its prudent option and the event just drawn
## (lib/presentation/widgets/turn/event_turn_section.dart). A factory for
## `SummarySections`, not a node: a divider then one `SummaryLine` each, or
## nothing when the turn had no event.


## Whether the turn had something to tell about events.
static func has_content(result: TurnResult) -> bool:
	return result.predators != null or result.defaulted_event != null or result.event != null


## The divider and the lines of [param result], none when [method has_content]
## is false.
static func of(result: TurnResult) -> Array[Control]:
	var found: Array[Control] = []
	if not has_content(result):
		return found
	found.append(HSeparator.new())
	if result.predators != null:
		if result.predators.victory:
			found.append(SummaryLine.new(&"shield", AbyssColors.SUCCESS, Texts.t.bind(&"historyPredatorsRepelled")))
		else:
			found.append(SummaryLine.new(&"dangerous", AbyssColors.ERROR, Texts.t.bind(&"turnPredatorsLooted")))
	if result.defaulted_event != null:
		found.append(_line(&"turnEventDefaulted", AbyssColors.WARNING, result.defaulted_event))
	if result.event != null:
		found.append(_line(&"turnEventDrawn", AbyssColors.BIOLUM_CYAN, result.event))
	return found


static func _line(key: StringName, color: Color, event: Variant) -> SummaryLine:
	var type: RandomEventType.Value = event
	var text := func() -> String: return Texts.t(key, {"event": RandomEventTexts.label(type)})
	return SummaryLine.new(&"auto_awesome", color, text)
