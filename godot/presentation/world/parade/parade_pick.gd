class_name ParadePick
extends RefCounted
## What a tap picks on the parade ground: the nearest of the boxes a ray
## meets, as [BasePads.pick] does on the base. Pure maths, so that it is
## tested without a screen.

## No box was met, and the barracks' box, among those of the units (whose
## keys are the [enum UnitType.Value]).
const NONE := -1
const BARRACKS := -2


## The key of the box of [param boxes] that a ray from [param origin] along
## [param direction] meets first, or [constant NONE].
static func pick(boxes: Dictionary[int, AABB], origin: Vector3, direction: Vector3) -> int:
	var picked := NONE
	var nearest := INF
	for key: int in boxes:
		var hit: Variant = boxes[key].intersects_ray(origin, direction)
		if hit == null:
			continue
		var point: Vector3 = hit
		if origin.distance_to(point) < nearest:
			nearest = origin.distance_to(point)
			picked = key
	return picked
