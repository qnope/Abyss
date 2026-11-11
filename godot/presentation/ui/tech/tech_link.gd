class_name TechLink
extends Panel
## The thread between two nodes of a branch, running down its column: lit in
## the branch's colour once the path has been opened as far as it, dim
## otherwise. Flutter paints the spokes of the reef with a painter
## (tech_reef_painter.dart); here a thin panel does.

const WIDTH := 2
const LIT_ALPHA := 0.7

var lit: bool
var color: Color


## A link of [param height] points, in [param tint] when [param is_lit].
func _init(tint: Color, is_lit: bool, height := 16.0) -> void:
	lit = is_lit
	color = Color(tint, LIT_ALPHA) if lit else AbyssColors.DISABLED
	custom_minimum_size = Vector2(WIDTH, height)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override(&"panel", AbyssBox.flat(color, 1))
