extends TestCase
## A finger put down on the map stops it where it is: a fling going or an ease
## not over would move the map under the finger, and a tap would pick another
## cell than the one touched.

const FRAME := 1.0 / 60.0

var _rig: MapRig
var _gestures: OrbitGestures


func before_each() -> void:
	_rig = MapRig.new()
	_rig.bounds = Rect2(-13.0, -13.0, 26.0, 26.0)
	_gestures = OrbitGestures.new(_rig)


## A drag to the left released while moving: the map flings on.
func _fling() -> void:
	for i in 6:
		_rig.drag(Vector2(-30.0, 0.0), FRAME)
		_rig.step(FRAME)
	_rig.release()
	_rig.step(FRAME)


func test_catching_stops_a_fling_where_the_view_is() -> void:
	_fling()
	var at := _rig.target
	assert_false(_rig.is_settled())
	_rig.catch()
	assert_true(_rig.is_settled())
	assert_eq(_rig.target, at)
	assert_eq(_rig.goal_target, at)
	_rig.step(FRAME)
	assert_eq(_rig.target, at, "nothing moves it on")


func test_catching_stops_an_ease_where_the_view_is() -> void:
	_rig.drag(Vector2(-100.0, 0.0), FRAME)
	_rig.release()
	_rig.step(FRAME)
	var at := _rig.target
	assert_ne(_rig.goal_target, at)
	_rig.catch()
	assert_eq(_rig.goal_target, at)
	assert_true(_rig.is_settled())


func test_a_finger_put_down_catches_the_map() -> void:
	_fling()
	_gestures.handle(_touch(0, true), 1.0)
	assert_true(_rig.is_settled())


func test_a_second_finger_catches_nothing_more() -> void:
	_gestures.handle(_touch(0, true), 0.0)
	_rig.drag(Vector2(-100.0, 0.0), FRAME)
	var goal := _rig.goal_target
	_gestures.handle(_touch(1, true), 0.1)
	assert_eq(_rig.goal_target, goal, "the goal of the drag stays")


func _touch(index: int, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = Vector2(100.0, 100.0)
	event.pressed = pressed
	return event
