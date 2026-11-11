class_name ThreatStrip
extends RefreshingPanel
## The thin strip under the resource bar that a threat draws on surface dim,
## the rows of [member column] stacked in it (the Container of
## lib/presentation/widgets/raid/raid_status_bar.dart and its neighbours). A
## strip that has nothing to tell hides itself, and the stack of
## [GameStatusBars] closes up over it.

const PADDING := Vector2i(12, 6)
const ROW_GAP := 4
const GAP := 8

var column := VBoxContainer.new()


func _init() -> void:
	super()
	add_theme_stylebox_override(&"panel", AbyssBox.flat(AbyssColors.SURFACE_DIM, 0, PADDING))
	column.add_theme_constant_override(&"separation", ROW_GAP)
	add_child(column)


## A row of [param glyph] tinted [param color], [param icon_size] across, then
## [param parts].
func add_row(glyph: StringName, color: Color, icon_size: float, parts: Array[Control]) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(UiIcon.glyph(glyph, icon_size, color))
	for part in parts:
		row.add_child(part)
	column.add_child(row)
	return row


## A label of the theme's [param role] in [param color], wrapped, filling the
## row.
static func label_of(role: StringName, color := AbyssColors.ON_SURFACE) -> Label:
	var label := Label.new()
	label.theme_type_variation = role
	label.add_theme_color_override(&"font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label
