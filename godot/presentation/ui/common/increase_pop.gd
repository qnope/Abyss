class_name IncreasePop
extends Control
## Makes its picture rise once each time [param value] goes up, such as a level
## or a count: it starts a little low and small, pops up past its size and
## settles, while a glow drifts up above it and fades away
## (lib/presentation/widgets/ambience/increase_pop.dart and rise_motion.dart).
## Nothing moves when first shown, nor when the value stays or goes down; the
## last value seen is kept, so a value changed in place still pops. Fewer
## animations ([member reduced_motion]): the final state shows at once. It
## takes no touch.

const START_SCALE := 0.8
const START_DROP := 0.12
const START_GLOW := 0.7
## How much of the glow's strength the outer disc has, and how far the glow
## climbs over the picture's height.
const HALO_SHARE := 0.35
const CLIMB := 0.4
## A corner radius that always rounds a disc, whatever its size.
const ROUND := 999

## What rises.
var picture: Control
var glow_color: Color
var value: int
## Fewer animations: the picture rises at once.
var reduced_motion := false
## The rise under way, null when none is.
var tween: Tween
var _halo := Panel.new()
var _core := Panel.new()
var _at := 1.0


func _init(picture_: Control, box: Vector2, glow_color_: Color, start := 0) -> void:
	picture = picture_
	glow_color = glow_color_
	value = start
	custom_minimum_size = box
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for disc: Panel in [_halo, _core]:
		disc.add_theme_stylebox_override(&"panel", AbyssBox.flat(glow_color, ROUND))
		disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(disc)
	add_child(picture)
	resized.connect(_pose)
	_rise(1.0)


## Shows [param next]: the picture pops if it is more than the value shown.
func set_value(next: int) -> void:
	var rose := next > value
	value = next
	if not rose:
		return
	_stop()
	if reduced_motion or not is_inside_tree():
		return
	_rise(0.0)
	tween = create_tween()
	tween.tween_method(_rise, 0.0, 1.0, AbyssMotion.EMPHASIS)
	tween.finished.connect(_stop)


## Whether the picture is rising.
func is_rising() -> bool:
	return tween != null and tween.is_running()


## The picture's scale at [param t], from 0 (the start) to 1 (at rest).
static func scale_at(t: float) -> float:
	return START_SCALE + (1.0 - START_SCALE) * _pop(t)


## How far below its place the picture is at [param t], as a share of its
## height.
static func drop_at(t: float) -> float:
	return START_DROP * (1.0 - _pop(t))


## The glow's strength at [param t], from [constant START_GLOW] down to 0.
static func glow_at(t: float) -> float:
	return START_GLOW * (1.0 - clampf(t, 0.0, 1.0))


func _exit_tree() -> void:
	_stop()


func _stop() -> void:
	if tween != null:
		tween.kill()
		tween = null
	_rise(1.0)


## Poses the picture and the glow [param t] of the way through the rise.
func _rise(t: float) -> void:
	_at = t
	_pose()


## Poses the picture and the glow where the rise is, in the box's size.
func _pose() -> void:
	picture.size = size
	picture.pivot_offset = Vector2(size.x / 2.0, size.y)
	picture.scale = Vector2.ONE * scale_at(_at)
	picture.position = Vector2(0.0, size.y * drop_at(_at))
	var glow := glow_at(_at)
	var center := Vector2(size.x / 2.0, size.y * (0.5 - CLIMB * _at))
	var radius := minf(size.x, size.y) / 2.0
	_disc(_halo, center, radius, glow * HALO_SHARE)
	_disc(_core, center, radius / 2.0, glow)


## Draws [param disc] as a disc of [param radius] round [param center], its
## strength [param strength] of the glow's colour.
func _disc(disc: Panel, center: Vector2, radius: float, strength: float) -> void:
	disc.position = center - Vector2.ONE * radius
	disc.size = Vector2.ONE * 2.0 * radius
	disc.modulate.a = glow_color.a * strength
	disc.visible = strength > 0.0


static func _pop(t: float) -> float:
	return Tween.interpolate_value(
		0.0, 1.0, clampf(t, 0.0, 1.0), 1.0, AbyssMotion.POP_TRANS, AbyssMotion.POP_EASE)
