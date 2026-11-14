extends TestCase
## Where a bench puts the camera: a turn round the base, a loop over the map.


func test_orbits_the_base_once_zooming() -> void:
	var rig := OrbitRig.new()
	rig.frame(25.0, 0.0)
	BenchPose.orbit(0.25, 0.5, rig)
	assert_almost_eq(rig.yaw, OrbitRig.DEFAULT_YAW + 90.0, 1e-3)
	assert_almost_eq(rig.distance, 12.5, 1e-3)
	BenchPose.orbit(0.0, 1.0, rig)
	assert_eq(rig.yaw, OrbitRig.DEFAULT_YAW)
	assert_eq(rig.distance, 25.0)


func test_loops_over_the_map_without_turning_the_view() -> void:
	var rig := MapRig.new()
	rig.bounds = Rect2(-13.0, -13.0, 26.0, 26.0)
	rig.frame(40.0, 0.0)
	BenchPose.pan(0.0, 1.0, rig)
	assert_eq(rig.target, Vector3.ZERO, "it starts on the middle")
	assert_eq(rig.distance, 40.0)
	BenchPose.pan(0.25, 0.6, rig)
	assert_eq(rig.yaw, MapRig.YAW)
	assert_eq(rig.pitch, MapRig.PITCH)
	assert_almost_eq(rig.distance, 24.0, 1e-3)
	assert_almost_eq(rig.target.x, 26.0 * BenchPose.PAN_REACH, 1e-4)
	BenchPose.pan(0.5, 1.0, rig)
	assert_almost_eq(rig.target.z, -26.0 * BenchPose.PAN_REACH, 1e-4)
	assert_true(Rect2(-13.0, -13.0, 26.0, 26.0).has_point(Vector2(rig.target.x, rig.target.z)), "over the map")


func test_puts_the_view_where_no_drag_pulls_it_from() -> void:
	var rig := MapRig.new()
	rig.bounds = Rect2(-13.0, -13.0, 26.0, 26.0)
	rig.frame(40.0, 0.0)
	rig.drag(Vector2(-200.0, 100.0), 1.0 / 60.0)
	rig.release()
	rig.step(1.0 / 60.0)
	BenchPose.pan(0.25, 1.0, rig)
	var put := rig.target
	assert_true(rig.is_settled())
	rig.step(1.0 / 60.0)
	assert_eq(rig.target, put)
