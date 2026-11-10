class_name BuildingEntry
extends HistoryEntry
## lib/domain/history/entries/building_entry.dart: history entry recording a
## building construction or upgrade. Without the `title` and `subtitle` of
## the Dart class, which only keep the layout of old saves.

var building_type: BuildingType.Value
var new_level: int


func _init(turn_: int, building_type_: BuildingType.Value, new_level_: int) -> void:
	super(turn_, HistoryEntryCategory.Value.BUILDING)
	building_type = building_type_
	new_level = new_level_
