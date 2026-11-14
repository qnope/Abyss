extends TestCase
## The gestures that move the orbit: one finger or the mouse turns it, two
## fingers, the wheel or a trackpad zoom it, and a touch that barely moved
## is a tap.

var _rig: OrbitRig
var _gestures: OrbitGestures
var _taps: Array[Vector2] = []


func before_each() -> void:
	_rig = OrbitRig.new()
	_gestures = OrbitGestures.new(_rig)
	_gestures.tapped.connect(_taps.append)


func test_one_finger_turns_the_view() -> void:
	assert_true(_gestures.handle(_touch(0, Vector2(100, 100), true), 0.0))
	assert_true(_gestures.is_touching())
	assert_true(_gestures.handle(_drag(0, Vector2(140, 100), Vector2(40, 0)), 0.016))
	assert_almost_eq(_rig.goal_yaw, 45.0 - 40.0 * OrbitRig.DEGREES_PER_POINT, 1e-6)
	_gestures.handle(_touch(0, Vector2(140, 100), false), 0.032)
	assert_false(_gestures.is_touching())
	assert_eq(_taps, [] as Array[Vector2])


func test_a_finger_put_down_lets_the_orbit_fling_on() -> void:
	_rig.drag(Vector2(60.0, 0.0), 1.0 / 60.0)
	_rig.release()
	_gestures.handle(_touch(0, Vector2(100, 100), true), 0.0)
	var yaw := _rig.goal_yaw
	_rig.step(1.0 / 60.0)
	assert_ne(_rig.goal_yaw, yaw, "the base turns on under the finger until it drags")


func test_a_touch_that_barely_moves_is_a_tap() -> void:
	_gestures.handle(_touch(0, Vector2(100, 100), true), 0.0)
	_gestures.handle(_drag(0, Vector2(104, 102), Vector2(4, 2)), 0.016)
	_gestures.handle(_touch(0, Vector2(104, 102), false), 0.1)
	assert_eq(_taps, [Vector2(104, 102)] as Array[Vector2])


func test_a_cancelled_touch_is_no_tap() -> void:
	_gestures.handle(_touch(0, Vector2(100, 100), true), 0.0)
	var cancel := _touch(0, Vector2(100, 100), false)
	cancel.canceled = true
	_gestures.handle(cancel, 0.1)
	assert_eq(_taps.size(), 0)


func test_two_fingers_pinch_to_zoom_and_tap_nothing() -> void:
	_gestures.handle(_touch(0, Vector2(100, 100), true), 0.0)
	_gestures.handle(_touch(1, Vector2(200, 100), true), 0.0)
	_gestures.handle(_drag(1, Vector2(300, 100), Vector2(100, 0)), 0.016)
	assert_almost_eq(_rig.goal_distance, OrbitRig.DEFAULT_DISTANCE / 2.0, 1e-4)
	assert_eq(_rig.goal_yaw, 45.0, "a pinch does not turn")
	_gestures.handle(_touch(1, Vector2(300, 100), false), 0.1)
	_gestures.handle(_touch(0, Vector2(100, 100), false), 0.2)
	assert_eq(_taps.size(), 0)


func test_a_drag_of_an_unknown_finger_is_left() -> void:
	assert_false(_gestures.handle(_drag(3, Vector2(10, 10), Vector2(10, 0)), 0.0))
	assert_eq(_rig.goal_yaw, 45.0)


func test_the_mouse_turns_the_view_and_clicks() -> void:
	assert_true(_gestures.handle(_button(MOUSE_BUTTON_LEFT, true, Vector2(50, 50)), 0.0))
	assert_true(_gestures.handle(_motion(Vector2(70, 50), Vector2(20, 0)), 0.016))
	assert_almost_eq(_rig.goal_yaw, 45.0 - 20.0 * OrbitRig.DEGREES_PER_POINT, 1e-6)
	_gestures.handle(_button(MOUSE_BUTTON_LEFT, false, Vector2(70, 50)), 0.05)
	_gestures.handle(_button(MOUSE_BUTTON_LEFT, true, Vector2(10, 10)), 1.0)
	_gestures.handle(_button(MOUSE_BUTTON_LEFT, false, Vector2(10, 10)), 1.1)
	assert_eq(_taps, [Vector2(10, 10)] as Array[Vector2])


func test_a_mouse_moving_without_its_button_does_nothing() -> void:
	assert_false(_gestures.handle(_motion(Vector2(70, 50), Vector2(20, 0)), 0.0))
	assert_false(_gestures.handle(_button(MOUSE_BUTTON_RIGHT, true, Vector2(5, 5)), 0.0))
	assert_eq(_rig.goal_yaw, 45.0)


func test_ignores_the_mouse_emulated_from_a_touch() -> void:
	var press := _button(MOUSE_BUTTON_LEFT, true, Vector2(50, 50))
	press.device = InputEvent.DEVICE_ID_EMULATION
	assert_false(_gestures.handle(press, 0.0))
	var motion := _motion(Vector2(70, 50), Vector2(20, 0))
	motion.device = InputEvent.DEVICE_ID_EMULATION
	assert_false(_gestures.handle(motion, 0.0))
	assert_false(_gestures.is_touching())


func test_the_wheel_zooms_by_notches() -> void:
	_gestures.handle(_button(MOUSE_BUTTON_WHEEL_UP, true, Vector2.ZERO), 0.0)
	assert_almost_eq(_rig.goal_distance, OrbitRig.DEFAULT_DISTANCE / OrbitGestures.WHEEL_STEP, 1e-4)
	var smooth := _button(MOUSE_BUTTON_WHEEL_DOWN, true, Vector2.ZERO)
	smooth.factor = 2.0
	_gestures.handle(smooth, 0.0)
	assert_almost_eq(_rig.goal_distance, OrbitRig.DEFAULT_DISTANCE * OrbitGestures.WHEEL_STEP, 1e-4)


func test_a_trackpad_pinches_and_scrolls_to_zoom() -> void:
	var magnify := InputEventMagnifyGesture.new()
	magnify.factor = 1.25
	assert_true(_gestures.handle(magnify, 0.0))
	assert_almost_eq(_rig.goal_distance, OrbitRig.DEFAULT_DISTANCE / 1.25, 1e-4)
	var pan := InputEventPanGesture.new()
	pan.delta = Vector2(0.0, 10.0)
	assert_true(_gestures.handle(pan, 0.0))
	assert_almost_eq(_rig.goal_distance,
		OrbitRig.DEFAULT_DISTANCE / 1.25 * (1.0 + 10.0 * OrbitGestures.PAN_ZOOM), 1e-4)


func test_leaves_other_events() -> void:
	assert_false(_gestures.handle(InputEventKey.new(), 0.0))


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


func _button(button: MouseButton, pressed: bool, position: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.position = position
	return event


func _motion(position: Vector2, relative: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.relative = relative
	return event
