class_name LevelSpecks
extends CPUParticles3D
## The specks of a level over its map: marine snow, bubbles or ash ([SpeckLooks]),
## drifting in a box over the whole slab. One CPU particle system, one draw
## call, as the base's snow and bubbles: no particle shader to compile on the
## web. It runs only while there is a level to show and the scene is on view
## (a hidden or paused scene is not processed), and stops with the particles
## setting of the quality panel ([method set_running]).

## How far beyond the slab's edge the specks drift.
const MARGIN := 3.0

var _shown := ""
var _running := true


func _init() -> void:
	randomness = 1.0
	emission_shape = EMISSION_SHAPE_BOX
	direction = Vector3(1.0, 0.0, 0.0)
	spread = 180.0
	color_ramp = ParticleDot.fading()
	cast_shadow = SHADOW_CASTING_SETTING_OFF
	emitting = false


## Drifts the specks of [param level] over a map of [param width] by
## [param height] cells, in place of the ones before. The same again changes
## nothing.
func show_level(level: int, width: int, height: int) -> void:
	var signature := "%d:%d:%d" % [MapScenery.index_of(level), width, height]
	if signature == _shown:
		return
	_shown = signature
	var look := SpeckLooks.of_level(level)
	amount = look.amount
	lifetime = look.lifetime
	preprocess = look.lifetime
	color = look.colour
	gravity = Vector3(0.0, look.lift, 0.0)
	initial_velocity_min = look.speed.x
	initial_velocity_max = look.speed.y
	mesh = ParticleDot.quad(look.size, 1.0, 0.5)
	emission_box_extents = Vector3(width / 2.0 + MARGIN, look.height / 2.0, height / 2.0 + MARGIN)
	position = Vector3(0.0, look.height / 2.0 + 0.2, 0.0)
	restart()
	emitting = _running


## Shows the specks or hides them, and stops computing them while hidden.
func set_running(running: bool) -> void:
	_running = running
	visible = running
	emitting = running and not _shown.is_empty()
