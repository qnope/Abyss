class_name SummarySections
extends RefCounted
## The sections of the end-of-turn summary, in order
## (lib/presentation/widgets/turn/turn_summary_dialog.dart): what each resource
## made and spent, the buildings shut down, the units lost, and the recruitment
## now open. A section is a Control, or nothing when the turn has nothing to
## tell about it; a lot that owns a section adds a line to [method of], at the
## place Flutter puts it:
##
## - after the losses, the raid, the attacks of the factions ([AttackSections])
##   and the kraken wave ([ThreatSections]), then the event lines
##   ([EventTurnSection]);
## - to come, around them: the exploration summary (lot 9) before the raid and
##   the objectives completed (lot 15) after the wave.


## The sections of [param result], top to bottom.
static func of(result: TurnResult) -> Array[Control]:
	var found: Array[Control] = []
	for change in result.changes:
		found.append(ResourceChangeLine.new(change.type, change.produced, change.consumed, change.was_capped))
	if not result.deactivated_buildings.is_empty():
		found.append(TurnLosses.deactivated(result.deactivated_buildings))
	if not result.lost_units.is_empty():
		found.append(TurnLosses.lost_units(result.lost_units))
	found.append_array(ThreatSections.raid(result))
	found.append_array(AttackSections.of(result))
	found.append_array(ThreatSections.volcano(result))
	found.append_array(EventTurnSection.of(result))
	if result.had_recruited_units:
		if not found.is_empty():
			found.append(HSeparator.new())
		found.append(SummaryLine.new(&"shield", AbyssColors.SUCCESS, Texts.t.bind(&"turnRecruitAvailable")))
	return found
