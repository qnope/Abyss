class_name MapRig
extends OrbitRig
## The view of the map: it looks down at a steep angle that never changes, and
## a drag moves the point it looks at over the map (the orbit's drag turns the
## base). The drag moves a goal the view eases to, as the orbit's does: touch
## moves do not come in step with the frames, and the ease evens them out. A
## drag released while moving flings the view on until friction, the edge of
## the map or a finger put down stops it. Pinches and the wheel zoom as the orbit's do. The
## point stays within the map, so the player cannot lose it.

## The map is seen from the front, tilted back a little from straight down.
const YAW := 0.0
const PITCH := -62.0
## Metres the goal moves for a point of drag, per metre of distance: the
## map follows the finger.
const PAN_PER_POINT := 0.0018
## The fastest fling, and the slowest, under which it stops, in metres per
## second: what the orbit's are in points of drag, the fastest seen from
## MAX_DISTANCE and the slowest from MIN_DISTANCE.
const MAX_PAN_FLING := 80.0
const MIN_PAN_FLING := 0.05

## Where the view may look, from the map's centre (x and z of the plane).
var bounds := Rect2():
	set(value):
		bounds = value
		goal_target = _within(goal_target)
## Where the view goes, which [member target] eases to: [method place] sets
## both.
var goal_target := Vector3.ZERO

## The pan's speed of a fling, in metres per second on the plane.
var _pan_fling := Vector3.ZERO


func _init() -> void:
	yaw = YAW
	goal_yaw = YAW
	pitch = PITCH
	goal_pitch = PITCH


## Moves the goal by a drag of [param points] that took [param seconds] since
## the last one: the map follows the finger, as far as its edge.
func drag(points: Vector2, seconds: float) -> void:
	_held = true
	var from := goal_target
	goal_target = _within(from - Vector3(points.x, 0.0, points.y) * PAN_PER_POINT * distance)
	var speed := (goal_target - from) / maxf(seconds, 1.0 / 60.0)
	_pan_fling = _pan_fling.lerp(speed, 0.6).limit_length(MAX_PAN_FLING)


## A finger comes down on the view: the map stops under it, where it is, so
## that a tap picks the cell it touched.
func catch() -> void:
	place(target)


## Holds the view still under two fingers that pinch: a fling stops at once.
func hold() -> void:
	super()
	_pan_fling = Vector3.ZERO


## Puts the view at once over [param point] of the map: nothing eases after.
func place(point: Vector3) -> void:
	goal_target = _within(point)
	target = goal_target
	_pan_fling = Vector3.ZERO


## Puts the view back on the middle of the map, at the default zoom.
func home() -> void:
	place(Vector3.ZERO)
	look(YAW, PITCH, default_distance)


## Moves the view [param seconds] on: the fling, which an edge of the map
## stops along its axis, then the ease to the goal.
func step(seconds: float) -> void:
	super(seconds)
	_pan_fling *= exp(-(HOLD_FRICTION if _held else FRICTION) * seconds)
	if _pan_fling.length() < MIN_PAN_FLING:
		_pan_fling = Vector3.ZERO
	if not _held:
		var wanted := goal_target + _pan_fling * seconds
		goal_target = _within(wanted)
		if goal_target.x != wanted.x:
			_pan_fling.x = 0.0
		if goal_target.z != wanted.z:
			_pan_fling.z = 0.0
	var share := 1.0 - exp(-SMOOTHING * seconds)
	target = Vector3(_ease(target.x, goal_target.x, share), 0.0,
		_ease(target.z, goal_target.z, share))


## Whether the view stands still on its goal.
func is_settled() -> bool:
	return super() and _pan_fling == Vector3.ZERO and target == goal_target


## [param point] on the plane, brought back within the map.
func _within(point: Vector3) -> Vector3:
	return Vector3(clampf(point.x, bounds.position.x, bounds.end.x), 0.0,
		clampf(point.z, bounds.position.y, bounds.end.y))
