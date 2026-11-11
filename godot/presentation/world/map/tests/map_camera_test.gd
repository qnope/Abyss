extends MapTestCase
## The view of the map: it pans after a drag, within the map, zooms on a pinch
## and is fitted to the screen.

var _camera: MapCamera


func before_each() -> void:
	_camera = mounted(MapCamera.new()) as MapCamera
	_camera.fit_map(26, 26, 0.1, 0.1)


func _drag(points: Vector2) -> void:
	_camera.rig.drag(points, 0.016)


func test_looks_down_at_the_map_from_its_front_and_never_turns() -> void:
	assert_eq(_camera.rig.yaw, MapRig.YAW)
	assert_eq(_camera.rig.pitch, MapRig.PITCH)
	_drag(Vector2(300.0, 200.0))
	_camera.rig.step(1.0)
	assert_eq(_camera.rig.yaw, MapRig.YAW)
	assert_eq(_camera.rig.pitch, MapRig.PITCH)


func test_a_drag_moves_the_map_under_the_finger() -> void:
	var before := _camera.rig.target
	_drag(Vector2(100.0, 0.0))
	assert_true(_camera.rig.target.x < before.x, "dragging right shows what lies to the left")
	_drag(Vector2(0.0, 100.0))
	assert_true(_camera.rig.target.z < before.z, "dragging down shows what lies behind")
	assert_eq(_camera.rig.target.y, 0.0)


func test_the_farther_the_view_the_more_a_drag_moves() -> void:
	_camera.rig.zoom(0.5)
	_camera.rig.step(5.0)
	var near := _camera.rig.target
	_drag(Vector2(100.0, 0.0))
	var near_move := near.x - _camera.rig.target.x
	_camera.pan.home()
	_camera.rig.zoom(2.0)
	_camera.rig.step(5.0)
	_drag(Vector2(100.0, 0.0))
	assert_true(-_camera.rig.target.x > near_move)


func test_the_view_stays_within_the_map() -> void:
	for corner: Vector2 in [Vector2(-1e6, -1e6), Vector2(1e6, 1e6)]:
		_drag(corner)
		assert_eq(Vector2(_camera.rig.target.x, _camera.rig.target.z).abs(), Vector2(13.0, 13.0))


func test_a_pinch_zooms_between_the_bounds_of_the_orbit() -> void:
	var fitted := _camera.rig.default_distance
	_camera.rig.zoom(0.1)
	assert_eq(_camera.rig.goal_distance, OrbitRig.MIN_DISTANCE)
	_camera.rig.zoom(100.0)
	assert_eq(_camera.rig.goal_distance, _camera.rig.max_distance)
	assert_true(_camera.rig.max_distance >= fitted, "never nearer than the whole map")


func test_the_fitted_view_shows_the_whole_map_between_the_bars() -> void:
	var size := _camera.get_viewport().get_visible_rect().size
	var fitted := OrbitFrame.fit(MapGrid.outline(26, 26), MapRig.YAW, MapRig.PITCH,
		size.x / size.y, OrbitCamera.FOV, 0.1, 0.1)
	assert_almost_eq(_camera.rig.default_distance, fitted.x, 1e-4)
	var tans := OrbitFrame.tangents(size.x / size.y, OrbitCamera.FOV)
	var bounds := OrbitFrame.project(MapGrid.outline(26, 26), MapRig.YAW, MapRig.PITCH,
		fitted.x, fitted.y * fitted.x, tans)
	assert_true(bounds.position.x >= -1.0 and bounds.end.x <= 1.0)
	assert_true(bounds.position.y >= -1.0 and bounds.end.y <= 1.0)


func test_home_puts_the_view_back_on_the_middle_of_the_map() -> void:
	_drag(Vector2(100.0, 50.0))
	_camera.rig.zoom(0.5)
	_camera.home()
	assert_eq(_camera.rig.target, Vector3.ZERO)
	assert_eq(_camera.rig.distance, _camera.rig.default_distance)
	assert_eq(_camera.transform, _camera.rig.transform())


func test_tells_a_tap_of_the_gestures() -> void:
	var taps: Array[Vector2] = []
	_camera.tapped.connect(taps.append)
	var touch := InputEventScreenTouch.new()
	touch.position = Vector2(50.0, 60.0)
	touch.pressed = true
	_camera._unhandled_input(touch)
	touch = touch.duplicate()
	touch.pressed = false
	_camera._unhandled_input(touch)
	assert_eq(taps, [Vector2(50.0, 60.0)] as Array[Vector2])
