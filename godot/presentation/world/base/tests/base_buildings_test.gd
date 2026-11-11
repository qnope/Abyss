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
	_buildings.build([&"Headquarters", &"CoralCitadel"] as Array[StringName], _pads)
	assert_eq(_buildings.names(), [&"Headquarters", &"CoralCitadel"] as Array[StringName])
	var headquarters := _buildings.building(&"Headquarters")
	assert_eq(headquarters.position, _pads.origin_of(&"Headquarters"))
	assert_not_null(headquarters.get_node("Headquarters/Beacon"))
	assert_eq(_buildings.building(&"CoralCitadel").position, _pads.origin_of(&"CoralCitadel"))


func test_builds_anew_in_place_of_the_last_ones() -> void:
	_buildings.build([&"Headquarters"] as Array[StringName], _pads)
	_buildings.build([&"SolarPanel"] as Array[StringName], _pads)
	assert_eq(_buildings.names(), [&"SolarPanel"] as Array[StringName])
	assert_null(_buildings.building(&"Headquarters"))


func test_has_a_model_for_each_building_of_the_prototype() -> void:
	for name: StringName in [&"Headquarters", &"SolarPanel", &"CoralCitadel"]:
		assert_has(BaseBuildings.MODELS, name)


func test_names_the_pad_of_each_building_of_the_game() -> void:
	assert_eq(BaseBuildings.pad_of(BuildingType.Value.HEADQUARTERS), &"Headquarters")
	assert_eq(BaseBuildings.pad_of(BuildingType.Value.SOLAR_PANEL), &"SolarPanel")
	for type: BuildingType.Value in BuildingType.Value.values():
		assert_has(_pads.names(), BaseBuildings.pad_of(type))


func test_shows_nothing_of_a_building_that_has_no_model_yet() -> void:
	_buildings.build([&"Headquarters", &"Barracks"] as Array[StringName], _pads)
	assert_eq(_buildings.names(), [&"Headquarters"] as Array[StringName])
	assert_null(_buildings.building(&"Barracks"))
