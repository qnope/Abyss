class_name CountBadge
extends PanelContainer
## A small ring holding a count, such as the number of saved games
## (lib/presentation/widgets/menu/count_badge.dart).

const DIAMETER := 24.0
const RADIUS := 12
const PADDING := Vector2i(6, 0)
const RING := 1.5

var label := Label.new()


func _init(count: int, color: Color) -> void:
	custom_minimum_size = Vector2(DIAMETER, DIAMETER)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := AbyssBox.flat(Color.TRANSPARENT, RADIUS, PADDING)
	add_theme_stylebox_override(&"panel", AbyssBox.rimmed(box, color, RING))
	label.text = str(count)
	label.theme_type_variation = &"BadgeLabel"
	label.add_theme_color_override(&"font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)


## Shows [param count].
func set_count(count: int) -> void:
	label.text = str(count)
