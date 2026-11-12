class_name BasePads
extends RefCounted
## The pads of the base's island (its node Pads/<Building>), one for each
## building: where a building stands, the empty ones marked discreetly on
## the deck (PadMarker), and the one under a tap.

## How far above its top an empty pad is picked, and how far above a
## building's top the building is: a finger rarely lands on the very edge.
const EMPTY_REACH := 0.8
const REACH_MARGIN := 0.3

var marker: PadMarker
var _pads: Dictionary[StringName, MeshInstance3D] = {}
var _empty: Dictionary[StringName, bool] = {}
var _reach: Dictionary[StringName, float] = {}


## Reads the pads under [param holder], the island's Pads node.
func _init(holder: Node3D) -> void:
	for node: Node in holder.get_children():
		var pad := node as MeshInstance3D
		_pads[pad.name] = pad
		_reach[pad.name] = EMPTY_REACH
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


## The top centres of the pads [param named], in the island's space.
func origins_of(named: Array[StringName]) -> PackedVector3Array:
	var origins := PackedVector3Array()
	for name in named:
		origins.append(origin_of(name))
	return origins


## How far the pad of [param name] reaches from its middle, in metres.
func radius_of(name: StringName) -> float:
	var size := _pads[name].get_aabb().size
	return maxf(size.x, size.z) / 2.0


## Marks every pad but those of [param occupied] as empty.
func mark(occupied: Array[StringName]) -> void:
	for name: StringName in _pads:
		var empty := not occupied.has(name)
		_empty[name] = empty
		_reach[name] = EMPTY_REACH
		var pad := _pads[name]
		pad.set_surface_override_material(0, marker.stone if empty else null)
		pad.set_surface_override_material(1, marker.glow if empty else null)


## Lets a tap pick each pad up to the top of the building of
## [param buildings] on it, a pad with none up to [constant EMPTY_REACH]: a
## tall building over its pad is not hidden by the box of a short one behind.
func fit_reach(buildings: BaseBuildings) -> void:
	for name in buildings.names():
		var top := ModelBounds.top_of(buildings.building(name))
		_reach[name] = top - origin_of(name).y + REACH_MARGIN


func is_empty(name: StringName) -> bool:
	return _empty.get(name, true)


## The pad, or the building on it, that a ray from [param origin] along
## [param direction] (in the island's space) meets first, or &"" if none.
func pick(origin: Vector3, direction: Vector3) -> StringName:
	var picked := &""
	var nearest := INF
	for name: StringName in _pads:
		var hit: Variant = _box(name).intersects_ray(origin, direction)
		if hit == null:
			continue
		var point: Vector3 = hit
		if origin.distance_to(point) < nearest:
			nearest = origin.distance_to(point)
			picked = name
	return picked


func _box(name: StringName) -> AABB:
	var pad := _pads[name]
	var footprint := pad.get_aabb()
	var box := AABB(footprint.position + pad.position, footprint.size)
	box.size.y = _reach[name] - footprint.position.y
	return box
