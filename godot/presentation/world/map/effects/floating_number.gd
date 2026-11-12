class_name FloatingNumber
extends Label3D
## What a side lost in a round, floating up over it (StrikeMarks.damage): "−N" in
## red, facing the camera, rising all along its way and fading over its second
## half. Hidden until it is shown.

## How high it rises over its way, in metres, and its size.
const RISE := 0.6
const FONT_SIZE := 72
const OUTLINE := 16
const PIXEL_SIZE := 0.007


func _init() -> void:
	name = &"Loss"
	font_size = FONT_SIZE
	outline_size = OUTLINE
	pixel_size = PIXEL_SIZE
	modulate = MapPalette.DAMAGE
	outline_modulate = MapPalette.COUNT_OUTLINE
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	render_priority = 3
	shaded = false
	visible = false


## Shows "−[param damage]" [param progress] of its way (0 to 1) up from [param from].
func show_loss(from: Vector3, damage: int, progress: float) -> void:
	visible = true
	text = "−%d" % damage
	position = from + Vector3.UP * RISE * MapMotion.enter(progress)
	modulate.a = 1.0 if progress < 0.5 else maxf(2.0 - 2.0 * progress, 0.0)
