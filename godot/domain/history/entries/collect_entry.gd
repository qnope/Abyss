class_name CollectEntry
extends HistoryEntry
## lib/domain/history/entries/collect_entry.dart: history entry recording a
## treasure collection at a grid coordinate. Without the `title` and
## `subtitle` of the Dart class, which only keep the layout of old saves.

var target_x: int
var target_y: int
var gains: Dictionary[ResourceType.Value, int]


func _init(
	turn_: int, target_x_: int, target_y_: int, gains_: Dictionary[ResourceType.Value, int]
) -> void:
	super(turn_, HistoryEntryCategory.Value.COLLECT)
	target_x = target_x_
	target_y = target_y_
	gains = gains_
