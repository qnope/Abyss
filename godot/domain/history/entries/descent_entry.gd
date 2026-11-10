class_name DescentEntry
extends HistoryEntry
## lib/domain/history/entries/descent_entry.dart: history entry recording a
## descent to a deeper level. Without the `title` and `subtitle` of the Dart
## class, which only keep the layout of old saves.

var target_level: int
var unit_count: int


func _init(turn_: int, target_level_: int, unit_count_: int) -> void:
	super(turn_, HistoryEntryCategory.Value.DESCENT)
	target_level = target_level_
	unit_count = unit_count_
