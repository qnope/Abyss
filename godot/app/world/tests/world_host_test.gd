extends TestCase
## The 3D world behind the screens: the base, drifting while a menu shows and
## the player's once a game is played.

var _world: WorldHost


func before_each() -> void:
	_world = WorldHost.new()
	add_child_to_window(_world)


func after_each() -> void:
	_world.free()


func test_shows_the_base_through_its_camera() -> void:
	assert_true(_world.base.camera.current)
	assert_eq(_world.base.buildings.names(), BaseScene.BUILT)


func test_drifts_around_the_island_out_of_reach_of_the_touches() -> void:
	assert_true(_world.drifting)
	assert_false(_world.base.camera.is_processing_unhandled_input())
	var yaw := _world.base.camera.rig.goal_yaw
	_world._process(2.0)
	assert_almost_eq(_world.base.camera.rig.goal_yaw, yaw + 2.0 * WorldHost.DRIFT, 1e-4)


func test_gives_the_camera_to_the_player() -> void:
	_world.set_drifting(false)
	assert_false(_world.drifting)
	assert_true(_world.base.camera.is_processing_unhandled_input())
	assert_false(_world.is_processing())
	_world.set_drifting(true)
	assert_true(_world.is_processing())


func test_frames_the_island_under_the_title() -> void:
	var size := _world.get_viewport().get_visible_rect().size
	var fitted := OrbitFrame.fit(BaseScene.OUTLINE, OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH,
		size.x / size.y, OrbitCamera.FOV, WorldHost.HUD)
	assert_almost_eq(_world.base.camera.rig.default_distance, fitted.x, 1e-4)
	assert_almost_eq(_world.base.camera.rig.lift, fitted.y, 1e-4)


func add_child_to_window(node: Node) -> void:
	(Engine.get_main_loop() as SceneTree).root.add_child(node)
