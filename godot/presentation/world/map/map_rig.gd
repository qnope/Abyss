class_name MapRig
extends OrbitRig
## The view of the map: it looks down at a steep angle that never changes, and
## a drag moves the point it looks at over the map (the orbit's drag turns the
## base). Pinches and the wheel zoom as the orbit's do. The point stays within
## the map, so the player cannot lose it.

## The map is seen from the front, tilted back a little from straight down.
const YAW := 0.0
const PITCH := -62.0
## Metres the view moves for a point of drag, per metre of distance: the
## map follows the finger.
const PAN_PER_POINT := 0.0018

## Where the view may look, from the map's centre (x and z of the plane).
var bounds := Rect2()


func _init() -> void:
	yaw = YAW
	goal_yaw = YAW
	pitch = PITCH
	goal_pitch = PITCH


## Moves the view by a drag of [param points]: the map follows the finger.
func drag(points: Vector2, _seconds: float) -> void:
	var moved := target - Vector3(points.x, 0.0, points.y) * PAN_PER_POINT * distance
	target = Vector3(
		clampf(moved.x, bounds.position.x, bounds.end.x), 0.0,
		clampf(moved.z, bounds.position.y, bounds.end.y))


## Puts the view back on the middle of the map, at the default zoom.
func home() -> void:
	target = Vector3.ZERO
	look(YAW, PITCH, default_distance)
