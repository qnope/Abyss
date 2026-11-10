class_name TurnEndEntry
extends HistoryEntry
## lib/domain/history/entries/turn_end_entry.dart: history entry recording
## the resolution of a turn: the production recap of each resource, the
## buildings deactivated for want of upkeep, and the units lost to
## starvation. Without the `title` and `subtitle` of the Dart class, which
## only keep the layout of old saves.

var changes: Array[TurnResourceChange]
var deactivated_buildings: Array[BuildingType.Value]
var lost_units: Dictionary[UnitType.Value, int]


func _init(
	turn_: int,
	changes_: Array[TurnResourceChange],
	deactivated_buildings_: Array[BuildingType.Value],
	lost_units_: Dictionary[UnitType.Value, int],
) -> void:
	super(turn_, HistoryEntryCategory.Value.TURN_END)
	changes = changes_
	deactivated_buildings = deactivated_buildings_
	lost_units = lost_units_
