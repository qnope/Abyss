extends TestCase
## The moving parts of the other buildings: the drill, the winch wheels, the
## drone, the atom, the beacons and the kernel's flame.

const ISLAND := preload("res://assets/models/base_island.glb")
const Type := BuildingType.Value
const TYPES: Array[BuildingType.Value] = [
	Type.ALGAE_FARM, Type.CORAL_MINE, Type.ORE_EXTRACTOR, Type.LABORATORY, Type.DESCENT_MODULE,
	Type.PRESSURE_CAPSULE, Type.VOLCANIC_KERNEL,
]

var _island: Node3D
var _pads: BasePads
var _buildings: BaseBuildings
var _motion: BasePartsMotion


func before_each() -> void:
	_island = ISLAND.instantiate() as Node3D
	_pads = BasePads.new(_island.get_node("Pads") as Node3D)
	_buildings = BaseBuildings.new()
	_build(false)
	_motion = BasePartsMotion.new()
	_motion.track(_buildings)


func after_each() -> void:
	_island.free()
	_buildings.free()


func test_turns_the_drill_the_wheels_the_drone_and_the_atom() -> void:
	_motion.advance(1.0)
	assert_ne(_part(&"OreExtractor", "Drill").rotation.y, 0.0)
	assert_ne(_part(&"AlgaeFarm", "Drone").rotation.y, 0.0)
	assert_ne(_part(&"CoralMine", "Wheel").rotation.z, 0.0)
	assert_ne(_part(&"CoralMine", "CrownWheel").rotation.z, 0.0)
	assert_ne(_part(&"Laboratory", "Atom").rotation.y, 0.0)


func test_the_drone_bobs_around_its_height() -> void:
	var drone := _part(&"AlgaeFarm", "Drone")
	var rest := drone.position.y
	_motion.advance(BasePartsMotion.BOB_CYCLE / 4.0)
	assert_almost_eq(drone.position.y, rest + BasePartsMotion.BOBS["AlgaeFarm/Drone"], 1e-4)


func test_the_flame_swells_and_the_lamps_pulse_on_their_own() -> void:
	var flame := _part(&"VolcanicKernel", "Flame") as MeshInstance3D
	_motion.advance(BasePartsMotion.PULSE_CYCLE / 4.0)
	assert_true(flame.scale.y > 1.0)
	var lamp := flame.get_surface_override_material(0) as StandardMaterial3D
	assert_almost_eq(lamp.emission_energy_multiplier, 3.4, 1e-4)
	_motion.advance(BasePartsMotion.PULSE_CYCLE * 3.0 / 4.0)
	assert_almost_eq(lamp.emission_energy_multiplier, 1.2, 1e-4)
	var beacon := _part(&"DescentModule", "Beacon") as MeshInstance3D
	assert_not_null(beacon.get_surface_override_material(1))
	assert_not_null((_part(&"PressureCapsule", "Beacon") as MeshInstance3D).get_surface_override_material(1))


func test_a_degraded_building_stays_still() -> void:
	_build(true)
	_motion.track(_buildings)
	_motion.advance(1.0)
	assert_eq(_part(&"OreExtractor", "Drill").rotation.y, 0.0)
	assert_null((_part(&"VolcanicKernel", "Flame") as MeshInstance3D).get_surface_override_material(0))


func test_leaves_a_stand_in_and_the_hidden_parts_alone() -> void:
	_buildings.use_models = false
	_build(false)
	_motion.track(_buildings)
	_motion.advance(1.0)
	assert_true(_buildings.building(&"Laboratory") is StandIn)


func _build(degraded: bool) -> void:
	var states: Array[PadState] = []
	for type in TYPES:
		states.append(PadState.new(type, 8, degraded))
	_buildings.build(states, _pads)


func _part(building: StringName, part: String) -> Node3D:
	return _buildings.building(building).find_child(part, true, false) as Node3D
