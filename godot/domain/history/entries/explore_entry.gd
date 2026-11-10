class_name ExploreEntry
extends HistoryEntry
## lib/domain/history/entries/explore_entry.dart: history entry recording an
## exploration order at a grid coordinate. Without the `title` and
## `subtitle` of the Dart class, which only keep the layout of old saves.

var target_x: int
var target_y: int


func _init(turn_: int, target_x_: int, target_y_: int) -> void:
	super(turn_, HistoryEntryCategory.Value.EXPLORE)
	target_x = target_x_
	target_y = target_y_
