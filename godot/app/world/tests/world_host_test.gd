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


func test_shows_the_base_of_a_game_in_place_of_the_ambience() -> void:
	var player := GameSamples.player_with("Nemo", {BuildingType.Value.HEADQUARTERS: 1})
	_world.show_game(player.buildings)
	assert_eq(_world.base.buildings.names(), [&"Headquarters"] as Array[StringName])
	_world.show_ambience()
	assert_eq(_world.base.buildings.names(), BaseScene.BUILT)


func test_frames_the_island_between_the_bars_of_the_game() -> void:
	_world.frame_between(0.1, 0.2)
	var size := _world.get_viewport().get_visible_rect().size
	var fitted := OrbitFrame.fit(BaseScene.OUTLINE, OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH,
		size.x / size.y, OrbitCamera.FOV, 0.1, 0.2)
	assert_almost_eq(_world.base.camera.rig.default_distance, fitted.x, 1e-4)
	_world.get_viewport().size_changed.emit()
	assert_almost_eq(_world.base.camera.rig.default_distance, fitted.x, 1e-4, "kept on a resize")
	_world.show_ambience()
	var under_the_title := OrbitFrame.fit(BaseScene.OUTLINE, OrbitRig.DEFAULT_YAW,
		OrbitRig.DEFAULT_PITCH, size.x / size.y, OrbitCamera.FOV, WorldHost.HUD)
	assert_almost_eq(_world.base.camera.rig.default_distance, under_the_title.x, 1e-4)


func test_hides_and_pauses_for_a_tab_with_no_view_of_the_world() -> void:
	_world.set_shown(false)
	assert_false(_world.visible)
	assert_eq(_world.process_mode, Node.PROCESS_MODE_DISABLED)
	_world.set_shown(true)
	assert_true(_world.visible)
	assert_eq(_world.process_mode, Node.PROCESS_MODE_INHERIT)


func add_child_to_window(node: Node) -> void:
	(Engine.get_main_loop() as SceneTree).root.add_child(node)
