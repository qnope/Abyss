extends TestCase
## The base of a game on the island: the buildings it has built stand on
## their pads (those with a model), the others stay empty pads.

var _base: BaseScene


func before_each() -> void:
	_base = BaseScene.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_base)


func after_each() -> void:
	_base.free()


func test_stands_the_buildings_the_player_has_built() -> void:
	var player := GameSamples.player_with("Nemo", {
		BuildingType.Value.HEADQUARTERS: 1, BuildingType.Value.SOLAR_PANEL: 3,
		BuildingType.Value.LABORATORY: 0,
	})
	_base.show_base(player.buildings)
	assert_eq(_base.buildings.names(), [&"Headquarters", &"SolarPanel"] as Array[StringName])
	assert_false(_base.pads.is_empty(&"Headquarters"))
	assert_true(_base.pads.is_empty(&"Laboratory"), "a level of 0 is not built")


func test_a_building_with_no_model_leaves_its_pad_bare_not_empty() -> void:
	var player := GameSamples.player_with("Nemo", {BuildingType.Value.BARRACKS: 2})
	_base.show_base(player.buildings)
	assert_eq(_base.buildings.names(), [] as Array[StringName])
	assert_false(_base.pads.is_empty(&"Barracks"), "it is built")
	assert_true(_base.pads.is_empty(&"Headquarters"))


func test_shows_the_base_of_a_new_game() -> void:
	var game := GameFactory.new_single_player("Nemo", 1)
	_base.show_base(game.human_player().buildings)
	var standing := _base.buildings.names()
	for type: BuildingType.Value in game.human_player().buildings:
		var built := game.human_player().buildings[type].level > 0
		var name := BaseBuildings.pad_of(type)
		assert_eq(not _base.pads.is_empty(name), built, str(name))
		if built and BaseBuildings.MODELS.has(name):
			assert_has(standing, name)


func test_a_base_with_nothing_built_shows_empty_pads_only() -> void:
	_base.show_base(GameSamples.player("Nemo").buildings)
	assert_eq(_base.buildings.names(), [] as Array[StringName])
	assert_true(_base.pads.is_empty(&"Headquarters"))


func test_the_bubbles_rise_from_the_buildings_standing() -> void:
	var player := GameSamples.player_with("Nemo", {BuildingType.Value.HEADQUARTERS: 1})
	_base.show_base(player.buildings)
	assert_eq(_base.bubbles.emission_points.size(), 6)


func test_frames_the_island_between_the_bars() -> void:
	_base.frame(0.1, 0.2)
	var size := _base.get_viewport().get_visible_rect().size
	var fitted := OrbitFrame.fit(BaseScene.OUTLINE, OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH,
		size.x / size.y, OrbitCamera.FOV, 0.1, 0.2)
	assert_almost_eq(_base.camera.rig.default_distance, fitted.x, 1e-4)
	assert_almost_eq(_base.camera.rig.lift, fitted.y, 1e-4)
