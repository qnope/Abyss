class_name RecruitEntry
extends HistoryEntry
## lib/domain/history/entries/recruit_entry.dart: history entry recording the
## recruitment of a batch of units. Without the `title` and `subtitle` of
## the Dart class, which only keep the layout of old saves.

var unit_type: UnitType.Value
var quantity: int


func _init(turn_: int, unit_type_: UnitType.Value, quantity_: int) -> void:
	super(turn_, HistoryEntryCategory.Value.RECRUIT)
	unit_type = unit_type_
	quantity = quantity_
