extends TestCase
## The base's slow life: the headquarters' beacon spinning and flashing, its
## dish sweeping, the solar array tracking, the citadel's heart beating and
## the empty pads breathing.

const ISLAND := preload("res://assets/models/base_island.glb")

var _island: Node3D
var _pads: BasePads
var _buildings: BaseBuildings
var _motion: BaseMotion


func before_each() -> void:
	_island = ISLAND.instantiate() as Node3D
	_pads = BasePads.new(_island.get_node("Pads") as Node3D)
	_buildings = BaseBuildings.new()
	_buildings.build(PadState.standing(BaseScene.BUILT), _pads)
	_motion = BaseMotion.new(_buildings, _pads.marker)
	_motion.track()


func after_each() -> void:
	_island.free()
	_buildings.free()
	_motion.free()


func test_turns_the_moving_parts() -> void:
	_motion.advance(1.5)
	assert_ne(_part(&"Headquarters", "Beacon").rotation.y, 0.0)
	assert_ne(_part(&"Headquarters", "Dish").rotation.y, 0.0)
	assert_ne(_part(&"SolarPanel", "Array").rotation.y, 0.0)
	assert_ne(_part(&"CoralCitadel", "Heart").scale, Vector3.ONE)


func test_lights_the_beacon_and_the_heart_on_their_own() -> void:
	var beacon := _part(&"Headquarters", "Beacon") as MeshInstance3D
	var lamp := beacon.get_surface_override_material(1) as StandardMaterial3D
	assert_not_null(lamp, "a lamp of its own, not the whole keep's")
	_motion.advance(BaseMotion.FLASH_CYCLE / 4.0)
	var flash := lamp.emission_energy_multiplier
	_motion.advance(BaseMotion.FLASH_CYCLE / 2.0)
	assert_true(flash > lamp.emission_energy_multiplier * 2.0, "a short flash")
	var heart := _part(&"CoralCitadel", "Heart") as MeshInstance3D
	assert_not_null(heart.get_surface_override_material(1))


func test_breathes_the_empty_pads() -> void:
	_motion.advance(PadMarker.PULSE_CYCLE / 4.0)
	assert_true(_pads.marker.glow.emission_energy_multiplier > PadMarker.GLOW_ENERGY)


func test_runs_with_the_buildings_that_stand() -> void:
	_buildings.build(PadState.standing([&"SolarPanel"] as Array[StringName]), _pads)
	_motion.track()
	_motion.advance(1.0)
	assert_ne(_part(&"SolarPanel", "Array").rotation.y, 0.0)


func test_leaves_a_stand_in_still() -> void:
	_buildings.use_models = false
	_buildings.build(PadState.standing(BaseScene.BUILT), _pads)
	_motion.track()
	_motion.advance(1.0)
	assert_true(_buildings.building(&"Headquarters") is StandIn)
	assert_eq(_buildings.building(&"CoralCitadel").scale, Vector3.ONE)


func test_a_degraded_building_stays_still() -> void:
	var states: Array[PadState] = [PadState.new(BuildingType.Value.CORAL_CITADEL, 2, true)]
	_buildings.build(states, _pads)
	_motion.track()
	_motion.advance(1.0)
	assert_true(_buildings.is_degraded(&"CoralCitadel"))
	assert_eq(_part(&"CoralCitadel", "Heart").scale, Vector3.ONE)
	assert_null((_part(&"CoralCitadel", "Heart") as MeshInstance3D).get_surface_override_material(1))


func test_moves_frame_by_frame() -> void:
	_motion._process(0.5)
	assert_ne(_part(&"Headquarters", "Dish").rotation.y, 0.0)


func test_its_curves_loop() -> void:
	assert_almost_eq(BaseMotion.sweep(0.0, 30.0, 12.0), 0.0, 1e-6)
	assert_almost_eq(BaseMotion.sweep(3.0, 30.0, 12.0), deg_to_rad(30.0), 1e-6)
	assert_almost_eq(BaseMotion.flash(0.0), 0.0, 1e-6)
	assert_almost_eq(BaseMotion.flash(BaseMotion.FLASH_CYCLE / 4.0), 1.0, 1e-6)


func _part(building: StringName, part: String) -> Node3D:
	return _buildings.building(building).get_node("%s/%s" % [building, part]) as Node3D
