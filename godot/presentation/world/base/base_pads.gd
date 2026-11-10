class_name BasePads
extends RefCounted
## The pads of the base's island (its node Pads/<Building>), one for each
## building: where a building stands, the empty ones marked discreetly on
## the deck (PadMarker), and the one under a tap.

## The height above a pad that a tap still picks it: its building.
const PICK_HEIGHT := 3.2

var marker: PadMarker
var _pads: Dictionary[StringName, MeshInstance3D] = {}
var _empty: Dictionary[StringName, bool] = {}


## Reads the pads under [param holder], the island's Pads node.
func _init(holder: Node3D) -> void:
	for node: Node in holder.get_children():
		var pad := node as MeshInstance3D
		_pads[pad.name] = pad
		# A slab a few centimetres thick: its shadow is not worth a pass.
		pad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var first: MeshInstance3D = _pads.values()[0]
	marker = PadMarker.new(first.mesh)


## The names of the pads, which are the buildings' names.
func names() -> Array[StringName]:
	return _pads.keys()


## The top centre of the pad [param name], where its building stands, in
## the island's space.
func origin_of(name: StringName) -> Vector3:
	return _pads[name].position


## Marks every pad but those of [param occupied] as empty.
func mark(occupied: Array[StringName]) -> void:
	for name: StringName in _pads:
		var empty := not occupied.has(name)
		_empty[name] = empty
		var pad := _pads[name]
		pad.set_surface_override_material(0, marker.stone if empty else null)
		pad.set_surface_override_material(1, marker.glow if empty else null)


func is_empty(name: StringName) -> bool:
	return _empty.get(name, true)


## The pad, or the building on it, that a ray from [param origin] along
## [param direction] (in the island's space) meets first, or &"" if none.
func pick(origin: Vector3, direction: Vector3) -> StringName:
	var picked := &""
	var nearest := INF
	for name: StringName in _pads:
		var hit: Variant = _box(_pads[name]).intersects_ray(origin, direction)
		if hit == null:
			continue
		var point: Vector3 = hit
		if origin.distance_to(point) < nearest:
			nearest = origin.distance_to(point)
			picked = name
	return picked


static func _box(pad: MeshInstance3D) -> AABB:
	var footprint := pad.get_aabb()
	var box := AABB(footprint.position + pad.position, footprint.size)
	box.size.y = PICK_HEIGHT
	return box
