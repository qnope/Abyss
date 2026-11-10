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
