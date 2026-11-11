class_name GuideHalo
extends PanelContainer
## Wraps any control and, while [member active], surrounds it with a pulsing
## cyan glow: what the guide of the tutorial asks to touch
## (lib/.../guide_halo.dart). Inactive, it shows the content alone and runs no
## animation; with [member reduced_motion] the glow holds still. The look is
## AbyssGuideTheme's. The halo is the panel's style, drawn behind the content
## and just outside it, so the content stays crisp, and the content sits the
## same 2 px in from the edge whether the halo shows or not.
##
## Flutter can trace the halo along any path (the diamond of a slot on the
## base); the base's slots are in the 3D world here, so a halo is a rounded
## rectangle ([member radius]) or a circle ([constant CIRCLE]).

## A radius that makes a circle of a square content.
const CIRCLE := 4096

## Whether the halo shows and pulses.
var active := false:
	set(value):
		active = value
		_sync()
## The corner radius of the halo.
var radius := 12:
	set(value):
		radius = value
		_sync()
## How far inside the content's box the halo is drawn, such as the margin of
## a card.
var inset := 0:
	set(value):
		inset = value
		_sync()
## Fewer animations: the glow holds still, at its brightest.
var reduced_motion := false:
	set(value):
		reduced_motion = value
		_sync()
## Where the pulse is now, from 0 (dimmest) to 1 (brightest).
var pulse := 1.0

var _tween: Tween


func _init(content: Control, is_active := false, corner := 12) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)
	radius = corner
	active = is_active


func _enter_tree() -> void:
	_sync()


func _exit_tree() -> void:
	_stop()


## Whether the glow is pulsing now.
func is_pulsing() -> bool:
	return _tween != null and _tween.is_running()


func _sync() -> void:
	_stop()
	if not active:
		add_theme_stylebox_override(&"panel", AbyssGuideTheme.idle())
		return
	_show(1.0)
	if reduced_motion or not is_inside_tree():
		return
	_tween = create_tween().set_loops()
	_tween.tween_method(_show, 1.0, 0.0, AbyssGuideTheme.BEAT)
	_tween.tween_method(_show, 0.0, 1.0, AbyssGuideTheme.BEAT)


func _stop() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null


func _show(at: float) -> void:
	pulse = at
	add_theme_stylebox_override(&"panel", AbyssGuideTheme.halo(at, radius, inset))
