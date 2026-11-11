extends TestCase
## The buildings of the base, each standing on the pad named after it.

const ISLAND := preload("res://assets/models/base_island.glb")

var _island: Node3D
var _pads: BasePads
var _buildings: BaseBuildings


func before_each() -> void:
	_island = ISLAND.instantiate() as Node3D
	_pads = BasePads.new(_island.get_node("Pads") as Node3D)
	_buildings = BaseBuildings.new()


func after_each() -> void:
	_island.free()
	_buildings.free()


func test_stands_each_building_on_its_pad() -> void:
	_build([&"Headquarters", &"CoralCitadel"])
	assert_eq(_buildings.names(), [&"Headquarters", &"CoralCitadel"] as Array[StringName])
	var headquarters := _buildings.building(&"Headquarters")
	assert_eq(headquarters.position, _pads.origin_of(&"Headquarters"))
	assert_not_null(headquarters.get_node("Headquarters/Beacon"))
	assert_eq(_buildings.building(&"CoralCitadel").position, _pads.origin_of(&"CoralCitadel"))


func test_builds_anew_in_place_of_the_last_ones() -> void:
	_build([&"Headquarters"])
	_build([&"SolarPanel"])
	assert_eq(_buildings.names(), [&"SolarPanel"] as Array[StringName])
	assert_null(_buildings.building(&"Headquarters"))


func test_a_building_with_no_model_stands_as_its_stand_in() -> void:
	_build([&"Headquarters", &"Barracks"])
	assert_eq(_buildings.names(), [&"Headquarters", &"Barracks"] as Array[StringName])
	var barracks := _buildings.building(&"Barracks") as StandIn
	assert_not_null(barracks)
	assert_eq(barracks.position, _pads.origin_of(&"Barracks"))
	assert_false(_buildings.building(&"Headquarters") is StandIn)


func test_stands_the_plots_nowhere() -> void:
	var states: Array[PadState] = [PadState.new(BuildingType.Value.BARRACKS, 0, false, true)]
	_buildings.build(states, _pads)
	assert_eq(_buildings.names(), [] as Array[StringName])


func test_stands_a_building_at_its_level_and_greyed_when_degraded() -> void:
	var states: Array[PadState] = [
		PadState.new(BuildingType.Value.BARRACKS, 8, true),
		PadState.new(BuildingType.Value.LABORATORY, 2),
	]
	_buildings.build(states, _pads)
	var barracks := _buildings.building(&"Barracks") as StandIn
	assert_eq([barracks.level, barracks.degraded], [8, true])
	assert_true(_buildings.is_degraded(&"Barracks"))
	assert_false(_buildings.is_degraded(&"Laboratory"))
	assert_false(_buildings.is_degraded(&"Headquarters"), "it does not stand")
	assert_eq((_buildings.building(&"Laboratory") as StandIn).level, 2)


func test_can_show_the_stand_ins_alone() -> void:
	_buildings.use_models = false
	_build([&"Headquarters", &"SolarPanel", &"CoralCitadel"])
	for name in _buildings.names():
		assert_true(_buildings.building(name) is StandIn, str(name))


func test_names_the_pad_of_each_building_of_the_game() -> void:
	assert_eq(BaseBuildings.pad_of(BuildingType.Value.HEADQUARTERS), &"Headquarters")
	assert_eq(BaseBuildings.pad_of(BuildingType.Value.SOLAR_PANEL), &"SolarPanel")
	for type: BuildingType.Value in BuildingType.Value.values():
		assert_has(_pads.names(), BaseBuildings.pad_of(type))


func test_finds_the_building_of_a_pad() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		assert_eq(BaseBuildings.type_of(BaseBuildings.pad_of(type)), type)


func test_a_pad_that_is_nobodys_is_an_error() -> void:
	expect_error("no building has a pad called Nowhere")
	BaseBuildings.type_of(&"Nowhere")


func _build(names: Array[StringName]) -> void:
	_buildings.build(PadState.standing(names), _pads)
