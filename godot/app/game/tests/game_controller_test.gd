extends UiTestCase
## The glue between the game screen and the world: the tab on show decides
## which view the world shows, a change of the game redraws both, and the
## ways out of the screen are told on.

var _folder: TempFolder
var _game: Game
var _session: GameSession
var _world: WorldHost
var _hud: GameHud
var _controller: GameController
var _quits := 0
var _languages: Array[LanguageChoice.Value] = []


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_game = GameFactory.new_single_player("Nemo", 1)
	_game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level = 1
	_session = GameSession.new(_game, GameRepository.new(_folder.path.path_join("saves")))
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_hud = GameHud.new(_session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(_hud)
	_controller = GameController.new(_session, _hud, _world)
	_controller.quit_requested.connect(func() -> void: _quits += 1)
	_controller.language_chosen.connect(_languages.append)
	# The listener of `quit_requested` holds the test: let go of the controller.
	add_cleanup(func() -> void: _controller = null)


func test_shows_the_base_of_the_game_in_the_world() -> void:
	var built := _built_pads()
	assert_eq(built, [&"Headquarters"] as Array[StringName])
	for pad in _world.base.buildings.names():
		assert_has(built, pad)
	assert_true(_world.visible)


func test_the_world_follows_the_tab_on_show() -> void:
	press("Carte")
	assert_false(_world.visible)
	assert_eq(_world.process_mode, Node.PROCESS_MODE_DISABLED)
	press("Tech")
	assert_false(_world.visible)
	press("Base")
	assert_true(_world.visible)
	assert_eq(_world.process_mode, Node.PROCESS_MODE_INHERIT)


func test_a_change_of_the_game_is_saved_then_redraws_the_screen() -> void:
	var before := _hud.turn_bar.turn_label.text
	_game.turn = 4
	_session.actions.set_tips_enabled(true)
	assert_eq(before, "Tour 1")
	assert_eq(_hud.turn_bar.turn_label.text, "Tour 4")
	assert_eq(_session.repository.load_all().games.size(), 1)


func test_a_new_building_stands_on_the_base_after_the_change() -> void:
	var player := _game.human_player()
	assert_null(_world.base.buildings.building(&"SolarPanel"))
	player.buildings[BuildingType.Value.SOLAR_PANEL].level = 1
	_session.actions.mark(func(_g: Game) -> void: pass)
	assert_not_null(_world.base.buildings.building(&"SolarPanel"))


func test_frames_the_island_between_the_bars_when_the_area_moves() -> void:
	_hud.content.position = Vector2(0.0, 100.0)
	_hud.content.size = Vector2(390.0, 600.0)
	var size := _world.get_viewport().get_visible_rect().size
	var fitted := OrbitFrame.fit(BaseScene.OUTLINE, OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH,
		size.x / size.y, OrbitCamera.FOV, _hud.content.global_position.y / size.y,
		(size.y - _hud.content.global_position.y - 600.0) / size.y)
	assert_almost_eq(_world.base.camera.rig.default_distance, fitted.x, 1e-3)


func test_waits_for_the_screen_to_be_in_the_tree_to_frame_the_island() -> void:
	var distance := _world.base.camera.rig.default_distance
	var screen := GameHud.new(_session.actions, LanguageChoice.Value.FRENCH, modals())
	GameController.new(_session, screen, _world)
	assert_eq(_world.base.camera.rig.default_distance, distance)
	screen.free()


func test_saving_and_quitting_is_told_on_to_the_flow() -> void:
	_hud.open_settings()
	press("Sauvegarder et quitter")
	assert_eq(_quits, 1)


func test_a_language_picked_is_told_on_to_the_flow() -> void:
	_hud.open_settings()
	press("Español")
	assert_eq(_languages, [LanguageChoice.Value.SPANISH] as Array[LanguageChoice.Value])


func test_closing_gives_the_world_back_to_the_menu() -> void:
	press("Carte")
	_controller.close()
	assert_true(_world.visible)
	assert_eq(_world.base.buildings.names(), BaseScene.BUILT)
	_session.actions.set_tips_enabled(true)
	assert_eq(_world.base.buildings.names(), BaseScene.BUILT, "a closed screen no longer follows")


func _built_pads() -> Array[StringName]:
	var built: Array[StringName] = []
	for type: BuildingType.Value in _game.human_player().buildings:
		if _game.human_player().buildings[type].level > 0:
			built.append(BaseBuildings.pad_of(type))
	return built
