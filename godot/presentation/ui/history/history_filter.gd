class_name HistoryFilter
extends RefCounted
## The filters of the history sheet (lib/presentation/widgets/history/
## history_filter.dart): `COMBAT`, `BUILDING` and `RESEARCH` map to the
## categories of their names (combat also keeps the raids, the kraken waves
## and the assaults on bases); `EVENT` keeps the random events and the
## predators fought like a raid; `OTHER` groups the lower-volume categories
## into a single bucket.

enum Value { ALL, COMBAT, BUILDING, RESEARCH, EVENT, OTHER }

const _CATEGORIES: Dictionary[Value, Array] = {
	Value.COMBAT: [HistoryEntryCategory.Value.COMBAT, HistoryEntryCategory.Value.RAID,
		HistoryEntryCategory.Value.VOLCANO, HistoryEntryCategory.Value.ASSAULT],
	Value.BUILDING: [HistoryEntryCategory.Value.BUILDING],
	Value.RESEARCH: [HistoryEntryCategory.Value.RESEARCH],
	Value.EVENT: [HistoryEntryCategory.Value.EVENT],
	Value.OTHER: [HistoryEntryCategory.Value.RECRUIT, HistoryEntryCategory.Value.EXPLORE,
		HistoryEntryCategory.Value.COLLECT, HistoryEntryCategory.Value.TURN_END,
		HistoryEntryCategory.Value.CAPTURE, HistoryEntryCategory.Value.DESCENT,
		HistoryEntryCategory.Value.REINFORCEMENT],
}


## `HistoryFilterLabel.label`: the name of [param filter] in the language on.
static func label(filter: Value) -> String:
	return Texts.t(TextKeys.of("historyFilter", Value, filter))


## `applyHistoryFilter`: [param entries] kept by [param filter], in their order.
static func apply(entries: Array[HistoryEntry], filter: Value) -> Array[HistoryEntry]:
	if filter == Value.ALL:
		return entries
	var kept: Array[HistoryEntry] = []
	for entry in entries:
		if _keeps(filter, entry):
			kept.append(entry)
	return kept


static func _keeps(filter: Value, entry: HistoryEntry) -> bool:
	if _CATEGORIES[filter].has(entry.category):
		return true
	return filter == Value.EVENT and entry is RaidEntry and (entry as RaidEntry).surprise
