extends TestCase
## The moving parts of the production buildings: the drone, the winch wheels
## and the drill.

const ISLAND := preload("res://assets/models/base_island.glb")
const PARTS := {
	&"AlgaeFarm": "Drone", &"CoralMine": "Wheel", &"OreExtractor": "Drill",
}

var _island: Node3D
var _buildings: BaseBuildings
var _motion: BaseMotion


func before_each() -> void:
	_island = ISLAND.instantiate() as Node3D
	var pads := BasePads.new(_island.get_node("Pads") as Node3D)
	_buildings = BaseBuildings.new()
	var states: Array[PadState] = []
	for type: BuildingType.Value in [
		BuildingType.Value.ALGAE_FARM, BuildingType.Value.CORAL_MINE, BuildingType.Value.ORE_EXTRACTOR,
	]:
		states.append(PadState.new(type, 8))
	_buildings.build(states, pads)
	_motion = BaseMotion.new(_buildings, pads.marker)
	_motion.track()


func after_each() -> void:
	_island.free()
	_buildings.free()
	_motion.free()


func test_turns_the_drill_the_wheels_and_the_drone() -> void:
	_motion.advance(1.0)
	assert_ne(_part(&"OreExtractor", "Drill").rotation.y, 0.0)
	assert_ne(_part(&"AlgaeFarm", "Drone").rotation.y, 0.0)
	assert_ne(_part(&"CoralMine", "Wheel").rotation.z, 0.0)
	assert_ne(_part(&"CoralMine", "CrownWheel").rotation.z, 0.0)


func test_the_drone_bobs_around_its_height() -> void:
	var drone := _part(&"AlgaeFarm", "Drone")
	var rest := drone.position.y
	_motion.advance(BaseMotion.DRONE_CYCLE / 4.0)
	assert_almost_eq(drone.position.y, rest + BaseMotion.DRONE_BOB, 1e-4)


func test_a_degraded_one_stays_still() -> void:
	var degraded: Array[PadState] = [PadState.new(BuildingType.Value.ORE_EXTRACTOR, 2, true)]
	_buildings.build(degraded, BasePads.new(_island.get_node("Pads") as Node3D))
	_motion.track()
	_motion.advance(1.0)
	assert_eq(_part(&"OreExtractor", "Drill").rotation.y, 0.0)


func _part(building: StringName, part: String) -> Node3D:
	return _buildings.building(building).find_child(part, true, false) as Node3D
