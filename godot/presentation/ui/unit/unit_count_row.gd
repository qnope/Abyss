class_name UnitCountRow
extends RefreshingPanel
## One line of an army that is only read: the unit's picture and how many of
## the type there are, "3 éclaireurs" (lib/presentation/widgets/unit/
## unit_count_row.dart).

const PORTRAIT_SIZE := 36.0
const GAP := 12

var type: UnitType.Value
var count: int
var label := Label.new()


func _init(type_: UnitType.Value, count_: int) -> void:
	super()
	type = type_
	count = count_
	label.theme_type_variation = &"TitleMedium"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(UnitPortrait.of(type, PORTRAIT_SIZE))
	row.add_child(label)
	add_child(row)
	refresh()


func refresh() -> void:
	label.text = UnitTexts.units(type, count)
