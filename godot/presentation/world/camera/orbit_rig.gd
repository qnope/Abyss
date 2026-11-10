class_name OrbitRig
extends RefCounted
## The maths of the camera orbiting the base, without a node: a yaw around
## the vertical axis, a pitch looking down and a distance from the target.
## Drags and pinches set goals the view eases to, within bounds; a drag
## released while moving flings the view on until friction stops it.
## OrbitCamera feeds it the player's input and takes its transform.

## The game's 3/4 view (tool/models/preview.sh): from the base's front
## corner, the largest x and z, looking down at its centre.
const DEFAULT_YAW := 45.0
const DEFAULT_PITCH := -50.0
const DEFAULT_DISTANCE := 29.0
## From nearly overhead to a low view along the deck, in degrees.
const MIN_PITCH := -82.0
const MAX_PITCH := -16.0
## From a building filling the screen to the whole island and its spike:
## the farthest is the fitted view's distance times ZOOM_OUT, never past
## MAX_DISTANCE.
const MIN_DISTANCE := 9.0
const MAX_DISTANCE := 44.0
const ZOOM_OUT := 1.4
## Degrees turned by a drag of one point.
const DEGREES_PER_POINT := 0.3
## How fast the view catches its goal: a share of 1 - exp(-SMOOTHING * t).
const SMOOTHING := 12.0
## How fast a fling slows down, and how fast a finger held still stops it.
const FRICTION := 3.5
const HOLD_FRICTION := 20.0
## The fastest fling, and the slowest, under which it stops, in degrees per
## second.
const MAX_FLING := 300.0
const MIN_FLING := 1.0
## Under this gap, in degrees or units, the view is on its goal.
const SNAP := 0.001

var target := Vector3.ZERO
var yaw := DEFAULT_YAW
var pitch := DEFAULT_PITCH
var distance := DEFAULT_DISTANCE
var goal_yaw := DEFAULT_YAW
var goal_pitch := DEFAULT_PITCH
var goal_distance := DEFAULT_DISTANCE
## The distance of the default view, fitted to the screen, and the farthest.
var default_distance := DEFAULT_DISTANCE
var max_distance := MAX_DISTANCE
## How high the camera rises along its own up, as a share of its distance:
## the target then shows below the screen's centre, under the HUD.
var lift := 0.0

## The yaw's speed of a fling, in degrees per second.
var _fling := 0.0
var _held := false


## Turns the goal by a drag of [param points] (screen points) that took
## [param seconds] since the last one: right turns the base right, down
## looks from higher.
func drag(points: Vector2, seconds: float) -> void:
	_held = true
	var turn := -points.x * DEGREES_PER_POINT
	goal_yaw += turn
	goal_pitch = clampf(goal_pitch - points.y * DEGREES_PER_POINT, MIN_PITCH, MAX_PITCH)
	var speed := turn / maxf(seconds, 1.0 / 60.0)
	_fling = clampf(lerpf(_fling, speed, 0.6), -MAX_FLING, MAX_FLING)


## Lets go of the drag: the view flings on at the drag's last speed.
func release() -> void:
	_held = false


## Moves the goal [param factor] times as far: under 1 zooms in.
func zoom(factor: float) -> void:
	goal_distance = clampf(goal_distance * factor, MIN_DISTANCE, max_distance)


## Puts the view at once on these angles (degrees) and [param distance_].
func look(yaw_: float, pitch_: float, distance_: float) -> void:
	goal_yaw = yaw_
	goal_pitch = clampf(pitch_, MIN_PITCH, MAX_PITCH)
	goal_distance = clampf(distance_, MIN_DISTANCE, max_distance)
	yaw = goal_yaw
	pitch = goal_pitch
	distance = goal_distance
	_fling = 0.0


## Fits the default view to the screen (OrbitFrame): its [param distance_]
## and its [param lift_]. The view keeps its zoom relative to the default.
func frame(distance_: float, lift_: float) -> void:
	var ratio := distance_ / default_distance
	default_distance = distance_
	max_distance = maxf(distance_, minf(distance_ * ZOOM_OUT, MAX_DISTANCE))
	lift = lift_
	goal_distance = clampf(goal_distance * ratio, MIN_DISTANCE, max_distance)
	distance = clampf(distance * ratio, MIN_DISTANCE, max_distance)


## Moves the view [param seconds] on: the fling, then the ease to the goal.
func step(seconds: float) -> void:
	_fling *= exp(-(HOLD_FRICTION if _held else FRICTION) * seconds)
	if absf(_fling) < MIN_FLING:
		_fling = 0.0
	if not _held:
		goal_yaw += _fling * seconds
	var share := 1.0 - exp(-SMOOTHING * seconds)
	yaw = _ease(yaw, goal_yaw, share)
	pitch = _ease(pitch, goal_pitch, share)
	distance = _ease(distance, goal_distance, share)
	_wrap()


## Whether the view stands still on its goal.
func is_settled() -> bool:
	return _fling == 0.0 and yaw == goal_yaw and pitch == goal_pitch \
		and distance == goal_distance


## The camera's place, looking at the target.
func transform() -> Transform3D:
	var basis := Basis.from_euler(Vector3(deg_to_rad(pitch), deg_to_rad(yaw), 0.0))
	return Transform3D(basis, target + basis * Vector3(0.0, lift, 1.0) * distance)


static func _ease(value: float, goal: float, share: float) -> float:
	var next := lerpf(value, goal, share)
	return goal if absf(goal - next) < SNAP else next


## Keeps the yaw within a turn, so that it never loses precision.
func _wrap() -> void:
	if absf(goal_yaw) < 360.0:
		return
	var turns := goal_yaw - fposmod(goal_yaw, 360.0)
	goal_yaw -= turns
	yaw -= turns
