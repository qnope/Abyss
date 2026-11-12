extends TestCase
## The islet's life: bubbles round the lamps, the turtle, the school of fish.

const ISLAND := preload("res://assets/models/base_island.glb")
const Type := BuildingType.Value

var _island: Node3D
var _pads: BasePads
var _buildings: BaseBuildings
var _life: IsletLife


func before_each() -> void:
	_island = ISLAND.instantiate() as Node3D
	_pads = BasePads.new(_island.get_node("Pads") as Node3D)
	_buildings = BaseBuildings.new()
	_life = IsletLife.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_life)


func after_each() -> void:
	for node: Node in [_island, _buildings, _life]:
		node.free()


func test_a_turtle_swims_round_the_island_and_fish_drift_by() -> void:
	assert_eq(_life.turtle.creature.position.x, IsletLife.REACH)
	assert_almost_eq(_life.turtle.creature.position.y, IsletLife.DEPTH, 1e-5)
	assert_eq(_life.fish.multimesh.instance_count, FishSchool.COUNT)
	assert_true(_life.is_ancestor_of(_life.fish))


func test_no_bubble_rises_while_no_lamp_burns() -> void:
	assert_false(_life.lamps.emitting)
	_show([PadState.new(Type.ALGAE_FARM, 1), PadState.new(Type.BARRACKS, 1)])
	assert_false(_life.lamps.emitting)


func test_bubbles_rise_round_the_buildings_that_carry_a_lamp() -> void:
	_show([PadState.new(Type.HEADQUARTERS, 1), PadState.new(Type.VOLCANIC_KERNEL, 1),
		PadState.new(Type.ALGAE_FARM, 1)])
	assert_true(_life.lamps.emitting)
	assert_eq(_life.lamps.emission_points.size(), 2 * 6)
	var origin := _pads.origin_of(&"Headquarters")
	var near := false
	for point in _life.lamps.emission_points:
		near = near or Vector2(point.x - origin.x, point.z - origin.z).length() <= RisingBubbles.SPREAD
	assert_true(near)


func test_a_degraded_building_lights_nothing() -> void:
	_show([PadState.new(Type.HEADQUARTERS, 1, true)])
	assert_false(_life.lamps.emitting)


func test_the_lamps_are_the_buildings_motion_lights() -> void:
	for key: String in BasePartsMotion.LAMPS:
		assert_has(IsletLife.LAMPS, StringName(key.get_slice("/", 0)))


func test_stops_and_hides_with_the_particles_and_starts_again() -> void:
	_show([PadState.new(Type.HEADQUARTERS, 1)])
	_life.set_running(false)
	assert_false(_life.visible)
	assert_false(_life.lamps.emitting)
	assert_eq(_life.process_mode, Node.PROCESS_MODE_DISABLED)
	_life.set_running(true)
	assert_true(_life.visible)
	assert_true(_life.lamps.emitting)
	assert_eq(_life.process_mode, Node.PROCESS_MODE_INHERIT)


func test_staying_stopped_when_a_lamp_is_lit() -> void:
	_life.set_running(false)
	_show([PadState.new(Type.HEADQUARTERS, 1)])
	assert_false(_life.lamps.emitting)


func _show(states: Array[PadState]) -> void:
	_buildings.build(states, _pads)
	_life.show_lamps(_pads, _buildings)
