class_name AnimatedAmount
extends Label
## The amount of a resource, bold in the colour of the resource: when it
## changes it flashes green if it grew and red if it fell, pops, and settles
## back (lib/presentation/widgets/resource/animated_resource_amount.dart), while
## the change floats up from it, "+30" or "−12" ([DeltaFloat], which the Flutter
## game wrapped round it). Fewer animations ([member reduced_motion]) just
## change the number.

## How much larger the amount is at the top of its pop.
const POP := 1.25

## Fewer animations: the amount changes without a flash or a pop.
var reduced_motion := false
var amount: int
var base_color: Color
## The flash and pop under way, null when none is.
var tween: Tween
## The change, floating up from the amount.
var floater := DeltaFloat.new()


func _init(color: Color, start: int) -> void:
	base_color = color
	amount = start
	text = str(start)
	theme_type_variation = &"ResourceAmount"
	add_theme_color_override(&"font_color", color)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floater)


## Shows [param value], flashing and popping if it is not the amount shown.
func set_amount(value: int) -> void:
	if value == amount:
		return
	var flash := AbyssColors.SUCCESS if value > amount else AbyssColors.ERROR
	floater.reduced_motion = reduced_motion
	floater.float_from(self, value - amount)
	amount = value
	text = str(value)
	_stop()
	if reduced_motion or not is_inside_tree():
		return
	pivot_offset = size / 2.0
	scale = Vector2.ONE * POP
	add_theme_color_override(&"font_color", flash)
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "theme_override_colors/font_color", base_color, AbyssMotion.EMPHASIS)
	tween.tween_property(self, "scale", Vector2.ONE, AbyssMotion.QUICK) \
		.set_trans(AbyssMotion.POP_TRANS).set_ease(AbyssMotion.POP_EASE)


## Whether the flash and the pop are under way.
func is_flashing() -> bool:
	return tween != null and tween.is_running()


func _exit_tree() -> void:
	_stop()


func _stop() -> void:
	if tween != null:
		tween.kill()
		tween = null
	scale = Vector2.ONE
	add_theme_color_override(&"font_color", base_color)
