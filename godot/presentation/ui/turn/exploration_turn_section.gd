class_name ExplorationTurnSection
extends RefCounted
## The exploration lines of the end-of-turn summary
## (lib/presentation/widgets/turn/exploration_summary_section.dart): the cells
## the scouts revealed in all, then each exploration with its cells and what
## notable it found. A factory for `SummarySections`, not a node: a divider
## then the lines, or nothing when no scout came back.


## The divider and the lines of [param result], none when it had no
## exploration.
static func of(result: TurnResult) -> Array[Control]:
	var found: Array[Control] = []
	if result.explorations.is_empty():
		return found
	var total := 0
	for each in result.explorations:
		total += each.new_cells_revealed
	found.append(HSeparator.new())
	found.append(SummaryLine.new(&"explore", AbyssColors.BIOLUM_CYAN, Texts.t.bind(&"turnExplorationTotal", {"count": total})))
	for each in result.explorations:
		var text := func() -> String: return describe(each)
		found.append(SummaryNoteLine.new(AbyssColors.BIOLUM_CYAN, text))
	return found


## "(x, y) → n cellules", then what notable it found in parentheses.
static func describe(exploration: ExplorationResult) -> String:
	var at := exploration.target
	var line := "(%d, %d) → %s" % [at.x, at.y, Texts.t(&"turnExplorationCells", {"count": exploration.new_cells_revealed})]
	if exploration.notable_content.is_empty():
		return line
	var names := PackedStringArray()
	for content in exploration.notable_content:
		names.append(CellContentTexts.label(content))
	return "%s (%s)" % [line, ", ".join(names)]
