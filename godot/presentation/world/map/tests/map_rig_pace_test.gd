extends TestCase
## Why the pan is eased: a browser does not hand the touch's moves in step with
## the frames, and the view must not show it. Then the bounds changing under
## the view.

const FRAME := 1.0 / 60.0

var _rig: MapRig


func before_each() -> void:
	_rig = MapRig.new()
	_rig.bounds = Rect2(-100.0, -100.0, 200.0, 200.0)


func test_drags_delivered_unevenly_move_the_view_at_a_steady_pace() -> void:
	var even := 3.0 * MapRig.PAN_PER_POINT * _rig.distance
	var goal_moves: Array[float] = []
	var view_moves: Array[float] = []
	for frame in 100:
		var goal := _rig.goal_target.x
		var view := _rig.target.x
		if frame % 2 == 1:
			_rig.drag(Vector2(-6.0, 0.0), 2.0 * FRAME)
		_rig.step(FRAME)
		if frame >= 60:
			goal_moves.append(_rig.goal_target.x - goal)
			view_moves.append(_rig.target.x - view)
	var least: float = goal_moves.min()
	var most: float = goal_moves.max()
	assert_eq(least, 0.0, "the finger's moves come one frame in two")
	assert_almost_eq(most, 2.0 * even, 1e-4)
	least = view_moves.min()
	most = view_moves.max()
	assert_true(least > 0.85 * even, "the view never stands still: %f of %f" % [least, even])
	assert_true(most < 1.15 * even, "nor jumps: %f of %f" % [most, even])


func test_drags_delivered_evenly_move_the_view_as_far_as_the_finger() -> void:
	var even := 3.0 * MapRig.PAN_PER_POINT * _rig.distance
	for frame in 60:
		_rig.drag(Vector2(-3.0, 0.0), FRAME)
		_rig.step(FRAME)
	var view := _rig.target.x
	_rig.drag(Vector2(-3.0, 0.0), FRAME)
	_rig.step(FRAME)
	assert_almost_eq(_rig.target.x - view, even, 1e-4)


func test_smaller_bounds_bring_the_goal_and_then_the_view_inside() -> void:
	_rig.drag(Vector2(-1e6, 1e6), FRAME)
	assert_eq(_rig.goal_target, Vector3(100.0, 0.0, -100.0))
	_rig.bounds = Rect2(-4.0, -3.0, 8.0, 6.0)
	assert_eq(_rig.goal_target, Vector3(4.0, 0.0, -3.0))
	assert_false(_rig.is_settled())
	for i in 120:
		_rig.step(FRAME)
	assert_eq(_rig.target, Vector3(4.0, 0.0, -3.0))
	assert_true(_rig.is_settled())
