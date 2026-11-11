class_name InfoBadge
extends PanelContainer
## A line of information in a small box rimmed with a colour, an icon before
## its text: the "free worksites" and "base rampart" banners over the base
## (lib/presentation/widgets/building/worksite_badge.dart and
## base_shield_badge.dart, which draw the same box). It lets touches through,
## to the world under it. The text stays on one line: the box is as wide as it.

const RADIUS := 8
const PADDING := Vector2i(12, 6)
const GAP := 8
const ICON_SIZE := 16.0

var icon: UiIcon
var label := Label.new()


## A badge saying [param text] in [param color] beside the glyph in the file
## [param icon_path].
func _init(icon_path: String, color: Color, text: String) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	icon = UiIcon.new(icon_path, ICON_SIZE)
	label.theme_type_variation = &"BodyMedium"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	row.add_child(label)
	add_child(row)
	show_text(text, color)


## Says [param text], the rim and the icon in [param color].
func show_text(text: String, color: Color) -> void:
	var box := AbyssBox.flat(AbyssColors.SURFACE_DIM, RADIUS, PADDING)
	add_theme_stylebox_override(&"panel", AbyssBox.rimmed(box, color))
	icon.self_modulate = color
	label.text = text
