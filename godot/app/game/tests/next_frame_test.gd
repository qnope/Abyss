extends TestCase
## The wait for the next frame: the frame it is asked in is told again
## before it is drawn, and only the one after it ends the wait.

var _frames := ManualFrames.new()
var _wait := _frames.next_frame()
var _came: Array[bool] = []


func before_each() -> void:
	_wait.came.connect(_came.append.bind(true))


func test_tells_nothing_until_asked() -> void:
	_frames.pass_one()
	assert_false(_wait.is_waiting())
	assert_eq(_came.size(), 0)


func test_tells_the_frame_after_the_one_it_was_asked_in() -> void:
	_wait.wait()
	assert_true(_wait.is_waiting())
	_frames.tell()
	assert_eq(_came.size(), 0, "the frame of the touch is not drawn yet")
	assert_true(_wait.is_waiting())
	_frames.pass_one()
	assert_eq(_came.size(), 1)
	assert_false(_wait.is_waiting())


func test_tells_once_however_many_times_it_was_asked() -> void:
	_wait.wait()
	_wait.wait()
	_frames.pass_one()
	_frames.pass_one()
	assert_eq(_came.size(), 1)


func test_waits_again_once_it_has_told() -> void:
	_wait.wait()
	_frames.pass_one()
	_wait.wait()
	_frames.tell()
	assert_eq(_came.size(), 1)
	_frames.pass_one()
	assert_eq(_came.size(), 2)


func test_a_wait_cancelled_tells_nothing() -> void:
	_wait.cancel()
	_wait.wait()
	_wait.cancel()
	assert_false(_wait.is_waiting())
	_frames.pass_one()
	assert_eq(_came.size(), 0)


func test_whoever_is_told_can_ask_for_the_frame_after() -> void:
	_wait.came.connect(_wait.wait, CONNECT_ONE_SHOT)
	_wait.wait()
	_frames.pass_one()
	assert_true(_wait.is_waiting())
	_frames.pass_one()
	assert_eq(_came.size(), 2)


func test_waits_on_the_scene_tree_unless_given_other_frames() -> void:
	var frames := (Engine.get_main_loop() as SceneTree).process_frame
	var wait := NextFrame.new()
	wait.came.connect(_came.append.bind(true))
	wait.wait()
	assert_true(frames.is_connected(wait._on_frame))
	wait._on_frame()
	assert_eq(_came.size(), 0, "the tests run in one frame")
	wait.cancel()
	assert_false(frames.is_connected(wait._on_frame))


func test_a_wait_let_go_leaves_the_scene_tree() -> void:
	var frames := (Engine.get_main_loop() as SceneTree).process_frame
	var listeners := frames.get_connections().size()
	var wait := NextFrame.new()
	wait.wait()
	assert_eq(frames.get_connections().size(), listeners + 1)
	wait = null
	assert_eq(frames.get_connections().size(), listeners)
