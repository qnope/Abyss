class_name GuideRing
extends Node3D
## The guide's halo in the 3D world: a pulsing cyan ring lying on the floor
## around the pad of a building, the drill pad of a unit or the cell of the map
## the tutorial asks to touch (Flutter's BaseSlotHalo and GuideCellHalo), with
## the name of what it points at floating over it when it has one. Each scene
## of the world carries one ([member BaseScene.guide]...); `app/` says where it
## points, this layer knows nothing of the guide's advice.
##
##     scene.guide.point_at(pads.origin_of(&"Headquarters"), 1.6, "QG")
##     scene.guide.clear()

## One beat of the pulse, in seconds: dimmest to brightest (the interface's
## halo beats at the same pace).
const BEAT := 0.9
## The thickness of the ring in metres, and how far over the floor it lies.
const TUBE := 0.07
const LIFT := 0.06
## How high the name floats over the ring.
const CAPTION_HEIGHT := 2.6
const FONT_SIZE := 64
const OUTLINE := 16
const PIXEL_SIZE := 0.008
## How much bigger the ring is at the brightest of the pulse.
const SWELL := 0.06

## The ring on show, its middle on the floor.
var ring := MeshInstance3D.new()
var caption := Label3D.new()
## The radius of the ring on show, in metres.
var radius := 0.0
## The thickness of the ring in metres: a bare floor of the map asks for more.
var tube := TUBE
## Fewer animations: the ring holds still, at its brightest.
var reduced_motion := false
## Where the pulse is now, from 0 (dimmest) to 1 (brightest).
var pulse := 1.0
var _material := StandardMaterial3D.new()
var _torus := TorusMesh.new()
var _tween: Tween


func _init() -> void:
	name = &"GuideRing"
	visible = false
	_torus.rings = 48
	_torus.ring_segments = 8
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.render_priority = 1
	_torus.material = _material
	ring.mesh = _torus
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ring)
	caption.font_size = FONT_SIZE
	caption.outline_size = OUTLINE
	caption.pixel_size = PIXEL_SIZE
	caption.modulate = WorldPalette.GUIDE
	caption.outline_modulate = WorldPalette.LEVEL_OUTLINE
	caption.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	caption.no_depth_test = true
	caption.render_priority = 2
	caption.shaded = false
	caption.position.y = CAPTION_HEIGHT
	add_child(caption)
	_show(1.0)


func _enter_tree() -> void:
	_sync()


func _exit_tree() -> void:
	_stop()


## Rings the floor at [param at] (the middle of a pad or a cell) with
## [param ring_radius] metres, and writes [param name_text] over it if given.
func point_at(at: Vector3, ring_radius: float, name_text := "") -> void:
	position = at + Vector3.UP * LIFT
	radius = ring_radius
	_torus.inner_radius = maxf(ring_radius - tube, 0.0)
	_torus.outer_radius = ring_radius + tube
	caption.text = name_text
	caption.visible = not name_text.is_empty()
	visible = true
	_sync()


## Takes the ring away.
func clear() -> void:
	visible = false
	_stop()


## Whether the ring is pulsing now.
func is_pulsing() -> bool:
	return _tween != null and _tween.is_running()


func _sync() -> void:
	_stop()
	_show(1.0)
	if not visible or reduced_motion or not is_inside_tree():
		return
	_tween = create_tween().set_loops()
	_tween.tween_method(_show, 1.0, 0.0, BEAT)
	_tween.tween_method(_show, 0.0, 1.0, BEAT)


func _stop() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null


func _show(at: float) -> void:
	pulse = at
	_material.albedo_color = Color(WorldPalette.GUIDE, lerpf(0.45, 1.0, at))
	ring.scale = Vector3.ONE * lerpf(1.0, 1.0 + SWELL, at)
