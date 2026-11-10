extends TestCase
## The frame rate capped while the view stands still, and lifted as soon
## as it moves.

var _camera: OrbitCamera
var _cap: IdleFrameCap


func before_each() -> void:
	_camera = OrbitCamera.new()
	_cap = IdleFrameCap.new(_camera)
	_root().add_child(_cap)


func after_each() -> void:
	_cap.free()
	_camera.free()


func test_caps_once_the_view_stood_still_a_moment() -> void:
	_cap._process(IdleFrameCap.IDLE_DELAY / 2.0)
	assert_false(_cap.is_capped())
	_cap._process(IdleFrameCap.IDLE_DELAY / 2.0)
	assert_true(_cap.is_capped())
	assert_eq(Engine.max_fps, 30)


func test_lifts_the_cap_when_the_view_moves() -> void:
	_cap._process(IdleFrameCap.IDLE_DELAY)
	_camera.rig.zoom(0.5)
	_cap._process(0.016)
	assert_false(_cap.is_capped())
	assert_eq(Engine.max_fps, 0)


func test_never_caps_when_disabled() -> void:
	_cap._process(IdleFrameCap.IDLE_DELAY)
	_cap.enabled = false
	assert_eq(Engine.max_fps, 0)
	_cap._process(IdleFrameCap.IDLE_DELAY * 2.0)
	assert_false(_cap.is_capped())


func test_gives_the_frame_rate_back_when_it_leaves() -> void:
	_cap._process(IdleFrameCap.IDLE_DELAY)
	_root().remove_child(_cap)
	assert_eq(Engine.max_fps, 0)


func _root() -> Window:
	return (Engine.get_main_loop() as SceneTree).root
