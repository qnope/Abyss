extends TestCase
## The base's camera: on the game's 3/4 view at first, it follows the
## player's gestures through its OrbitRig, and tells a tap.

var _camera: OrbitCamera
var _taps: Array[Vector2] = []


func before_each() -> void:
	_camera = OrbitCamera.new()
	_camera.tapped.connect(_taps.append)
	_root().add_child(_camera)


func after_each() -> void:
	_camera.free()


func test_frames_the_base_as_the_game_view() -> void:
	assert_eq(_camera.fov, OrbitCamera.FOV)
	assert_eq(_camera.keep_aspect, Camera3D.KEEP_WIDTH)
	assert_true(_camera.transform.is_equal_approx(OrbitRig.new().transform()))
	assert_false(_camera.is_moving())


func test_follows_a_drag_frame_by_frame() -> void:
	_root().push_input(_touch(Vector2(100, 100), true))
	assert_true(_camera.is_moving(), "a finger is down")
	_root().push_input(_drag(Vector2(160, 100), Vector2(60, 0)))
	_root().push_input(_touch(Vector2(160, 100), false))
	var before := _camera.transform
	_camera._process(1.0 / 60.0)
	assert_false(_camera.transform.is_equal_approx(before))
	assert_true(_camera.transform.is_equal_approx(_camera.rig.transform()))
	assert_true(_camera.is_moving(), "it eases on")
	for i in 600:
		_camera._process(1.0 / 60.0)
	assert_false(_camera.is_moving())
	assert_eq(_taps.size(), 0)


func test_tells_a_tap() -> void:
	_root().push_input(_touch(Vector2(30, 40), true))
	_root().push_input(_touch(Vector2(30, 40), false))
	assert_eq(_taps.size(), 1, "in the viewport's coordinates, past the window's stretch")


func test_fits_its_default_view_to_an_upright_phone_and_to_a_desktop() -> void:
	var screen := SubViewport.new()
	_root().add_child(screen)
	var camera := OrbitCamera.new()
	screen.add_child(camera)
	var outline := PackedVector3Array([Vector3(8, 0, 8), Vector3(-8, 0, -8), Vector3(8, 0, -8),
		Vector3(-8, 0, 8)])
	screen.size = Vector2i(390, 844)
	camera.fit(outline, 0.1)
	assert_eq(camera.keep_aspect, Camera3D.KEEP_WIDTH)
	var upright := OrbitFrame.fit(outline, 45.0, -50.0, 390.0 / 844.0, OrbitCamera.FOV, 0.1)
	assert_almost_eq(camera.rig.default_distance, upright.x, 1e-4)
	assert_almost_eq(camera.rig.lift, upright.y, 1e-4)
	assert_true(camera.transform.is_equal_approx(camera.rig.transform()))
	screen.size = Vector2i(1600, 900)
	camera.fit(outline, 0.1)
	assert_eq(camera.keep_aspect, Camera3D.KEEP_HEIGHT)
	screen.free()


func _touch(position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.position = position
	event.pressed = pressed
	return event


func _drag(position: Vector2, relative: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.position = position
	event.relative = relative
	return event


func _root() -> Window:
	return (Engine.get_main_loop() as SceneTree).root
