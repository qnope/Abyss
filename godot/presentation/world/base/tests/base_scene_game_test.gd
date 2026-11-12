extends TestCase
## The base of a game on the island: each building it has built stands on its
## pad (its model, or its stand-in), the others stay empty pads.

const Type := BuildingType.Value

var _base: BaseScene


func before_each() -> void:
	_base = BaseScene.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_base)


func after_each() -> void:
	_base.free()


func test_stands_the_buildings_the_player_has_built() -> void:
	var player := GameSamples.player_with("Nemo", {
		Type.HEADQUARTERS: 1, Type.SOLAR_PANEL: 3, Type.LABORATORY: 0,
	})
	_base.show_base(player.buildings)
	assert_eq(_base.buildings.names(), [&"Headquarters", &"SolarPanel"] as Array[StringName])
	assert_false(_base.pads.is_empty(&"Headquarters"))
	assert_true(_base.pads.is_empty(&"Laboratory"), "a level of 0 is not built")


func test_the_same_base_again_changes_nothing() -> void:
	var player := GameSamples.player_with("Nemo", {Type.HEADQUARTERS: 1})
	_base.show_base(player.buildings)
	var standing := _base.buildings.building(&"Headquarters")
	_base.show_base(player.buildings)
	assert_eq(_base.buildings.building(&"Headquarters"), standing)
	player.buildings[Type.SOLAR_PANEL] = Building.new(Type.SOLAR_PANEL, 1)
	_base.show_base(player.buildings)
	assert_not_null(_base.buildings.building(&"SolarPanel"))


func test_a_building_with_no_model_stands_as_a_stand_in_on_a_pad_that_is_not_empty() -> void:
	var player := GameSamples.player_with("Nemo", {Type.BARRACKS: 2})
	_base.buildings.use_models = false
	_base.show_base(player.buildings)
	assert_eq(_base.buildings.names(), [&"Barracks"] as Array[StringName])
	assert_true(_base.buildings.building(&"Barracks") is StandIn)
	assert_false(_base.pads.is_empty(&"Barracks"), "it is built")
	assert_true(_base.pads.is_empty(&"Headquarters"))


func test_shows_the_base_of_a_new_game() -> void:
	var game := GameFactory.new_single_player("Nemo", 1)
	_base.show_base(game.human_player().buildings)
	for type: BuildingType.Value in game.human_player().buildings:
		var built := game.human_player().buildings[type].level > 0
		var name := BaseBuildings.pad_of(type)
		assert_eq(not _base.pads.is_empty(name), built, str(name))
		assert_eq(_base.buildings.building(name) != null, built, str(name))


func test_a_base_with_nothing_built_shows_empty_pads_only() -> void:
	_base.show_base(GameSamples.player("Nemo").buildings)
	assert_eq(_base.buildings.names(), [] as Array[StringName])
	assert_true(_base.pads.is_empty(&"Headquarters"))


func test_the_bubbles_rise_from_the_buildings_standing() -> void:
	var player := GameSamples.player_with("Nemo", {Type.HEADQUARTERS: 1, Type.BARRACKS: 1})
	_base.show_base(player.buildings)
	assert_eq(_base.bubbles.emission_points.size(), 12)


func test_the_rampart_follows_the_level_of_the_citadel() -> void:
	var player := GameSamples.player_with("Nemo", {Type.HEADQUARTERS: 1, Type.CORAL_CITADEL: 0})
	var tiers: Array[int] = []
	for level: int in [0, 1, 2, 3, 4, 5]:
		player.buildings[Type.CORAL_CITADEL].level = level
		_base.show_base(player.buildings)
		tiers.append(_base.rampart_tier)
	assert_eq(tiers, [0, 1, 1, 2, 2, 3] as Array[int])
	player.buildings.erase(Type.CORAL_CITADEL)
	_base.show_base(player.buildings)
	assert_eq(_base.rampart_tier, 0, "no citadel, no rampart")


func test_the_menus_base_has_the_first_tier_of_the_rampart_back() -> void:
	_base.show_base(GameSamples.player("Nemo").buildings)
	assert_eq(_base.rampart_tier, 0)
	_base.build(BaseScene.BUILT)
	assert_eq(_base.rampart_tier, 1)
	_base.build([&"Headquarters"] as Array[StringName])
	assert_eq(_base.rampart_tier, 0)


func test_frames_the_island_between_the_bars() -> void:
	_base.frame(0.1, 0.2)
	var size := _base.get_viewport().get_visible_rect().size
	var fitted := OrbitFrame.fit(BaseScene.OUTLINE, OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH,
		size.x / size.y, OrbitCamera.FOV, 0.1, 0.2)
	assert_almost_eq(_base.camera.rig.default_distance, fitted.x, 1e-4)
	assert_almost_eq(_base.camera.rig.lift, fitted.y, 1e-4)
