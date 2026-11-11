class_name MapPick
extends RefCounted
## What a tap picks on the map: the cell a ray from the camera meets, on a
## plane at the height of the stand-ins' middle so that a tall one is picked
## from its side as well as from above. Pure maths, so that it is tested
## without a screen, as [BasePads.pick] and [ParadePick] are.

## The height of the plane the ray is cut with.
const HEIGHT := 0.3


## The cell, a Vector2i, that a ray from [param origin] along [param direction]
## meets in a map of [param width] by [param height] cells, or null when it
## meets none (it points up, or lands beside the map).
static func cell(origin: Vector3, direction: Vector3, width: int, height: int) -> Variant:
	var hit: Variant = Plane(Vector3.UP, HEIGHT).intersects_ray(origin, direction)
	if hit == null:
		return null
	var point: Vector3 = hit
	return MapGrid.cell_at(point, width, height)
