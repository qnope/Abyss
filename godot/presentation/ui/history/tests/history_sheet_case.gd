class_name HistorySheetCase
extends UiTestCase
## What the tests of the history sheet share: a hook for the reports, sample
## entries and the sheet over the window or the modals.


## A hook for the reports: opens a plain page for the combats, as the lot that
## builds the fight summary will.
class FakeReports:
	extends HistoryReports

	var asked: Array[HistoryEntry] = []
	var page: ModalPanel

	func page_for(entry: HistoryEntry) -> ModalPanel:
		asked.append(entry)
		return page if entry is CombatEntry else null


func _entries() -> Array[HistoryEntry]:
	return [
		BuildingEntry.new(1, BuildingType.Value.ALGAE_FARM, 2),
		ResearchEntry.new(2, TechBranch.Value.MILITARY, false, 1),
		HistorySamples.combat_entry(true),
	]


## The sheet of [param entries] (the sample ones when none), on the window or,
## when [param on_modals], opened on the modals.
func _sheet(entries: Array[HistoryEntry] = [], reports := HistoryReports.new(), on_modals := false) -> HistorySheet:
	var sheet := HistorySheet.new(entries if not entries.is_empty() else _entries(), modals(), reports)
	if on_modals:
		modals().open(sheet)
		return sheet
	return mount(sheet) as HistorySheet


func _turns(sheet: HistorySheet) -> Array[int]:
	var turns: Array[int] = []
	for card in sheet.cards:
		turns.append(card.entry.turn)
	return turns
