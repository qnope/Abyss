extends TestCase
## The eleven pads of a game's base, filled by level and by state, and what a
## tap on each tells.

const Type := BuildingType.Value

var _base: BaseScene
var _taps: Array[BuildingType.Value] = []


func before_each() -> void:
	_base = BaseScene.new()
	_base.building_tapped.connect(_taps.append)
	(Engine.get_main_loop() as SceneTree).root.add_child(_base)


func after_each() -> void:
	_base.free()


func test_fills_the_eleven_pads_of_a_full_base() -> void:
	var player := _full_base()
	_base.show_base(player.buildings)
	assert_eq(_base.buildings.names().size(), 11)
	for type: BuildingType.Value in Type.values():
		var building := _base.buildings.building(BaseBuildings.pad_of(type))
		assert_not_null(building, str(type))
		assert_eq(building is StandIn, not WorldModels.has_model(type), str(type))


func test_a_stand_in_rises_with_the_level_of_its_building() -> void:
	var player := GameSamples.player_with("Nemo", {Type.HEADQUARTERS: 10, Type.ALGAE_FARM: 1})
	_base.show_base(player.buildings)
	var low := _base.buildings.building(&"AlgaeFarm") as StandIn
	assert_almost_eq(low.scale.y, StandIn.TIER_HEIGHT[1], 1e-5)
	player.buildings[Type.ALGAE_FARM].level = 5
	_base.show_base(player.buildings)
	var risen := _base.buildings.building(&"AlgaeFarm") as StandIn
	assert_almost_eq(risen.scale.y, StandIn.TIER_HEIGHT[2], 1e-5)


func test_greys_the_buildings_the_headquarters_is_too_low_for() -> void:
	var player := GameSamples.player_with("Nemo", {Type.HEADQUARTERS: 1, Type.BARRACKS: 3})
	_base.show_base(player.buildings)
	assert_true((_base.buildings.building(&"Barracks") as StandIn).degraded)
	player.buildings[Type.HEADQUARTERS].level = 6
	_base.show_base(player.buildings)
	assert_false((_base.buildings.building(&"Barracks") as StandIn).degraded)


func test_writes_the_level_and_signs_what_each_pad_needs() -> void:
	var player := GameSamples.player_with("Nemo", {
		Type.HEADQUARTERS: 2, Type.BARRACKS: 3, Type.LABORATORY: 1, Type.SOLAR_PANEL: 0,
		Type.ALGAE_FARM: 0, Type.CORAL_MINE: 0,
	})
	_base.show_base(player.buildings, {Type.LABORATORY: true, Type.ALGAE_FARM: true},
		{Type.CORAL_MINE: true})
	var kinds: Array[PadMark.Kind] = []
	var levels := PackedStringArray()
	for mark: Node in _base.marks.get_children():
		if mark is PadMark:
			kinds.append((mark as PadMark).kind)
		else:
			levels.append((mark as PadLevelLabel).text)
	assert_eq(levels, PackedStringArray(["2", "3", "1"]))
	assert_eq(kinds, [PadMark.Kind.DEGRADED, PadMark.Kind.UPGRADE, PadMark.Kind.BUILD,
		PadMark.Kind.LOCKED] as Array[PadMark.Kind])


func test_the_signs_change_with_the_game_not_with_a_same_base() -> void:
	var player := GameSamples.player_with("Nemo", {Type.HEADQUARTERS: 1, Type.ALGAE_FARM: 1})
	_base.show_base(player.buildings, {Type.ALGAE_FARM: true})
	var marks := _base.marks.get_child_count()
	_base.show_base(player.buildings, {Type.ALGAE_FARM: true})
	assert_eq(_base.marks.get_child_count(), marks)
	_base.show_base(player.buildings)
	assert_eq(_base.marks.get_child_count(), marks - 1, "the arrow is gone")


func test_can_show_every_building_as_its_stand_in() -> void:
	_base.buildings.use_models = false
	_base.show_base(_full_base().buildings)
	for name in _base.buildings.names():
		assert_true(_base.buildings.building(name) is StandIn, str(name))


func test_tells_the_building_of_the_pad_tapped_built_or_not() -> void:
	var player := GameSamples.player_with("Nemo", {
		Type.HEADQUARTERS: 1, Type.BARRACKS: 2, Type.LABORATORY: 0,
	})
	_base.show_base(player.buildings)
	for type: BuildingType.Value in [Type.HEADQUARTERS, Type.BARRACKS, Type.LABORATORY]:
		var pad := _base.pads.origin_of(BaseBuildings.pad_of(type)) + Vector3.UP * 0.5
		_base.camera.tapped.emit(_base.camera.unproject_position(pad))
	assert_eq(_taps, [Type.HEADQUARTERS, Type.BARRACKS, Type.LABORATORY] as Array[BuildingType.Value])


func _full_base() -> Player:
	var player := GameFactory.new_single_player("Nemo", 1).human_player()
	for building: Building in player.buildings.values():
		building.level = 2
	return player
