class_name ReinforcementEntry
extends HistoryEntry
## lib/domain/history/entries/reinforcement_entry.dart: history entry
## recording a reinforcement dispatch to a deeper level. Without the `title`
## and `subtitle` of the Dart class, which only keep the layout of old saves.

var target_level: int
var unit_count: int


func _init(turn_: int, target_level_: int, unit_count_: int) -> void:
	super(turn_, HistoryEntryCategory.Value.REINFORCEMENT)
	target_level = target_level_
	unit_count = unit_count_
