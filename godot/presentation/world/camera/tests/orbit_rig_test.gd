extends TestCase
## The orbit maths: the default 3/4 view, drags and pinches setting goals the
## view eases to, clamped, and a fling spinning on until friction stops it.

var _rig: OrbitRig


func before_each() -> void:
	_rig = OrbitRig.new()


func test_starts_on_the_game_view_settled() -> void:
	assert_eq(_rig.yaw, 45.0)
	assert_eq(_rig.pitch, -50.0)
	assert_eq(_rig.distance, OrbitRig.DEFAULT_DISTANCE)
	assert_true(_rig.is_settled())


func test_looks_at_its_target_from_the_front_corner() -> void:
	var transform := _rig.transform()
	var forward := -transform.basis.z
	assert_true(transform.origin.x > 0.0 and transform.origin.z > 0.0)
	assert_almost_eq(transform.origin.x, transform.origin.z, 1e-4)
	assert_almost_eq(transform.origin.length(), OrbitRig.DEFAULT_DISTANCE, 1e-4)
	assert_true(forward.is_equal_approx(-transform.origin.normalized()))
	assert_almost_eq(rad_to_deg(asin(forward.y)), -50.0, 1e-3)


func test_a_drag_turns_the_goal_and_the_view_eases_to_it() -> void:
	_rig.drag(Vector2(100.0, 0.0), 0.1)
	assert_almost_eq(_rig.goal_yaw, 45.0 - 100.0 * OrbitRig.DEGREES_PER_POINT, 1e-6)
	assert_eq(_rig.yaw, 45.0)
	assert_false(_rig.is_settled())
	_rig.step(1.0 / 60.0)
	assert_true(_rig.yaw < 45.0 and _rig.yaw > _rig.goal_yaw)


func test_a_vertical_drag_tilts_within_its_bounds() -> void:
	_rig.drag(Vector2(0.0, -10000.0), 0.1)
	assert_eq(_rig.goal_pitch, OrbitRig.MAX_PITCH)
	_rig.drag(Vector2(0.0, 10000.0), 0.1)
	assert_eq(_rig.goal_pitch, OrbitRig.MIN_PITCH)


func test_zooms_within_its_bounds() -> void:
	_rig.zoom(0.5)
	assert_almost_eq(_rig.goal_distance, OrbitRig.DEFAULT_DISTANCE * 0.5, 1e-6)
	_rig.zoom(0.01)
	assert_eq(_rig.goal_distance, OrbitRig.MIN_DISTANCE)
	_rig.zoom(100.0)
	assert_eq(_rig.goal_distance, OrbitRig.MAX_DISTANCE)


func test_settles_on_its_goal() -> void:
	_rig.drag(Vector2(40.0, 20.0), 0.5)
	_rig.zoom(0.8)
	_rig.release()
	for i in 600:
		_rig.step(1.0 / 60.0)
	assert_true(_rig.is_settled())
	assert_eq(_rig.yaw, _rig.goal_yaw)
	assert_eq(_rig.pitch, _rig.goal_pitch)
	assert_eq(_rig.distance, _rig.goal_distance)


func test_a_fling_spins_on_then_stops() -> void:
	_rig.drag(Vector2(-30.0, 0.0), 1.0 / 60.0)
	var released := _rig.goal_yaw
	_rig.release()
	_rig.step(1.0 / 60.0)
	assert_true(_rig.goal_yaw > released, "it goes on turning the same way")
	for i in 600:
		_rig.step(1.0 / 60.0)
	assert_true(_rig.is_settled())
	var stopped := _rig.goal_yaw
	_rig.step(1.0 / 60.0)
	assert_eq(_rig.goal_yaw, stopped)


func test_a_finger_held_still_before_lifting_does_not_fling() -> void:
	_rig.drag(Vector2(-30.0, 0.0), 1.0 / 60.0)
	for i in 30:
		_rig.step(1.0 / 60.0)
	var held := _rig.goal_yaw
	_rig.release()
	_rig.step(1.0 / 60.0)
	assert_almost_eq(_rig.goal_yaw, held, 0.01)


func test_a_drag_in_no_time_counts_as_one_frame() -> void:
	_rig.drag(Vector2(-10.0, 0.0), 0.0)
	_rig.release()
	_rig.step(1.0 / 60.0)
	assert_true(_rig.goal_yaw > 45.0 + 10.0 * OrbitRig.DEGREES_PER_POINT)


func test_look_snaps_the_view_and_stops_a_fling() -> void:
	_rig.drag(Vector2(-30.0, 0.0), 1.0 / 60.0)
	_rig.release()
	_rig.look(120.0, -70.0, 500.0)
	assert_eq(_rig.yaw, 120.0)
	assert_eq(_rig.pitch, -70.0)
	assert_eq(_rig.distance, OrbitRig.MAX_DISTANCE)
	_rig.step(1.0 / 60.0)
	assert_eq(_rig.yaw, 120.0)
	assert_true(_rig.is_settled())


func test_keeps_its_angles_small_after_many_turns() -> void:
	_rig.look(45.0 + 360.0 * 3.0, -50.0, 20.0)
	_rig.step(1.0 / 60.0)
	assert_almost_eq(_rig.yaw, 45.0, 1e-6)
	assert_almost_eq(_rig.goal_yaw, 45.0, 1e-6)
