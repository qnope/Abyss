class_name DeltaFloat
extends Label
## The figure that floats up from a value that changed, "+N" in the gain colour
## or "−N" in the loss colour, rising [constant RISE] points from the top
## centre of the control it is told to leave while it fades
## (lib/presentation/widgets/ambience/delta_float.dart). It sits on top of the
## screen whatever clips or lays out its parent (a top level control), takes no
## touch and never changes the size of what it leaves. A new change replaces
## the float under way; fewer animations ([member reduced_motion]) float
## nothing.
##
##     var float_up := DeltaFloat.new()
##     amount_label.add_child(float_up)
##     float_up.float_from(amount_label, +30)

## How far the figure rises, in points.
const RISE := 22.0

var gain_color: Color
var loss_color: Color
## Fewer animations: nothing floats.
var reduced_motion := false
## The float under way, null when none is.
var tween: Tween
var _origin := Vector2.ZERO


func _init(gain := AbyssColors.SUCCESS, loss := AbyssColors.ERROR) -> void:
	gain_color = gain
	loss_color = loss
	theme_type_variation = &"DeltaFloat"
	top_level = true
	z_index = 1
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Floats [param delta] up from the top centre of [param anchor], now.
func float_from(anchor: Control, delta: int) -> void:
	_stop()
	if delta == 0 or reduced_motion or not is_inside_tree():
		return
	text = label_of(delta)
	add_theme_color_override(&"font_color", gain_color if delta > 0 else loss_color)
	size = get_minimum_size()
	_origin = anchor.global_position + Vector2((anchor.size.x - size.x) / 2.0, 0.0)
	_at(0.0)
	visible = true
	tween = create_tween()
	tween.tween_method(_at, 0.0, 1.0, AbyssMotion.DELTA_FLOAT)
	tween.finished.connect(_stop)


## Whether a figure is floating.
func is_floating() -> bool:
	return tween != null and tween.is_running()


## The share of its rise a float has gone up at [param t], from 0 to 1.
static func lift_at(t: float) -> float:
	return Tween.interpolate_value(0.0, 1.0, t, 1.0, AbyssMotion.ENTER_TRANS, AbyssMotion.ENTER_EASE)


## The opacity of a float at [param t], from 1 down to 0.
static func fade_at(t: float) -> float:
	return 1.0 - Tween.interpolate_value(0.0, 1.0, t, 1.0, AbyssMotion.EXIT_TRANS, AbyssMotion.EXIT_EASE)


## "+N" for a gain, "−N" (with a true minus sign) for a loss.
static func label_of(delta: int) -> String:
	return "+%d" % delta if delta >= 0 else "−%d" % -delta


func _exit_tree() -> void:
	_stop()


func _stop() -> void:
	if tween != null:
		tween.kill()
		tween = null
	visible = false


func _at(t: float) -> void:
	position = _origin + Vector2(0.0, -RISE * lift_at(t))
	modulate.a = fade_at(t)
