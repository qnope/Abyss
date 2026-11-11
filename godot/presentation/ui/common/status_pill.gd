class_name StatusPill
extends PanelContainer
## A short capitalised label in a rounded pill tinted with a colour, such as a
## difficulty or how a game ended (lib/presentation/widgets/common/status_pill.dart).

const RADIUS := 6
const PADDING := Vector2i(7, 2)
## Share of the colour's opacity the pill's fill keeps.
const FILL_SHARE := 0.16

var label := Label.new()


## A pill saying [param text] in [param color]; [param faded] dims it with the
## item it labels, such as a lost game.
func _init(text: String, color: Color, faded := false) -> void:
	var tint := AbyssColors.dimmed(color) if faded else color
	var box := AbyssBox.flat(Color(tint, tint.a * FILL_SHARE), RADIUS, PADDING)
	add_theme_stylebox_override(&"panel", box)
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.theme_type_variation = &"PillLabel"
	label.add_theme_color_override(&"font_color", tint)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
