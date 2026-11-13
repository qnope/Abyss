extends TestCase
## A pinch only zooms: the fingers that land one after the other, slide while
## pinching and lift one after the other never turn the view.

var _rig: OrbitRig
var _gestures: OrbitGestures


func before_each() -> void:
	_rig = OrbitRig.new()
	_gestures = OrbitGestures.new(_rig)


func test_a_finger_left_down_after_a_pinch_does_not_turn() -> void:
	_pinch()
	_gestures.handle(_touch(1, Vector2(300, 100), false), 0.1)
	_gestures.handle(_drag(0, Vector2(160, 140), Vector2(60, 40)), 0.116)
	assert_eq(_rig.goal_yaw, OrbitRig.DEFAULT_YAW)
	assert_eq(_rig.goal_pitch, OrbitRig.DEFAULT_PITCH)
	_gestures.handle(_touch(0, Vector2(160, 140), false), 0.2)
	_rig.step(1.0)
	assert_eq(_rig.yaw, OrbitRig.DEFAULT_YAW, "nor flings it once lifted")


func test_the_next_touch_after_a_pinch_turns_again() -> void:
	_pinch()
	_gestures.handle(_touch(1, Vector2(300, 100), false), 0.1)
	_gestures.handle(_touch(0, Vector2(100, 100), false), 0.1)
	_gestures.handle(_touch(0, Vector2(100, 100), true), 1.0)
	_gestures.handle(_drag(0, Vector2(140, 100), Vector2(40, 0)), 1.016)
	assert_almost_eq(_rig.goal_yaw,
		OrbitRig.DEFAULT_YAW - 40.0 * OrbitRig.DEGREES_PER_POINT, 1e-6)


func test_a_finger_does_not_turn_before_it_leaves_the_tap_slop() -> void:
	_gestures.handle(_touch(0, Vector2(100, 100), true), 0.0)
	_gestures.handle(_drag(0, Vector2(106, 104), Vector2(6, 4)), 0.016)
	assert_eq(_rig.goal_yaw, OrbitRig.DEFAULT_YAW, "the second finger may be landing")
	assert_eq(_rig.goal_pitch, OrbitRig.DEFAULT_PITCH)
	_gestures.handle(_drag(0, Vector2(112, 104), Vector2(6, 0)), 0.032)
	assert_almost_eq(_rig.goal_yaw,
		OrbitRig.DEFAULT_YAW - 6.0 * OrbitRig.DEGREES_PER_POINT, 1e-6)


func test_a_pinch_stops_a_fling() -> void:
	_gestures.handle(_touch(0, Vector2(100, 100), true), 0.0)
	_gestures.handle(_drag(0, Vector2(160, 100), Vector2(60, 0)), 0.016)
	_gestures.handle(_touch(0, Vector2(160, 100), false), 0.032)
	_gestures.handle(_touch(0, Vector2(100, 100), true), 0.05)
	_gestures.handle(_touch(1, Vector2(200, 100), true), 0.05)
	var pinched := _rig.goal_yaw
	_rig.step(1.0)
	assert_eq(_rig.goal_yaw, pinched)
	_gestures.handle(_touch(1, Vector2(200, 100), false), 1.1)
	_gestures.handle(_touch(0, Vector2(100, 100), false), 1.1)
	_rig.step(1.0)
	assert_eq(_rig.goal_yaw, pinched)


## Two fingers, the second landing and pinching outwards: the view zooms in.
func _pinch() -> void:
	_gestures.handle(_touch(0, Vector2(100, 100), true), 0.0)
	_gestures.handle(_touch(1, Vector2(200, 100), true), 0.02)
	_gestures.handle(_drag(1, Vector2(300, 100), Vector2(100, 0)), 0.036)
	assert_almost_eq(_rig.goal_distance, OrbitRig.DEFAULT_DISTANCE / 2.0, 1e-4)


func _touch(index: int, position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	return event


func _drag(index: int, position: Vector2, relative: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	event.relative = relative
	return event
