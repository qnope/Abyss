class_name PadLevelLabel
extends Label3D
## The level of a building, written over it: a number in white with a dark
## outline, facing the camera and drawn over the buildings.

const FONT_SIZE := 72
const OUTLINE := 18
## A glyph's height in metres at [constant FONT_SIZE].
const PIXEL_SIZE := 0.005


func _init(level: int) -> void:
	name = &"Level"
	text = str(level)
	font_size = FONT_SIZE
	outline_size = OUTLINE
	pixel_size = PIXEL_SIZE
	modulate = WorldPalette.LEVEL
	outline_modulate = WorldPalette.LEVEL_OUTLINE
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	render_priority = 2
	shaded = false
