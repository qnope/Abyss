extends TestCase
## The one place that chooses between a model and a stand-in.

const Type := BuildingType.Value

var _made: Array[Node3D] = []


func after_each() -> void:
	for node in _made:
		node.free()


func test_has_a_model_for_the_buildings_that_have_one() -> void:
	var with_model: Array[BuildingType.Value] = []
	for type: BuildingType.Value in BuildingType.Value.values():
		if WorldModels.has_model(type):
			with_model.append(type)
	assert_eq(with_model, [
		Type.HEADQUARTERS, Type.ALGAE_FARM, Type.CORAL_MINE, Type.ORE_EXTRACTOR, Type.SOLAR_PANEL,
		Type.LABORATORY, Type.BARRACKS, Type.CORAL_CITADEL, Type.DESCENT_MODULE, Type.PRESSURE_CAPSULE,
		Type.VOLCANIC_KERNEL,
	] as Array[BuildingType.Value])


func test_gives_the_model_when_there_is_one() -> void:
	var node := _make(Type.HEADQUARTERS, 3)
	assert_false(node is StandIn)
	assert_not_null(node.get_node("Headquarters/Beacon"))


func test_every_building_has_a_model() -> void:
	for type: BuildingType.Value in BuildingType.Value.values():
		assert_true(WorldModels.has_model(type), str(type))
		assert_false(_make(type, 2) is StandIn, str(type))


func test_the_stand_in_can_be_asked_for_whatever_the_building() -> void:
	var node := WorldModels.building(Type.HEADQUARTERS, 5, false, false)
	_made.append(node)
	assert_true(node is StandIn)
	var direct := WorldModels.stand_in(Type.SOLAR_PANEL, 2, true)
	_made.append(direct)
	assert_true(direct.degraded)
	assert_eq(direct.level, 2)


func test_hands_the_level_and_the_degradation_to_the_stand_in() -> void:
	var node := WorldModels.stand_in(Type.BARRACKS, 8, true)
	_made.append(node)
	assert_eq([node.level, node.degraded], [8, true])


func test_a_degraded_model_is_veiled_in_grey() -> void:
	var node := _make(Type.CORAL_CITADEL, 2, true)
	var meshes := node.find_children("*", "GeometryInstance3D", true, false)
	assert_false(meshes.is_empty())
	for mesh: Node in meshes:
		var veil := (mesh as GeometryInstance3D).material_overlay as StandardMaterial3D
		assert_eq(veil.albedo_color, Color(WorldPalette.DEGRADED, WorldModels.VEIL))
	var healthy := _make(Type.CORAL_CITADEL, 2)
	for mesh: Node in healthy.find_children("*", "GeometryInstance3D", true, false):
		assert_null((mesh as GeometryInstance3D).material_overlay)


func _make(type: BuildingType.Value, level: int, degraded := false) -> Node3D:
	var node := WorldModels.building(type, level, degraded)
	# In the tree, as the base's buildings are: freed outside it, a node with
	# its own materials makes the renderer complain.
	(Engine.get_main_loop() as SceneTree).root.add_child(node)
	_made.append(node)
	return node


func test_gives_a_model_to_every_unit_that_swims_attacks_and_is_hit() -> void:
	for type: UnitType.Value in UnitType.Value.values():
		var node := _unit(type)
		assert_false(node is UnitStandIn, str(type))
		assert_eq(node.rotation_degrees.y, WorldModels.FIGURE_YAW)
		var animator := WorldModels.animator(node)
		assert_eq(animator.animations(), [&"attack", &"hit", &"idle", &"swim"] as Array[StringName], str(type))
		assert_eq(animator.current(), ModelAnimator.IDLE)


func test_gives_a_stand_in_to_a_unit_with_no_model() -> void:
	var none: Dictionary[UnitType.Value, PackedScene] = {}
	var node := _unit(UnitType.Value.SCOUT, false, none)
	assert_true(node is UnitStandIn)
	assert_null(WorldModels.animator(node))
	assert_true((_unit(UnitType.Value.GUARDIAN, true, none) as UnitStandIn).ghost)


func test_gives_the_model_of_a_unit_when_there_is_one() -> void:
	var models: Dictionary[UnitType.Value, PackedScene] = {
		UnitType.Value.SCOUT: WorldModels.MODELS[BuildingType.Value.HEADQUARTERS],
	}
	var model := _unit(UnitType.Value.SCOUT, false, models)
	assert_false(model is UnitStandIn)
	for mesh: Node in model.find_children("*", "GeometryInstance3D", true, false):
		assert_null((mesh as GeometryInstance3D).material_overlay)
	var ghost := _unit(UnitType.Value.SCOUT, true, models)
	for mesh: Node in ghost.find_children("*", "GeometryInstance3D", true, false):
		assert_not_null((mesh as GeometryInstance3D).material_overlay)
	assert_true(_unit(UnitType.Value.GUARDIAN, false, models) is UnitStandIn, "the others stay stand-ins")


func _unit(type: UnitType.Value, ghost := false,
		models: Dictionary[UnitType.Value, PackedScene] = WorldModels.UNIT_MODELS) -> Node3D:
	var node := WorldModels.unit(type, ghost, models)
	(Engine.get_main_loop() as SceneTree).root.add_child(node)
	_made.append(node)
	return node
