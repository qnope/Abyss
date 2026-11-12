class_name PadHalos
extends Node3D
## The glow of the buildings that can rise: a soft disc of light behind each
## one, facing the camera, that breathes (Flutter's rise glow, which the arrow
## [PadMark] above the building goes with). All the discs share one additive
## material and one quad, so the lot draws in one call per building and a
## single tween breathes them; a degraded building is warned of, not glowed.

## A breath, in seconds: the pulse of the other glows of the base.
const CYCLE := 3.0
## The disc's opacity at its dimmest and at its brightest.
const ALPHA := Vector2(0.25, 0.65)
## How much bigger the disc is at the brightest of the pulse.
const SWELL := 0.08
## The disc's diameter against the building's greater side (its height, or
## its pad's width), and where it sits against the building's height.
const REACH := 1.6
const CENTRE := 0.5
const SOFT := Vector2(1.0, 0.45)

## Fewer animations: the discs hold still, at their brightest.
var reduced_motion := false
## Where the breath is now, from 0 (dimmest) to 1 (brightest).
var pulse := 1.0
var _material := StandardMaterial3D.new()
var _quad := QuadMesh.new()
var _sizes := PackedFloat32Array()
var _tween: Tween


func _init() -> void:
	name = &"Halos"
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_material.billboard_keep_scale = true
	_material.disable_receive_shadows = true
	_material.albedo_texture = ParticleDot.dot(SOFT.x, SOFT.y)
	_quad.size = Vector2.ONE
	_quad.material = _material
	_show(1.0)


func _enter_tree() -> void:
	_sync()


func _exit_tree() -> void:
	_stop()


## Draws the halos of [param states] around their buildings, which stand in
## [param buildings] on [param pads], in place of the ones before: one for
## each building that can rise and works well.
func show_halos(states: Array[PadState], pads: BasePads, buildings: BaseBuildings) -> void:
	for child: Node in get_children():
		child.free()
	_sizes.clear()
	for state in states:
		if state.is_built() and state.upgradable and not state.degraded:
			var origin := pads.origin_of(state.pad())
			var height := ModelBounds.top_of(buildings.building(state.pad())) - origin.y
			_add(origin + Vector3.UP * height * CENTRE,
				REACH * maxf(height, 2.0 * pads.radius_of(state.pad())))
	_sync()


## Whether the halos are breathing now.
func is_pulsing() -> bool:
	return _tween != null and _tween.is_running()


func _add(at: Vector3, size: float) -> void:
	var halo := MeshInstance3D.new()
	halo.name = &"Halo"
	halo.mesh = _quad
	halo.position = at
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(halo)
	_sizes.append(size)
	_size(halo, size, pulse)


func _sync() -> void:
	_stop()
	_show(1.0)
	if get_child_count() == 0 or reduced_motion or not is_inside_tree():
		return
	_tween = create_tween().set_loops()
	_tween.tween_method(_show, 1.0, 0.0, CYCLE / 2.0).set_trans(Tween.TRANS_SINE)
	_tween.tween_method(_show, 0.0, 1.0, CYCLE / 2.0).set_trans(Tween.TRANS_SINE)


func _stop() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null


func _show(at: float) -> void:
	pulse = at
	_material.albedo_color = Color(WorldPalette.UPGRADE, lerpf(ALPHA.x, ALPHA.y, at))
	for index in get_child_count():
		_size(get_child(index) as Node3D, _sizes[index], at)


static func _size(halo: Node3D, size: float, at: float) -> void:
	halo.scale = Vector3.ONE * size * lerpf(1.0, 1.0 + SWELL, at)
