class_name HistoryEntryCategory
extends RefCounted
## lib/domain/history/history_entry_category.dart: what an entry of the
## history tells of, one category per class of entry.

enum Value {
	COMBAT,
	BUILDING,
	RESEARCH,
	RECRUIT,
	EXPLORE,
	COLLECT,
	TURN_END,
	CAPTURE,
	DESCENT,
	REINFORCEMENT,
	RAID,
	VOLCANO,
	EVENT,
	ASSAULT,
}
