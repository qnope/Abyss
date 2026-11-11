class_name StripLine
extends HBoxContainer
## One line of a status strip under the resource bar: a small glyph and a
## short text in one colour, which wraps (lib/.../event_status_bar.dart, its
## `_line`). It lets the touches through, to what covers it.

const ICON_SIZE := 16.0
const GAP := 8

var icon: UiIcon
var label := Label.new()


## A line in [param color] beside the glyph [param glyph] (a file of
## assets/icons/ui); [method show_text] says it.
func _init(glyph: StringName, color: Color) -> void:
	add_theme_constant_override(&"separation", GAP)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon = UiIcon.glyph(glyph, ICON_SIZE, color)
	label.theme_type_variation = &"BodySmall"
	label.add_theme_color_override(&"font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon)
	add_child(label)


## Says [param text], or hides the line when it is null.
func show_text(text: Variant) -> void:
	visible = text != null
	if text != null:
		label.text = text
