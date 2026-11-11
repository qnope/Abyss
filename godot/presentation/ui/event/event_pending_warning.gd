class_name EventPendingWarning
extends RefreshingPanel
## The warning before the end of a turn while an event still waits for a
## choice: its prudent option will apply
## (lib/presentation/widgets/event/event_pending_warning.dart). It never
## blocks the turn; `TurnWarnings` adds it when the player has an event
## pending.

const ICON_SIZE := 24.0
const GAP := 8

var type: RandomEventType.Value
var label := Label.new()


func _init(type_: RandomEventType.Value) -> void:
	type = type_
	super()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(UiIcon.glyph(&"auto_awesome", ICON_SIZE, AbyssColors.WARNING))
	row.add_child(label)
	var column := VBoxContainer.new()
	column.add_child(HSeparator.new())
	column.add_child(row)
	add_child(column)
	refresh()


func refresh() -> void:
	label.text = Texts.t(&"eventCardPendingWarning", {"event": RandomEventTexts.label(type)})
