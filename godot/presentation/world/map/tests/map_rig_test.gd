extends TestCase
## The pan's maths: a drag moves a goal over the map the view eases to, and a
## drag released while moving flings the view on until friction, or the edge
## of the map, stops it.

const FRAME := 1.0 / 60.0

var _rig: MapRig


func before_each() -> void:
	_rig = MapRig.new()
	_rig.bounds = Rect2(-13.0, -13.0, 26.0, 26.0)


func _steps(count: int) -> void:
	for i in count:
		_rig.step(FRAME)


## How far a drag of [param points] moves the goal, in metres.
func _metres(points: float) -> float:
	return points * MapRig.PAN_PER_POINT * _rig.distance


func test_a_drag_moves_the_goal_at_once_and_the_view_by_a_share_per_step() -> void:
	_rig.drag(Vector2(100.0, 50.0), FRAME)
	assert_true(_rig.goal_target.is_equal_approx(Vector3(-_metres(100.0), 0.0, -_metres(50.0))))
	assert_eq(_rig.target, Vector3.ZERO)
	assert_false(_rig.is_settled())
	_rig.step(FRAME)
	var share := 1.0 - exp(-OrbitRig.SMOOTHING * FRAME)
	assert_true(_rig.target.is_equal_approx(_rig.goal_target * share), str(_rig.target))


func test_the_view_ends_on_its_goal_exactly() -> void:
	_rig.drag(Vector2(40.0, 20.0), FRAME)
	var goal := _rig.goal_target
	_steps(120)
	assert_eq(_rig.target, goal, "a finger at rest lets the view catch up")
	assert_true(_rig.is_settled())


func test_the_goal_and_the_view_stay_within_the_map() -> void:
	for corner: Vector2 in [Vector2(-1e6, -1e6), Vector2(1e6, 1e6)]:
		_rig.drag(corner, FRAME)
		assert_eq(Vector2(_rig.goal_target.x, _rig.goal_target.z).abs(), Vector2(13.0, 13.0))
		for i in 120:
			_rig.step(FRAME)
			assert_true(absf(_rig.target.x) <= 13.0 and absf(_rig.target.z) <= 13.0, str(_rig.target))
		assert_eq(_rig.target, _rig.goal_target)


func test_a_released_drag_flings_on_then_friction_stops_it() -> void:
	_rig.drag(Vector2(-6.0, 3.0), FRAME)
	var released := _rig.goal_target
	_rig.release()
	_rig.step(FRAME)
	assert_true(_rig.goal_target.x > released.x and _rig.goal_target.z < released.z, "it goes on the same way")
	assert_false(_rig.is_settled())
	_steps(600)
	assert_true(_rig.is_settled())
	assert_eq(_rig.target, _rig.goal_target)
	assert_true(_rig.goal_target.x < 13.0 and _rig.goal_target.z > -13.0, "short of the edge")
	var stopped := _rig.goal_target
	_rig.step(FRAME)
	assert_eq(_rig.goal_target, stopped)


func test_a_fling_is_never_faster_than_the_top_speed() -> void:
	_rig.bounds = Rect2(-1e4, -1e4, 2e4, 2e4)
	_rig.drag(Vector2(-3000.0, -4000.0), FRAME)
	var released := _rig.goal_target
	_rig.release()
	_rig.step(FRAME)
	var moved := _rig.goal_target.distance_to(released)
	assert_true(moved > 0.0 and moved <= MapRig.MAX_PAN_FLING * FRAME, str(moved))


func test_a_fling_stops_at_the_edge_of_the_map() -> void:
	_rig.place(Vector3(11.0, 0.0, 11.0))
	_rig.drag(Vector2(-12.0, -12.0), FRAME)
	assert_true(_rig.goal_target.x < 13.0 and _rig.goal_target.z < 13.0)
	_rig.release()
	_steps(60)
	assert_eq(_rig.goal_target, Vector3(13.0, 0.0, 13.0))
	assert_eq(_rig.target, Vector3(13.0, 0.0, 13.0))
	assert_true(_rig.is_settled(), "friction alone would take longer")


func test_a_fling_slides_along_the_edge_it_meets() -> void:
	_rig.place(Vector3(11.0, 0.0, 0.0))
	_rig.drag(Vector2(-12.0, -6.0), FRAME)
	_rig.release()
	_steps(30)
	var met := _rig.goal_target
	assert_eq(met.x, 13.0)
	_rig.step(FRAME)
	assert_true(_rig.goal_target.z > met.z and _rig.goal_target.x == 13.0)


func test_a_finger_held_still_before_lifting_does_not_fling() -> void:
	_rig.drag(Vector2(-30.0, 0.0), FRAME)
	_steps(30)
	var held := _rig.goal_target
	_rig.release()
	_rig.step(FRAME)
	assert_eq(_rig.goal_target, held)


func test_holding_stops_a_fling_at_once() -> void:
	_rig.drag(Vector2(-6.0, 0.0), FRAME)
	_rig.release()
	_rig.step(FRAME)
	_rig.hold()
	var held := _rig.goal_target
	_rig.release()
	_steps(60)
	assert_eq(_rig.goal_target, held)
	assert_true(_rig.is_settled())


func test_placing_the_view_leaves_nothing_easing() -> void:
	_rig.drag(Vector2(-6.0, 3.0), FRAME)
	_rig.release()
	_rig.place(Vector3(3.0, 0.0, -2.0))
	assert_true(_rig.is_settled())
	_rig.step(FRAME)
	assert_eq(_rig.target, Vector3(3.0, 0.0, -2.0))
	assert_eq(_rig.goal_target, Vector3(3.0, 0.0, -2.0))
	_rig.place(Vector3(100.0, 5.0, -100.0))
	assert_eq(_rig.target, Vector3(13.0, 0.0, -13.0), "over the map")


func test_home_puts_the_view_on_the_middle_with_nothing_easing() -> void:
	_rig.drag(Vector2(-6.0, 3.0), FRAME)
	_rig.zoom(0.5)
	_rig.release()
	_rig.step(FRAME)
	_rig.home()
	assert_true(_rig.is_settled())
	_rig.step(FRAME)
	assert_eq(_rig.target, Vector3.ZERO)
	assert_eq(_rig.goal_target, Vector3.ZERO)
	assert_eq(_rig.distance, _rig.default_distance)
