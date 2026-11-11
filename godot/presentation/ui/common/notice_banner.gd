class_name NoticeBanner
extends PanelContainer
## A tinted box with an icon and a short text in one colour: a warning or an
## information at the top of a dialog (lib/.../notice_banner.dart).

const RADIUS := 8
const PADDING := Vector2i(12, 12)
const GAP := 8
const ICON_SIZE := 24.0

var icon: UiIcon
var label := Label.new()


## A banner saying [param text] in [param color] beside the icon in the file
## [param icon_path] (for example [code]UiIcon.glyph_path(&"warning")[/code]).
func _init(icon_path: String, color: Color, text: String) -> void:
	var box := AbyssBox.flat(Color(color, 0.15), RADIUS, PADDING)
	add_theme_stylebox_override(&"panel", AbyssBox.rimmed(box, Color(color, 0.5)))
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	icon = UiIcon.new(icon_path, ICON_SIZE, color)
	label.text = text
	label.theme_type_variation = &"BodySmall"
	label.add_theme_color_override(&"font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(icon)
	row.add_child(label)
	add_child(row)
